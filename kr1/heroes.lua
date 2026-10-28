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
local V = require("lib.klua.vector")
local v = V.v
local vv = V.vv

local U = require("utils")
local SU = require("script_utils")

require("game_templates_utils")

tt = RT("ps_arrow_multishot_hero_alleria")
AC(tt, "pos", "particle_system")
tt.particle_system.name = "hero_archer_arrow_particle"
tt.particle_system.alphas = {255, 0}
tt.particle_system.particle_lifetime = {0.1, 0.1}
tt.particle_system.emission_rate = 30
tt.particle_system.track_rotation = true
tt.particle_system.z = Z_BULLETS

tt = RT("aura_beastmaster_regeneration", "aura")
AC(tt, "hps")
tt.hps.heal_min = 6
tt.hps.heal_max = 6
tt.hps.heal_every = 0.25
tt.main_script.update = scripts.aura_beastmaster_regeneration.update

tt = RT("mod_van_helsing_crosshair", "modifier")
AC(tt, "render")
tt.render.sprites[1].name = "vanhelsing_crosshair"
tt.render.sprites[1].sort_y_offset = -2
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = fts(16)

tt = RT("mod_van_helsing_beacon", "modifier")
AC(tt, "render")
tt.main_script.insert = scripts.mod_van_helsing_beacon.insert
tt.main_script.remove = scripts.mod_van_helsing_beacon.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = 1
tt.modifier.use_mod_offset = false
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "Halloween_hero_vhelsing_buffeffect"
tt.render.sprites[1].z = Z_DECALS

tt = RT("mod_anya_ultimate_beacon", "mod_van_helsing_beacon")
tt.inflicted_damage_factor = 2
tt.modifier.duration = 12
tt.render.sprites[1].color = {100, 100, 255}
tt.render.sprites[1].scale = vec_1(1.2)

tt = RT("hero_steam_frigate", "stage_hero")
AC(tt, "ranged", "timed_attacks")
image_y = 120
anchor_y = 0.16666666666666666
tt.health.armor = 0.7
tt.health.hp_max = 420
tt.health.immune_to = DAMAGE_ALL
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.level = 10
tt.idle_flip = nil
tt.info.fn = scripts.hero_basic.get_info
tt.info.hero_portrait = "kr2_hero_portraits_0018"
tt.info.portrait = "kr2_info_portraits_heroes_0018"
tt.main_script.insert = nil
tt.main_script.update = scripts.hero_steam_frigate.update
tt.motion.max_speed = 75
tt.nav_grid.valid_terrains = bor(TERRAIN_WATER)
tt.nav_grid.valid_terrains_dest = bor(TERRAIN_WATER)
tt.nav_rally.requires_node_nearby = false
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_steam_frigate_l1"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].anchor.y = anchor_y
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].prefix = "hero_steam_frigate_l2"
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].anchor.y = anchor_y
tt.render.sprites[3].loop_forced = true
tt.render.sprites[3].name = "idle"
tt.render.sprites[3].prefix = "hero_steam_frigate_smoke"
tt.sound_events.change_rally_point = "PirateBoatTaunt"
tt.ui.click_rect = r(-30, 0, 60, 38)
tt.unit.mod_offset = vec_2(0, ady(22))
tt.vis.bans = F_ALL
tt.vis.flags = F_NONE
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "throw_barrel"
tt.ranged.attacks[1].bullet = "steam_frigate_barrel"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(29, 39)}
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].max_range = 250
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].node_prediction = fts(33)
tt.ranged.attacks[1].shoot_time = fts(13)
tt.ranged.attacks[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].animation = "throw_mine"
tt.timed_attacks.list[1].bullet = "steam_frigate_mine"
tt.timed_attacks.list[1].bullet_start_offset = {vec_2(29, 39)}
tt.timed_attacks.list[1].cooldown = 8
tt.timed_attacks.list[1].max_mines = 20
tt.timed_attacks.list[1].max_range = 150
tt.timed_attacks.list[1].min_range = 16.5
tt.timed_attacks.list[1].shoot_time = fts(13)
tt.timed_attacks.list[1].valid_terrains = TERRAIN_WATER

tt = RT("steam_frigate_barrel", "bomb")
tt.bullet.flight_time = fts(20)
tt.bullet.g = -1.5 / (fts(1) * fts(1))
tt.bullet.damage_min = 80
tt.bullet.damage_max = 100
tt.bullet.damage_radius = 96
tt.bullet.hide_radius = nil
tt.render.sprites[1].name = "pirateHero_proy_0001"
tt.sound_events.insert = "AxeSound"

tt = RT("steam_frigate_mine", "bomb")
AC(tt, "lifespan")
tt.bullet.damage_bans = bor(F_FLYING)
tt.bullet.damage_max = 280
tt.bullet.damage_min = 280
tt.bullet.damage_radius = 76.80000000000001
tt.bullet.flight_time = fts(20)
tt.bullet.g = -1.5 / (fts(1) * fts(1))
tt.bullet.hide_radius = nil
tt.bullet.pop = nil
tt.bullet.vis_bans = bor(F_FLYING)
tt.lifespan.duration = 40
tt.main_script.update = scripts.steam_frigate_mine.update
tt.render.sprites[1].name = "pirateHero_proy_0002"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].anchor.y = 0.38
tt.render.sprites[2].hidden = true
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].prefix = "steam_frigate_mine"
tt.sound_events.insert = "AxeSound"
tt.trigger_radius = 10

tt = RT("mod_hero_elves_archer_slow", "mod_slow")
tt.modifier.duration = 1

tt = RT("arrow_hero_elves_archer_ultimate", "bullet")
tt.main_script.update = scripts.arrow_hero_elves_archer_ultimate.update
tt.bullet.damage_radius = 35
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_bans = F_FRIEND
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.arrive_decal = "decal_hero_elves_archer_ultimate"
tt.bullet.max_speed = 1500
tt.bullet.mod = "mod_hero_elves_archer_slow"
tt.render.sprites[1].name = "archer_hero_arrows_proy-f"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.x = 0.9629629629629629
tt.sound_events.insert = "ArrowSound"

tt = RT("decal_hero_elves_archer_ultimate", "decal_tween")
AC(tt, "main_script")
tt.main_script.insert = scripts.decal_hero_elves_archer_ultimate.insert
tt.tween.props[1].keys = {{0, 255}, {1, 255}, {4, 0}}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.render.sprites[1].name = "decal_hero_elves_archer_ultimate"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "fx_hero_elves_archer_ultimate_smoke"
tt.render.sprites[2].loop = false

tt = RT("mod_lynn_ultimate", "modifier")
AC(tt, "dps", "render", "tween")
tt.render.sprites[1].name = "mod_lynn_ultimate"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "mod_lynn_ultimate_decal_loop"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].name = "mod_lynn_ultimate_over"
tt.render.sprites[3].draw_order = 10
tt.tween.props[1].keys = {{0, 0}, {0.3, 255}, {"this.modifier.duration-0.3", 255}, {"this.modifier.duration", 0}}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 3
tt.tween.remove = false
tt.main_script.insert = scripts.mod_lynn_ultimate.insert
tt.main_script.update = scripts.mod_lynn_ultimate.update
tt.modifier.vis_flags = bor(F_MOD, F_RANGED)
tt.modifier.duration = 5
tt.modifier.health_bar_offset = vec_2(0, 10)
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_every = fts(15)
tt.dps.damage_type = DAMAGE_TRUE
tt.explode_fx = "fx_lynn_explosion"
tt.explode_range = 80
tt.explode_damage_type = DAMAGE_TRUE
tt.explode_vis_flags = F_RANGED
tt.explode_vis_bans = 0

tt = RT("soldier_veznan_demon", "soldier_militia")
AC(tt, "reinforcement", "ranged", "nav_grid")
tt.controable = true
tt.controable_other = true
tt.health.magic_armor = 0.5
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 65)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr3_info_portraits_soldiers_0011"
tt.info.random_name_count = 8
tt.info.random_name_format = "ELVES_SOLDIER_VEZNAN_DEMON_%i_NAME"
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].mod = "mod_veznan_demon_fire"
tt.melee.continue_in_cooldown = true
tt.melee.range = 65
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 65
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].bullet = "fireball_veznan_demon"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(25, 42)}
tt.ranged.attacks[1].shoot_time = fts(13)
tt.ranged.attacks[1].node_prediction = fts(25)
tt.regen.health = 0
tt.reinforcement.duration = 30
tt.reinforcement.fade = nil
tt.render.sprites[1].anchor.y = 0.1
tt.render.sprites[1].prefix = "veznan_demon"
tt.render.sprites[1].name = "raise"
tt.soldier.melee_slot_offset = vec_2(10, 0)
tt.sound_events.death = "ElvesHeroVeznanDemonDeath"
tt.ui.click_rect = r(-10, 0, 20, 30)
tt.unit.hit_offset = vec_2(0, 30)
tt.unit.mod_offset = vec_2(0, 28)
tt.unit.hide_after_death = true
tt.vis.flags = bor(tt.vis.flags, F_HERO)
tt.vis.bans = bor(F_POISON, F_NET, F_STUN, F_BURN)

tt = RT("mod_veznan_demon_fire", "modifier")
AC(tt, "render")
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = fts(29)
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].draw_order = 10

tt = RT("mod_arivan_freeze", "mod_freeze")
AC(tt, "render", "tween")
tt.modifier.duration = nil
tt.modifier.vis_bans = F_BOSS
tt.render.sprites[1].name = "arivan_hero_freeze_decal"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{"this.modifier.duration-0.5", 255}, {"this.modifier.duration", 0}}

tt = RT("mod_arivan_ultimate_freeze", "mod_arivan_freeze")

tt = RT("soldier_bravebark", "soldier_militia")
AC(tt, "reinforcement")
image_y = 58
anchor_y = 12 / image_y
tt.health_bar.offset = vec_2(0, 44)
tt.health_bar.size = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr3_info_portraits_soldiers_0003"
tt.info.random_name_format = nil
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(6)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.cooldown = 1
tt.regen.health = 0
tt.reinforcement.duration = 20
tt.reinforcement.fade = nil
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "bravebark_mignon"
tt.render.sprites[1].name = "raise"
tt.soldier.melee_slot_offset = vec_2(4, 0)
tt.unit.mod_offset = vec_2(0, 15)
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)

tt = RT("soldier_xin_shadow", "soldier")
AC(tt, "melee")
image_y = 64
anchor_y = 12 / image_y
tt.health.hp_max = 50
tt.health.ignore_damage = true
tt.health_bar.hidden = true
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
tt.ui.can_click = false
tt.ui.can_select = false
tt.unit.mod_offset = vec_2(0, 15)
tt.vis.bans = bor(F_ALL)
tt.melee.attacks[1].damage_max = 12
tt.melee.attacks[1].damage_min = 4
tt.melee.attacks[1].hit_time = fts(4)
tt.melee.attacks[1].shared_cooldown = true
for i = 2, 4 do
	local a = table.deepclone(tt.melee.attacks[1])

	a.animation = "attack" .. i
	a.chance = 1 / i
	tt.melee.attacks[i] = a
end
tt.melee.cooldown = fts(15)
tt.melee.range = 60

tt = RT("soldier_xin_ultimate", "soldier_xin_shadow")
tt.max_attack_count = 2

for i = 1, 4 do
	tt.melee.attacks[i].damage_type = DAMAGE_TRUE
	tt.melee.attacks[i].sound = "ElvesHeroXinPandamoniumHit"
end

tt.sound_events.insert = "ElvesHeroXinAfterTeleportIn"
tt.sound_events.death = "ElvesHeroXinAfterTeleportOut"

tt = RT("aura_rabbit_kamihare", "aura")
tt.aura.cycles = 1
tt.aura.damage_min = 35
tt.aura.damage_max = 45
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.radius = 40
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.vis_flags = bor(F_RANGED)
tt.main_script.update = scripts.aura_apply_damage.update

tt = RT("bullet_rag_throw", "arrow")
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.flight_time = fts(12)
tt.bullet.miss_decal = nil
tt.bullet.miss_fx_water = nil
tt.bullet.pop = nil
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

tt = RT("soldier_rag", "soldier_militia")
AC(tt, "reinforcement")
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 37)
tt.health_bar.size = HEALTH_BAR_SIZE_SMALL
tt.health.damage_factor = 1.5
tt.info.portrait = "kr3_info_portraits_soldiers_0009"
tt.info.random_name_format = nil
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.melee.attacks[1].damage_max = 50
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.cooldown = 0.5
tt.motion.max_speed = 60
tt.regen.cooldown = 100
tt.regen.health = 0
tt.reinforcement.duration = 1200
tt.reinforcement.fade = nil
tt.render.sprites[1].anchor.y = 0.22
tt.render.sprites[1].prefix = "rag_polymorphed"
tt.render.sprites[1].name = "idle"
tt.soldier.melee_slot_offset = vec_2(4, 0)
tt.unit.mod_offset = vec_2(0, 15)
tt.unit.hide_after_death = true
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)

tt = RT("soldier_hero_space_elf_astral_reflection", "soldier_militia")
AC(tt, "ranged", "reinforcement", "tween", "transfer")
tt.info.enc_icon = 12
tt.info.portrait = "kr5_info_portraits_soldiers_0037"
tt.info.random_name_format = nil
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.render.sprites[1].prefix = "hero_therien_reflection"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].angles.walk = {"ability3"}
tt.unit.hit_offset = vec_2(0, 16)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = vec_2(0, 38)
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_hero_space_elf_astral_reflection.update
tt.idle_flip.last_animation = "idle"
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE)
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.tween.disabled = true
tt.melee.range = 50
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF, F_WATER)
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].animation = "ability1"
tt.melee.attacks[1].hit_fx = "fx_hero_space_elf_melee_hit"
tt.melee.attacks[1].hit_offset = vec_2(27, 15)
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "ability2"
tt.ranged.attacks[1].bullet = "bolt_hero_space_elf_basic_attack"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(-9, 42), vec_2(9, 42)}
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].max_range = 160
tt.ranged.attacks[1].min_range = 68
tt.ranged.attacks[1].shoot_time = fts(10)
tt.ranged.attacks[1].xp_gain_factor = 1.6
tt.reinforcement.duration = 12
tt.reinforcement.fade = nil
tt.ui.click_rect = r(-20, -5, 40, 50)
tt.health.dead_lifetime = fts(15)
tt.spawn_fx = "fx_hero_space_elf_astral_reflection_spawn"

tt = RT("soldier_hero_space_elf_astral_reflection_1", "soldier_hero_space_elf_astral_reflection")
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].damage_max = 15
tt.ranged.attacks[1].damage_min = 19
tt.ranged.attacks[1].damage_max = 36
tt.health.hp_max = 247

tt = RT("soldier_hero_space_elf_astral_reflection_2", "soldier_hero_space_elf_astral_reflection")
tt.melee.attacks[1].damage_min = 14
tt.melee.attacks[1].damage_max = 20
tt.ranged.attacks[1].damage_min = 26
tt.ranged.attacks[1].damage_max = 47
tt.health.hp_max = 286

tt = RT("soldier_hero_space_elf_astral_reflection_3", "soldier_hero_space_elf_astral_reflection")
tt.melee.attacks[1].damage_min = 19
tt.melee.attacks[1].damage_max = 31
tt.ranged.attacks[1].damage_min = 33
tt.ranged.attacks[1].damage_max = 62
tt.health.hp_max = 325

tt = RT("bolt_hero_space_elf_basic_attack", "bolt")
tt.render.sprites[1].prefix = "hero_therien_ranged_proyectile"
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.acceleration_factor = 0.1
tt.bullet.align_with_trajectory = true
tt.bullet.hit_fx = "fx_hero_space_elf_ranged_hit"
tt.bullet.xp_gain_factor = 1.6
tt.sound_events.insert = "EnemyTurtleShamanBasicAttack"
tt.bullet.particles_name = "ps_hero_space_elf_basic_attack_trail"
tt.bullet.mod = "mod_hero_space_elf_bolt"

tt = RT("mod_hero_space_elf_bolt", "modifier")
tt.received_damage_factor = 1.1
tt.modifier.duration = 4
tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.remove = scripts.mod_damage_factors.remove
tt.main_script.update = scripts.mod_track_target.update

tt = RT("hero_raelyn_ultimate_entity", "soldier_militia")
AC(tt, "nav_grid", "reinforcement", "tween")
tt.controable = true
tt.controable_other = true
tt.health_bar.offset = vec_2(0, 50)
tt.info.enc_icon = 12
tt.info.portrait = "kr5_info_portraits_soldiers_0006"
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
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE)
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.tween.disabled = true
tt.spawn_mod_decal = "hero_raelyn_ultimate_entity_spawn_mod_decal"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF, F_WATER)
tt.melee.attacks[1].sound = "CommonNoSwordAttack"
tt.melee.attacks[1].sound_args = {
	delay = fts(8)
}
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].hit_times = {fts(16), fts(28)}
tt.melee.attacks[1].loops = 1
tt.melee.attacks[1].hit_fx = "hero_raelyn_command_orders_hit_fx"
tt.melee.attacks[1].hit_offset = vec_2(30, 20)
tt.melee.attacks[1].animations = {nil, "attack_1"}
tt.melee.attacks[1].shared_cooldown = true
tt.melee.range = 72
tt.reinforcement.duration = 20
tt.reinforcement.fade = nil
tt.ui.click_rect = r(-20, -5, 40, 50)

tt = RT("hero_raelyn_ultimate_entity_1", "hero_raelyn_ultimate_entity")
tt.motion.max_speed = 60

for _, attack in ipairs(tt.melee.attacks) do
	attack.cooldown = 1.5
	attack.damage_max = 15
	attack.damage_min = 10
end

tt.health.hp_max = 156
tt.health.armor = 0.3

tt = RT("hero_raelyn_ultimate_entity_2", "hero_raelyn_ultimate_entity")
tt.motion.max_speed = 60

for _, attack in ipairs(tt.melee.attacks) do
	attack.cooldown = 1.5
	attack.damage_max = 23
	attack.damage_min = 15
end

tt.health.hp_max = 260
tt.health.armor = 0.4

tt = RT("hero_raelyn_ultimate_entity_3", "hero_raelyn_ultimate_entity")
tt.motion.max_speed = 60

for _, attack in ipairs(tt.melee.attacks) do
	attack.cooldown = 1.5
	attack.damage_max = 31
	attack.damage_min = 20
end

tt.health.hp_max = 364
tt.health.armor = 0.55

tt = RT("hero_raelyn_ultimate_entity_4", "hero_raelyn_ultimate_entity")
tt.motion.max_speed = 60

for _, attack in ipairs(tt.melee.attacks) do
	attack.cooldown = 1.5
	attack.damage_max = 44
	attack.damage_min = 28
end

tt.health.hp_max = 468
tt.health.armor = 0.7

tt = RT("enemy_pumpkin_witch", "enemy")
tt.main_script.update = scripts.enemy_passive.update
tt.health.armor = 0
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, 32)
tt.info.enc_icon = 127
tt.info.portrait = "kr5_info_portraits_enemies_0050"
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.head_offset = vec_2(0, 5)
tt.unit.mod_offset = vec_2(0, 10)
tt.motion.max_speed = 20
tt.render.sprites[1].prefix = "hero_witch_pumpkling"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.render.sprites[1].scale = vec_1(1)
tt.sound_events.death = "EnemyPumpkinDeath"
tt.ui.click_rect = r(-17, 0, 34, 20)
tt.vis.flags = bor(F_ENEMY, F_POLYMORPH)
tt.vis.bans = bor(F_BLOCK, F_SKELETON)

tt = RT("enemy_pumpkin_witch_flying", "enemy_pumpkin_witch")
tt.info.portrait = "kr5_info_portraits_enemies_0049"
tt.flight_height = 47
tt.health_bar.offset = vec_2(0, tt.flight_height + 40)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.render.sprites[1].prefix = "hero_witch_pumpkling_flying"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.render.sprites[1].offset = vec_2(0, tt.flight_height)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].scale = vec_1(0.8)
tt.unit.hide_after_death = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = vec_2(0, tt.flight_height + 10)
tt.unit.mod_offset = vec_2(0, tt.flight_height + 10)
tt.unit.show_blood_pool = false
tt.sound_events.death = "EnemySheepDeath"
tt.ui.click_rect = r(-18, tt.flight_height - 2, 36, 23)
tt.vis.flags = bor(F_ENEMY, F_FLYING, F_POLYMORPH)

-- 光龙
tt = RT("ps_bolt_lumenir")
AC(tt, "pos", "particle_system")
tt.particle_system.name = "hero_lumenir_attack_projectile_trail_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(12), fts(12)}
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi / 2
tt.particle_system.z = Z_FLYING_HEROES

tt = RT("ps_bolt_lumenir_wave")
AC(tt, "pos", "particle_system")
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

tt = RT("ps_bolt_lance_lumenir")
AC(tt, "pos", "particle_system")
tt.particle_system.name = "bolt_lance_lumenir_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 90
tt.particle_system.emit_rotation_spread = math.pi

tt = RT("ps_soul_soldier_tower_ghost")
AC(tt, "pos", "particle_system")
tt.particle_system.name = "ghost_tower_soul_skill_projectile_particle_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(13), fts(13)}
tt.particle_system.emission_rate = 60
tt.particle_system.emit_rotation_spread = math.pi

tt = RT("ps_bullet_liquid_fire_lumenir")
AC(tt, "pos", "particle_system")
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
tt.particle_system.spin = {-math.pi / 2, math.pi / 2}
tt.particle_system.sort_y_offsets = {-100, 0}

tt = RT("ps_minidragon_lumenir_fire", "ps_bullet_liquid_fire_lumenir")
tt.particle_system.emit_duration = nil
tt.particle_system.emit_speed = {500, 500}
tt.particle_system.emit_rotation_spread = math.pi / 8

tt = RT("ps_hero_lumenir_fire_ball")
AC(tt, "pos", "particle_system")
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
tt.particle_system.emit_spread = math.pi
tt.particle_system.emission_rate = 30

tt = RT("fx_bolt_lumenir_hit", "fx")
tt.render.sprites[1].name = "hero_lumenir_attack_hit_fx_air"

tt = RT("fx_bolt_lumenir_hit_mini", "fx")
tt.render.sprites[1].name = "hero_lumenir_light_companion_attack_fx_idle"

tt = RT("bolt_lumenir", "bullet")
AC(tt, "force_motion")
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.hit_fx = "fx_bolt_lumenir_hit"
tt.bullet.particles_name = "ps_bolt_lumenir"
tt.bullet.max_speed = 600
tt.bullet.align_with_trajectory = true
tt.bullet.min_speed = 30
tt.bullet.xp_gain_factor = 1.46
tt.bullet.pop_chance = 0
tt.initial_impulse = 30000
tt.initial_impulse_duration = 10
tt.initial_impulse_angle = math.pi / 4
tt.force_motion.a_step = 5
tt.force_motion.max_a = 3000
tt.force_motion.max_v = 600
tt.main_script.update = scripts.bolt_lumenir.update
tt.render.sprites[1].name = "hero_lumenir_attack_projectile_idle"
tt.render.sprites[1].z = Z_FLYING_HEROES

tt = RT("bolt_lumenir_wave", "bolt_lumenir")
tt.bullet.hit_fx = "fx_bolt_lumenir_hit_mini"
tt.bullet.particles_name = "ps_bolt_lumenir_wave"
tt.render.sprites[1].name = "hero_lumenir_radiant_wave_projectile_idle"

tt = E:register_t("hero_muyrn_sentinel_wisps_entity_bullet_fx_mod", "mod_track_target_fx")
tt.render.sprites[1].name = "hero_nyru_sentinel_wisps_hit"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hide_after_runs = 1
tt.modifier.duration = fts(11)

tt = E:register_t("hero_muyrn_verdant_blast_bolt_hit_fx", "fx")
tt.render.sprites[1].name = "hero_nyru_verdant_blast_explosion"

tt = E:register_t("decal_hero_dragon_arb_passive_plant_1", "decal_scripted")
E:add_comps(tt, "vis")
tt.main_script.update = scripts.decal_hero_dragon_arb_passive_plant.update
tt.render.sprites[1].prefix = "hero_dragon_arborean_passive_root1"
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "start"
tt.render.sprites[1].hidden = true
tt.vis.bans = bor(F_BLOCK)

tt = E:register_t("decal_hero_dragon_arb_passive_plant_2", "decal_hero_dragon_arb_passive_plant_1")
tt.render.sprites[1].prefix = "hero_dragon_arborean_passive_root2"

tt = E:register_t("decal_hero_dragon_arb_passive_plant_3", "decal_hero_dragon_arb_passive_plant_1")
tt.render.sprites[1].prefix = "hero_dragon_arborean_passive_root3"

tt = RT("fx_hero_builder_demolition_man", "fx")
tt.render.sprites[1].prefix = "hero_obdul_skill_3_fx"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].loop = true

tt = RT("soldier_hero_spider_ultimate", "soldier_militia")
AC(tt, "reinforcement", "nav_grid", "tween")
tt.health.armor = 0
tt.health.hp_max = {150, 150, 150, 150}
tt.health_bar.offset = v(0, 30)
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.info.portrait = "kr5_info_portraits_soldiers_0037" -- TODO: 暂无对应头像（FL: 0057）
tt.info.random_name_format = nil
tt.info.random_name_count = nil
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].mod = "mod_soldier_hero_spider_ultimate_stun"
tt.melee.range = 72
tt.motion.max_speed = 95
tt.regen.health = 0
tt.reinforcement.duration = {5, 7, 8, 10}
tt.render.sprites[1].prefix = "hero_spider_05_spider"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.unit.hit_offset = v(0, 5)
tt.unit.mod_offset = v(0, 14)

tt = RT("mod_soldier_hero_spider_ultimate_stun", "mod_stun")
tt.main_script.insert = scripts.mod_soldier_hero_spider_ultimate_stun.insert
tt.modifier.duration = 3
tt.stun_chance = 0.15
tt.modifier.vis_flags = bor(F_MOD, F_STUN)

-- ======== hero_eiskalt(冰龙) ========

tt = RT("mod_eiskalt_cold", "mod_slow")
tt.modifier.duration = 3
tt.slow.factor = 0.75
tt.main_script.insert = scripts.mod_eiskalt_cold.insert
tt.main_script.remove = scripts.mod_eiskalt_cold.remove
tt.shader = "p_tint"
tt.shader_args = {
	tint_color = {0.6235294117647059, 0.9176470588235294, 1, 1}
}
tt.modifier.vis_bans = bor(tt.modifier.vis_bans, F_BOSS)

tt = RT("hero_beresad_conflagration_particle")
AC(tt, "pos", "particle_system")
tt.particle_system.name = "hero_beresad_conflagration_particle_travel"
tt.particle_system.animated = true
tt.particle_system.emission_rate = 30
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.source_lifetime = fts(20)

-- ======== 伊斯菲特 ========
tt = RT("hero_isfet", "hero")
tt.hero.room_special_order = {"BLACK_CLOUD", "FROG_CURSE", "RAIN", "BLOOD_POOL", "ULTIMATE", "ULTIMATE_2"}
AC(tt, "melee", "ranged", "timed_attacks")
anchor_x, anchor_y = 0.5, 0.12
image_x, image_y = 92, 110
tt.melee.range = 65
tt.health_bar.offset = v(0, 46)
tt.health.dead_lifetime = 15
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.tombstone_show_time = fts(90)
tt.main_script.update = scripts.hero_isfet.update
tt.hero.fn_level_up = scripts.hero_isfet.level_up
tt.info.hero_portrait = "kr4_hero_portraits_0016"
tt.info.portrait = "kr4_info_portraits_heroes_0017"
tt.motion.max_speed = 1.33 * FPS
tt.soldier.melee_slot_offset = v(5, 0)
tt.sound_events.change_rally_point = "group_hero_isfet_taunt"
tt.sound_events.death = "hero_isfet_taunt_death"
tt.sound_events.hero_room_select = "group_hero_isfet_taunt"
tt.sound_events.insert = "group_hero_isfet_taunt"
tt.sound_events.respawn = "HeroLevelUp"
tt.unit.hit_offset = v(0, 18)
tt.unit.mod_offset = v(0, 18)
tt.hero.skills.black_cloud = CC("hero_skill")
tt.hero.skills.black_cloud.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.black_cloud.xp_gain = {50, 100, 150}
tt.hero.skills.black_cloud.damage = {4, 6, 9}
tt.hero.skills.frog_curse = CC("hero_skill")
tt.hero.skills.frog_curse.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.frog_curse.xp_gain = {50, 100, 150}
tt.hero.skills.frog_curse.health_threshold = {510, 1200, 2000}
tt.hero.skills.rain = CC("hero_skill")
tt.hero.skills.rain.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.rain.xp_gain = {50, 100, 150}
tt.hero.skills.rain.count = {4, 7, 10}
tt.hero.skills.blood_pool = CC("hero_skill")
tt.hero.skills.blood_pool.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.blood_pool.xp_gain = {50, 100, 150}
tt.hero.skills.blood_pool.damage_factor = {1.25, 1.5, 1.75}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.xp_gain = {160, 320, 480}
tt.hero.skills.ultimate.controller_name = "controller_hero_isfet_ultimate"
tt.hero.skills.ultimate.cooldown = {48, 48, 48, 48}
tt.hero.skills.ultimate.damage = {4, 6, 12, 20}
tt.isfet_necromancy = {
	range = 300,
	chance = 0.5,
	max_units = 2,
	cycle_time = 0.1,
	entity = "hero_isfet_mummy"
}
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {204, 228, 252, 276, 300, 324, 348, 372, 396, 420}
tt.hero.level_stats.melee_damage_max = {7, 8, 9, 11, 13, 14, 15, 16, 18, 20}
tt.hero.level_stats.melee_damage_min = {4, 5, 6, 7, 8, 9, 10, 12, 12, 13}
tt.hero.level_stats.ranged_damage_max = {22, 26, 31, 35, 39, 44, 48, 53, 58, 62}
tt.hero.level_stats.ranged_damage_min = {12, 14, 16, 19, 21, 24, 26, 29, 31, 33}
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(0.5, 0.28)
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_isfet"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].offset = v(0, 20)
tt.render.sprites[2].name = "hero_isfet_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 1
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].max_range = 175
tt.ranged.attacks[1].animation = "rangedAttack"
tt.ranged.attacks[1].bullet = "bolt_isfet"
tt.ranged.attacks[1].shoot_time = fts(32)
tt.ranged.attacks[1].sound_shoot = "ember_lords_mage_attack"
tt.ranged.attacks[1].bullet_start_offset = {v(-12, 44)}
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "specialCloud"
tt.timed_attacks.list[1].cooldown = 45
tt.timed_attacks.list[1].cast_time = fts(17)
tt.timed_attacks.list[1].trigger_range = 300
tt.timed_attacks.list[1].min_targets = 2
tt.timed_attacks.list[1].entity = "aura_isfet_locust_swarm"
tt.timed_attacks.list[1].sound = "hero_isfet_blackcloud"
tt.timed_attacks.list[1].sound_delay = 0.23
tt.timed_attacks.list[1].spawn_offset = v(45, 35)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].vis_bans = F_FLYING
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].animation = "specialFrog"
tt.timed_attacks.list[2].cooldown = 35
tt.timed_attacks.list[2].cast_time = fts(17)
tt.timed_attacks.list[2].min_range = 150
tt.timed_attacks.list[2].max_range = 330
tt.timed_attacks.list[2].projectile = "projectile_isfet_frog_curse"
tt.timed_attacks.list[2].sound = "hero_isfet_polymorph_spell"
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED, F_INSTAKILL)
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING, F_BOSS)
tt.timed_attacks.list[3] = CC("mod_attack")
tt.timed_attacks.list[3].animation_in = "specialFirestormIn"
tt.timed_attacks.list[3].animation_loop = "specialFirestormLoop"
tt.timed_attacks.list[3].animation_out = "specialFirestormOut"
tt.timed_attacks.list[3].cooldown = 70
tt.timed_attacks.list[3].range = 120
tt.timed_attacks.list[3].loop_duration = 1.5
tt.timed_attacks.list[3].entity = "controller_isfet_fire_ice_rain"
tt.timed_attacks.list[3].sound = "hero_isfet_fireice_cast"
tt.timed_attacks.list[3].sound_delay = 0.26
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].vis_flags = F_RANGED
tt.timed_attacks.list[3].vis_bans = F_FLYING
tt.timed_attacks.list[4] = CC("mod_attack")
tt.timed_attacks.list[4].animation = "specialBlood"
tt.timed_attacks.list[4].cooldown = 20
tt.timed_attacks.list[4].cast_time = fts(7)
tt.timed_attacks.list[4].min_range = 60
tt.timed_attacks.list[4].max_range = 175
tt.timed_attacks.list[4].crowd_range = 100
tt.timed_attacks.list[4].min_targets = 2
tt.timed_attacks.list[4].entity = "aura_isfet_blood_pool"
tt.timed_attacks.list[4].sound = "hero_mortemis_rotten"
tt.timed_attacks.list[4].sound_delay = 0.32
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].vis_flags = F_RANGED
tt.timed_attacks.list[4].vis_bans = F_FLYING
tt.ultimate = {
	ts = 0,
	cooldown = 48,
	disabled = true
}
tt.hero.skills.ultimate.cooldown = tt.ultimate.cooldown

tt = RT("bolt_isfet", "bolt")
AC(tt, "force_motion")
tt.render.sprites[1].prefix = "hero_isfet_bolt"
tt.height_attack = 70
tt.initial_vel_y = 50
tt.transition_time = 1
tt.target_distance_detection = 20
tt.main_script.update = scripts.hero_isfet_bolt.update
tt.bullet.damage_max = 10
tt.bullet.damage_min = 10
tt.bullet.acceleration_factor = 0.3
tt.bullet.hit_fx = "hero_isfet_bolt_hit"
tt.bullet.particles_name = "ps_hero_isfet_bolt_trail"
tt.bullet.max_speed = 1800
tt.bullet.min_speed = 150
tt.initial_impulse = 9000
tt.initial_impulse_duration = 0.1
tt.initial_impulse_angle = math.pi / 2
tt.force_motion.max_a = 1800
tt.force_motion.max_v = 450
tt.sound_events.insert = nil

tt = RT("hero_isfet_bolt_hit", "fx")
tt.render.sprites[1].name = "hero_isfet_bolt_hit"

tt = RT("ps_hero_isfet_bolt_trail")
AC(tt, "pos", "particle_system")
tt.particle_system.name = "hero_isfet_bolt_particle"
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 45
tt.particle_system.emit_area_spread = v(8, 8)
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.scales_y = {1, 1.5}
tt.particle_system.scales_x = {1, 1.5}

tt = RT("aura_isfet_necromancy")
AC(tt, "pos", "main_script")
tt.main_script.update = scripts.aura_isfet_necromancy.update

tt = RT("hero_isfet_mummy", "soldier_militia")
AC(tt, "nav_path")
tt.main_script.update = scripts.hero_isfet_mummy.update
tt.health.hp_max = 180
tt.health.dead_lifetime = 0
tt.health_bar.offset = v(0, 32)
tt.info.portrait = "kr4_info_portraits_soldiers_0011"
tt.lifetime = 50
tt.motion.max_speed = 20
tt.nav_path.dir = -1
tt.render.sprites[1].anchor = v(0.5, 0.065)
tt.render.sprites[1].prefix = "hero_isfet_mummy"
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk", "walkUp", "walkDown"}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_isfet_mummy_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.melee.range = 60
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = 8
tt.melee.attacks[1].damage_max = 12
tt.melee.attacks[1].animation = "melee"
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.ui.can_click = false
tt.unit.hit_offset = v(0, 11)
tt.unit.mod_offset = v(0, 12)
tt.spawn_sound = "group_party_sarcophagus_mummy_moan"
tt.spawn_sound_delay = 0.2

tt = RT("aura_isfet_locust_swarm", "aura")
AC(tt, "nav_path", "motion", "render")
tt.main_script.update = scripts.aura_isfet_locust_swarm.update
tt.aura.duration = 7
tt.infection_aura = "aura_isfet_locust_infection"
tt.motion.max_speed = 30
tt.nav_path.dir = -1
tt.render.sprites[1].prefix = "hero_isfet_cloud"
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].offset = v(0, 20)
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].z = Z_FLYING_HEROES

tt = RT("aura_isfet_locust_infection", "aura")
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.duration = 7
tt.aura.cycle_time = 0.1
tt.aura.radius = 110
tt.aura.track_source = true
tt.aura.mods = {"mod_isfet_locust_damage", "mod_isfet_locust_silence"}
tt.aura.vis_flags = bor(F_RANGED, F_MOD)
tt.aura.vis_bans = bor(F_FRIEND)

tt = RT("mod_isfet_locust_damage", "modifier")
AC(tt, "dps")
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.modifier.duration = 5
tt.modifier.vis_flags = F_MOD
tt.dps.damage_min = 4
tt.dps.damage_max = 4
tt.dps.damage_every = 0.25
tt.dps.damage_type = DAMAGE_EXPLOSION

tt = RT("mod_isfet_locust_silence", "modifier")
AC(tt, "render")
tt.main_script.insert = scripts.mod_silence.insert
tt.main_script.remove = scripts.mod_silence.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = 5
tt.modifier.vis_flags = F_MOD
tt.render.sprites[1].prefix = "hero_isfet_cloud_modifier"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].draw_order = 2

tt = RT("projectile_isfet_frog_curse")
AC(tt, "pos", "main_script", "render")
tt.main_script.update = scripts.projectile_isfet_frog_curse.update
tt.duration = 0.6
tt.sound_hit = "hero_isfet_polymorph_spell_impact"
tt.sound_frog = "hero_isfet_polymorph_spell_frog"
tt.render.sprites[1].prefix = "hero_isfet_frog_ray"
tt.render.sprites[1].name = "travel"
tt.render.sprites[1].z = Z_BULLETS

tt = RT("fx_isfet_frog_smoke", "fx")
tt.render.sprites[1].prefix = "hero_isfet_frog_smoke"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].anchor = v(0.5, 0.34)
tt.render.sprites[1].offset = v(0, 2)

tt = RT("decal_isfet_frog")
AC(tt, "pos", "main_script", "render")
tt.main_script.update = scripts.decal_isfet_frog.update
tt.lifetime = 6
tt.render.sprites[1].prefix = "hero_isfet_frog"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor = v(0.5, 0.11)
tt.render.sprites[1].z = Z_DECALS + 1

tt = RT("controller_isfet_fire_ice_rain")
AC(tt, "pos", "main_script")
tt.main_script.update = scripts.controller_isfet_fire_ice_rain.update
tt.spawn_delay = 0.2
tt.radius = 60
tt.projectiles = {"projectile_isfet_rain_fire", "projectile_isfet_rain_ice"}
tt.scale_min = 0.65
tt.scale_max = 0.8

tt = RT("projectile_isfet_rain")
AC(tt, "pos", "main_script", "render")
tt.main_script.update = scripts.projectile_isfet_rain.update
tt.flight_time = 0.25
tt.damage = 60
tt.damage_radius = 30
tt.damage_type = DAMAGE_TRUE
tt.vis_flags = F_RANGED
tt.vis_bans = F_FLYING

tt = RT("projectile_isfet_rain_fire", "projectile_isfet_rain")
tt.kind = "fire"
tt.mod = "mod_isfet_rain_burn"
tt.hit_fx = "fx_isfet_rain_fire"
tt.release_sound = "group_hero_isfet_fire_proyectil"
tt.hit_sound = "bomb_hit_sound"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "hero_isfet_fireice_fire_proy"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].flip_x = true

tt = RT("projectile_isfet_rain_ice", "projectile_isfet_rain")
tt.kind = "ice"
tt.mod = "mod_isfet_rain_freeze"
tt.hit_fx = "fx_isfet_rain_ice"
tt.release_sound = "group_hero_isfet_ice_proyectile"
tt.hit_sound = "bomb_hit_sound"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "hero_isfet_fireice_ice_proy"
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].flip_x = true

tt = RT("fx_isfet_rain_fire", "fx")
tt.render.sprites[1].prefix = "hero_isfet_fireice_fire_explotion"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].anchor = v(0.5, 0.341)
tt.render.sprites[1].offset = v(0, 3)

tt = RT("fx_isfet_rain_ice", "fx")
tt.render.sprites[1].prefix = "hero_isfet_fireice_ice_explotion"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].anchor = v(0.5, 0.341)
tt.render.sprites[1].offset = v(0, 3)

tt = RT("mod_isfet_rain_burn", "modifier")
AC(tt, "dps")
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.modifier.duration = 8
tt.modifier.vis_flags = F_MOD
tt.dps.damage_min = 3
tt.dps.damage_max = 3
tt.dps.damage_every = 0.2
tt.dps.damage_type = DAMAGE_TRUE

tt = RT("mod_isfet_rain_freeze", "mod_freeze")
tt.modifier.duration = 8
tt.modifier.vis_bans = F_BOSS

tt = RT("aura_isfet_blood_pool", "aura")
AC(tt, "render")
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.duration = 6
tt.aura.cycle_time = 0.2
tt.aura.radius = 75
tt.aura.mod = "mod_isfet_blood_vulnerability"
tt.aura.vis_flags = F_MOD
tt.aura.vis_bans = bor(F_FRIEND)
tt.sound = "hero_isfet_bloodpool"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "hero_isfet_blood_decal"
tt.render.sprites[1].z = Z_DECALS
for i, offset in ipairs({v(12, 16), v(13, 0), v(-15, 17), v(-10, 1)}) do
	tt.render.sprites[i + 1] = CC("sprite")
	tt.render.sprites[i + 1].prefix = "hero_isfet_blood_bubble"
	tt.render.sprites[i + 1].name = "run"
	tt.render.sprites[i + 1].loop = true
	tt.render.sprites[i + 1].anchor = v(0.5, 0)
	tt.render.sprites[i + 1].offset = offset
end

tt = RT("mod_isfet_blood_vulnerability", "modifier")
AC(tt, "render")
tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.remove = scripts.mod_damage_factors.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = 6
tt.modifier.vis_flags = F_MOD
tt.received_damage_factor = 1.25
tt.render.sprites[1].prefix = "hero_isfet_blood_modifier"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].draw_order = 2

tt = RT("controller_hero_isfet_ultimate")
AC(tt, "pos", "main_script", "render")
tt.main_script.update = scripts.controller_hero_isfet_ultimate.update
tt.cloud_radius = 120
tt.damage_radius = 80
tt.damage = {4, 6, 12, 20}
tt.duration = 4
tt.tick_time = 0.2
tt.cooldown = 48
tt.damage_type = DAMAGE_TRUE
tt.damage_flags = F_RANGED
tt.damage_bans = F_FLYING
tt.slow_aura = "aura_isfet_ultimate_slow"
tt.sound = "hero_isfet_ultimate"
tt.lightning_fx = "fx_isfet_ultimate_lightning"
tt.lightning_hit_fx = "fx_isfet_ultimate_lightning_hit"
tt.lightning_origin_y = 90
tt.lightning_destination_y = -8
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].prefix = "hero_isfet_storm_clouds"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].anchor = v(0.5, 0.14)
tt.render.sprites[1].offset = v(0, 100)
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_isfet_storm_shadow"
tt.render.sprites[2].z = Z_DECALS

tt = RT("aura_isfet_ultimate_slow", "aura")
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.duration = 4
tt.aura.cycle_time = 0.2
tt.aura.radius = 120
tt.aura.track_source = true
tt.aura.mod = "mod_isfet_ultimate_slow"
tt.aura.vis_flags = bor(F_RANGED, F_MOD)
tt.aura.vis_bans = F_FLYING

tt = RT("mod_isfet_ultimate_slow", "mod_slow")
tt.modifier.duration = 0.25
tt.slow.factor = 0.4

tt = RT("fx_isfet_ultimate_lightning", "fx")
tt.render.sprites[1].prefix = "hero_isfet_storm_lightning"
tt.render.sprites[1].name = "travel"
tt.render.sprites[1].z = Z_BULLETS

tt = RT("fx_isfet_ultimate_lightning_hit", "fx")
tt.render.sprites[1].prefix = "hero_isfet_storm_lightning_hit"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].z = Z_BULLETS

-- ======== 奥洛克 ========

tt = RT("aura_bomb_tramin_ultimate", "aura_rabbit_kamihare")
tt.aura.damage_min = 110
tt.aura.damage_max = 155
tt.aura.radius = 30
tt.aura.damage_type = DAMAGE_EXPLOSION
tt.sound_events.insert = "BombExplosionSound"

-- ======== 银橡村关卡自带英雄（KR6 level05 stage hero）========
tt = RT("hero_stage_205_alleria", "stage_hero")
AC(tt, "melee", "ranged", "timed_attacks")
tt.hero.respawn_animation = "in"
tt.hero.stage_hero = true
tt.hero.stage_hero_w_portrait = true
tt.health.armor = 0
tt.health.dead_lifetime = 15
tt.health.hp_max = 160
tt.health_bar.offset = v(0, 39)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.hero_portrait = "kr6_hero_portraits_0002"
tt.info.portrait = "kr6_info_portraits_heroes_0002"
tt.info.i18n_key = "HERO_ALLERIA"
tt.main_script.insert = scripts.hero_stage_205_alleria.insert
tt.main_script.update = scripts.hero_stage_205_alleria.update
tt.motion.max_speed = 70
tt.regen.cooldown = 1
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].angles.ranged = {"attack_1"}
tt.render.sprites[1].prefix = "Alleria_hero"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].draw_order = DO_HEROES
tt.sound_events.change_rally_point = "Stage05AlleriaSwiftwindTaunt"
tt.sound_events.death = "Stage05AlleriaSwiftwindDeath"
tt.sound_events.respawn = "Stage05AlleriaSwiftwindTaunt"
tt.soldier.melee_slot_offset.x = 5
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, -1)
tt.unit.mod_offset = v(0, 19.9)
tt.unit.hide_after_death = true
tt.melee.attacks[1].animation = "attack_melee"
tt.melee.attacks[1].damage_min = 8
tt.melee.attacks[1].damage_max = 13
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].hit_fx = "fx_alleria_hit"
tt.melee.attacks[1].hit_offset = v(30, 20)
tt.melee.attacks[1].basic_attack = true
tt.melee.cooldown = 1
tt.melee.range = 40
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].bullet = "bullet_alleria"
tt.ranged.attacks[1].bullet_start_offset = {v(8, 35)}
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].min_range = 70
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].shoot_time = fts(10)
tt.ranged.attacks[1].shared_cooldown = true
tt.ranged.attacks[1].chance = 1
tt.ranged.attacks[1].node_prediction = fts(8) + fts(15)
tt.ranged.attacks[1].basic_attack = true
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animations = {"skill_1_in", "skill_1_loop", "skill_1_out"}
tt.timed_attacks.list[1].shots = 3
tt.timed_attacks.list[1].bullet = "bullet_alleria_multishot"
tt.timed_attacks.list[1].bullet_start_offset = v(8, 35)
tt.timed_attacks.list[1].cooldown = 20
tt.timed_attacks.list[1].min_range = 100
tt.timed_attacks.list[1].max_range = 200
tt.timed_attacks.list[1].min_targets = 3
tt.timed_attacks.list[1].shoot_time = fts(4)
tt.timed_attacks.list[1].sound = "Stage05AlleriaMultishotCast"
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animation = "skill_2"
tt.timed_attacks.list[2].entity = "soldier_alleria_cat"
tt.timed_attacks.list[2].cooldown = 28
tt.timed_attacks.list[2].min_targets = 2
tt.timed_attacks.list[2].range_check = 150
tt.timed_attacks.list[2].cast_time = fts(6)
tt.timed_attacks.list[2].spawn_offset = v(10, -10)
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[2].sound = "Stage05AlleriaSummonCast"
tt.ui.click_rect = r(-15, 0, 30, 35)

-- 弹道
tt = RT("bullet_alleria", "arrow5_fixed_height")
tt.render.sprites[1].name = "Alleria_arrow"
tt.bullet.fixed_height = 40
tt.bullet.g = -1000
tt.bullet.hit_blood_fx = nil
tt.bullet.pop = {"pop_archer"}
tt.bullet.hide_radius = 1
tt.bullet.prediction_error = false
tt.bullet.predict_target_pos = false
tt.bullet.miss_decal = nil
tt.bullet.miss_fx = "decal_alleria_miss"
tt.bullet.hit_fx = "fx_alleria_hit"
tt.bullet.damage_min = 8
tt.bullet.damage_max = 13
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.particles_name = "ps_bullet_alleria"

tt = RT("bullet_alleria_multishot", "arrow5_fixed_height")
tt.render.sprites[1].name = "Alleria_skill_1_arrow"
tt.bullet.fixed_height = 40
tt.bullet.g = -1000
tt.bullet.hit_blood_fx = nil
tt.bullet.pop = {"pop_archer"}
tt.bullet.hide_radius = 0
tt.bullet.prediction_error = false
tt.bullet.predict_target_pos = true
tt.bullet.miss_decal = nil
tt.bullet.miss_fx = "decal_alleria_miss_multishot"
tt.bullet.hit_fx = "fx_alleria_hit_multishot"
tt.bullet.damage_min = 8
tt.bullet.damage_max = 14
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.particles_name = "ps_bullet_alleria_multishot"

-- 特效
tt = RT("fx_alleria_hit", "fx")
tt.render.sprites[1].prefix = "Alleria_arrow_hit"
tt.render.sprites[1].name = "hit"

tt = RT("fx_alleria_hit_multishot", "fx")
tt.render.sprites[1].prefix = "Alleria_skill_1_arrow_hit"
tt.render.sprites[1].name = "hit"

tt = RT("fx_alleria_cat_hit", "fx")
tt.render.sprites[1].prefix = "Alleria_cat_hit"
tt.render.sprites[1].name = "hit"

-- 落空 decal
tt = RT("decal_alleria_miss", "decal_tween")
tt.render.sprites[1].prefix = "Alleria_arrow_decal"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.tween.props[1].keys = {{0, 255}, {2, 255}, {4, 0}}

tt = RT("decal_alleria_miss_multishot", "decal_alleria_miss")
tt.render.sprites[1].prefix = "Alleria_skill_1_arrow_decal"

-- 粒子
tt = RT("ps_bullet_alleria", "particle_system")
tt.particle_system.name = "Alleria_arrow_particle_hit"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(12), fts(12)}
tt.particle_system.emission_rate = 60

tt = RT("ps_bullet_alleria_multishot", "particle_system")
tt.particle_system.name = "Alleria_skill_1_arrow_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(13), fts(13)}
tt.particle_system.emission_rate = 60

-- 猞猁召唤物
tt = RT("soldier_alleria_cat", "soldier_militia")
AC(tt, "reinforcement", "tween")
tt.info.portrait = "kr6_info_portraits_soldiers_0015"
tt.info.i18n_key = "SOLDIER_ALLERIA_CAT"
tt.info.random_name_format = nil
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.render.sprites[1].prefix = "Alleria_cat"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.unit.hit_offset = v(0, 10)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 10)
tt.health.hp_max = 80
tt.health.armor = 0
tt.health_bar.offset = v(0, 23)
tt.health.dead_lifetime = 12
tt.regen.health = 6
tt.motion.max_speed = 80
tt.melee.range = 150
tt.vis.flags = bor(F_BLOCK, F_FRIEND)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = 6
tt.melee.attacks[1].damage_max = 9
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].hit_fx = "fx_alleria_cat_hit"
tt.melee.attacks[1].hit_offset = v(23, 8)
tt.soldier.melee_slot_offset = v(4, 0)
tt.reinforcement.duration = 15
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.tween.reverse = false
tt.ui.click_rect = r(-13, -2, 26, 20)

-- ======== KR6 level215 特殊关卡英雄 Lord Blackburn ========
tt = RT("fx_stage_215_lord_blackburn_hit_01", "fx")
tt.render.sprites[1].prefix = "BB_hit_01Def"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true

tt = RT("fx_stage_215_lord_blackburn_hit_02", "fx")
tt.render.sprites[1].prefix = "BB_hit_02Def"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true

tt = RT("decal_stage_215_lord_blackburn_corrupt_level_1_idle", "decal")
AC(tt, "editor")
tt.render.sprites[1].prefix = "BB_V1Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].flip_x = true

tt = RT("decal_stage_215_lord_blackburn_corrupt_level_3_idle", "decal_stage_215_lord_blackburn_corrupt_level_1_idle")
tt.render.sprites[1].prefix = "BB_V3Def"

tt = RT("decal_stage_215_lord_blackburn_tombstone_lvl1", "decal")
tt.render.sprites[1].prefix = "BB_V1Def"
tt.render.sprites[1].name = "deathloop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].scale = vv(1)

tt = RT("decal_stage_215_lord_blackburn_tombstone_lvl2", "decal_stage_215_lord_blackburn_tombstone_lvl1")
tt.render.sprites[1].prefix = "BB_V2Def"

tt = RT("decal_stage_215_lord_blackburn_tombstone_lvl3", "decal_stage_215_lord_blackburn_tombstone_lvl1")
tt.render.sprites[1].prefix = "BB_V3Def"

tt = RT("decal_stage_215_lord_blackburn_death_explosion", "decal_timed")
AC(tt, "sound_events")
tt.render.sprites[1].prefix = "BB_explosionDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -10
tt.render.sprites[1].scale = vv(1.1)
tt.timed.runs = 1

tt = RT("decal_stage_215_lord_blackburn_explosion_ground", "decal_timed")
tt.render.sprites[1].prefix = "BB_decalDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].sort_y_offset = -10
tt.render.sprites[1].scale = vv(1.1)
tt.timed.runs = 1

tt = RT("decal_stage_215_lord_blackburn_ray", "decal_scripted")
tt.render.sprites[1].prefix = "BB_rayDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BULLETS
tt.main_script.update = scripts.stage_215_lord_blackburn_ray.update
tt.decal_explosion_ground = "decal_stage_215_lord_blackburn_explosion_ground"
tt.hit_time = fts(3)
tt.aura = "aura_stage_215_lord_blackburn"

tt = RT("aura_stage_215_lord_blackburn", "aura")
tt.aura.radius = 120
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = 0
tt.aura.cycles = 1
tt.aura.cycle_time = 0
tt.aura.duration = 1e+99
tt.aura.damage_min = 1e+99
tt.aura.damage_max = 1e+99
tt.aura.damage_type = DAMAGE_NO_SPAWNS
tt.aura.excluded_templates = {"enemy_boss_stage_215"}
tt.main_script.update = scripts.aura_apply_damage.update

tt = RT("mod_stage_215_black_burn_mind_control", "modifier")
tt.modifier.duration = 1e+99
tt.modifier.speed_factor = 2
tt.main_script.insert = scripts.mod_stage_215_black_burn_mind_control.insert
tt.main_script.remove = scripts.mod_stage_215_black_burn_mind_control.remove

tt = RT("hero_stage_215_lord_blackburn", "stage_hero")
AC(tt, "melee")
tt.hero.respawn_animation = "deathout"
tt.health.armor = 0.3
tt.health.dead_lifetime = 18
tt.health.hp_max = 450
tt.health_bar.offset = v(0, 60)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.hero.stage_hero = true
tt.hero.stage_hero_w_portrait = true
tt.hero.tombstone_show_time = fts(18)
tt.hero.tombstone_decal = "decal_stage_215_lord_blackburn_tombstone_lvl1"
tt.hero.tombstone_concurrent_with_death = true
tt.hero.remove_tombstone_before_respawn = true
tt.idle_flip.chance = 0.4
tt.idle_flip.cooldown = 4
tt.unit.hide_after_death = true
tt.info.fn = scripts.hero_basic.get_info
tt.info.hero_portrait = "kr6_hero_portraits_0015"
tt.info.portrait = "kr6_info_portraits_heroes_0015"
tt.info.i18n_key = "HERO_LORD_BLACKBURN"
tt.motion.max_speed = 45
tt.regen.cooldown = 1
tt.regen.health = 36
tt.render.sprites[1].prefix = "BB_V1Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].flip_x = true
tt.unit.hit_offset = v(0, 5)
tt.unit.mod_offset = v(0, 30)
tt.unit.marker_offset = v(0, -1)
tt.vis.bans = bor(F_BLOOD)
tt.vis.flags = bor(F_BLOCK, F_FRIEND)
tt.main_script.insert = scripts.hero_stage_215_lord_blackburn.insert
tt.main_script.update = scripts.hero_stage_215_lord_blackburn.update
tt.main_script.remove = nil
tt.melee.range = 75
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_min = 26
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].animation = "attack_01"
tt.melee.attacks[1].hit_time = fts(21)
tt.melee.attacks[1].hit_fx = "fx_stage_215_lord_blackburn_hit_01"
tt.melee.attacks[1].hit_offset = v(45, 12)
tt.melee.attacks[1].sound_hit = "Stage15BlackburnBasicAttack"
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack_02"
tt.melee.attacks[2].hit_time = fts(17)
tt.melee.attacks[2].chance = 0.5
tt.soldier.melee_slot_offset = v(20, 0)
tt.sound_events.change_rally_point = "Stage15BlackburnTaunt"
tt.sound_events.death = "Stage15BlackburnDeath"
tt.sound_events.respawn = "Stage15BlackburnRespawn"
tt.sound_events.insert = nil
tt.sound_drink = "Stage15BlackburnDrinkPotion"
tt.sound_power_up = "Stage15BlackburnPowerUp"
tt.sound_explosion = "Stage15BlackburnExplosion"
tt.sound_jump = "Stage15BlackburnJumpOut"
tt.sound_energy = "Stage15MidCinematicDarkEnergy"
tt.corrupt_count = 1
tt.death_aura = "aura_stage_215_lord_blackburn"
tt.intro_drink_time = fts(90)
tt.intro_explosion_time = fts(85)
tt.death_explosion_decal = "decal_stage_215_lord_blackburn_death_explosion"
tt.explosion_ground_decal = "decal_stage_215_lord_blackburn_explosion_ground"
tt.offset_decal_explosion = v(-20, 8)
tt.offset_decal_ground = v(-6, 3)
tt.corruption = {}
tt.corruption.renders = {"BB_V1Def", "BB_V2Def", "BB_V3Def"}
tt.corruption.portraits = {"kr6_info_portraits_heroes_0015", "kr6_info_portraits_heroes_0016", "kr6_info_portraits_heroes_0017"}
tt.corruption.tombstones = {"decal_stage_215_lord_blackburn_tombstone_lvl1", "decal_stage_215_lord_blackburn_tombstone_lvl2", "decal_stage_215_lord_blackburn_tombstone_lvl3"}
tt.corruption.hero_portraits = {"kr6_hero_portraits_0015", "kr6_hero_portraits_0016", "kr6_hero_portraits_0017"}
tt.corruption.hp_max = {450, 650, 800}
tt.corruption.armor = {0.3, 0.5, 0.6}
tt.corruption.magic_armor = {0, 0, 0}
tt.corruption.regen_health = {36, 44, 64}
tt.corruption.damage_min = {26, 34, 52}
tt.corruption.damage_max = {40, 50, 78}
tt.corruption.hit_fx = {"fx_stage_215_lord_blackburn_hit_01", "fx_stage_215_lord_blackburn_hit_02", "fx_stage_215_lord_blackburn_hit_02"}
tt.corruption.click_rects = {r(-30, 0, 60, 50), r(-30, 0, 60, 55), r(-30, 0, 60, 65)}
tt.corruption.melee_offsets = {v(20, 0), v(25, 0), v(25, 0)}
tt.corruption.health_bar_offsets = {v(0, 60), v(0, 65), v(0, 70)}
tt.corruption.boss = "enemy_boss_stage_215"
tt.ui.click_rect = r(-30, 0, 60, 50)

-- ============================================================
-- KR6 stage 18（最终关）英雄 Denas（hero_stage_218_denas）
-- ============================================================
tt = RT("hero_stage_218_denas", "stage_hero")
AC(tt, "melee", "timed_attacks")
tt.hero.respawn_animation = "revive"
tt.hero.tombstone_decal = "decal_denas_sword_tombstone"
tt.hero.tombstone_show_time = fts(62)
tt.hero.tombstone_concurrent_with_death = true
tt.hero.remove_tombstone_before_respawn = true
tt.hero.stage_hero = true
tt.hero.stage_hero_w_portrait = true
tt.health.armor = 0.5
tt.health.dead_lifetime = 27
tt.health.hp_max = 750
tt.health_bar.offset = v(0, 74)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.info.fn = scripts.hero_basic.get_info
tt.info.hero_portrait = "kr6_hero_portraits_0018"
tt.info.portrait = "kr6_info_portraits_heroes_0018"
tt.info.i18n_key = "HERO_DENAS"
tt.main_script.insert = scripts.hero_stage_218_denas.insert
tt.main_script.update = scripts.hero_stage_218_denas.update
tt.motion.max_speed = 110
tt.rally_speed_boost = {
	min_dist = 100,
	speed_factor = 1.5
}
tt.regen.cooldown = 1
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk_slow"}
tt.render.sprites[1].prefix = "animations_denasDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = DO_HEROES
tt.sound_events.change_rally_point = "Stage218DenasTaunt"
tt.sound_events.cinematic_entrance = "Stage218DenasTauntIntro"
tt.sound_events.cinematic_gallop = "Stage218MidCinematicDenasGallop"
tt.sound_events.cinematic_neigh = "Stage218MidCinematicDenasHorseNeigh"
tt.cinematic_gallop_lead = 0.75
tt.cinematic_neigh_delay = 3.8
tt.sound_events.death = "Stage218DenasDeath"
tt.sound_events.respawn = "Stage218DenasTauntIntro"
tt.soldier.melee_slot_offset.x = 18
tt.unit.hit_offset = v(0, 36)
tt.unit.marker_offset = v(0, -1)
tt.unit.mod_offset = v(0, 33)
tt.unit.hide_after_death = true
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animation = "melee"
tt.melee.attacks[1].damage_min = 35
tt.melee.attacks[1].damage_max = 50
tt.melee.attacks[1].hit_time = fts(17)
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].hit_offset = v(46, 7)
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "mighty_blow"
tt.melee.attacks[2].damage_min = 100
tt.melee.attacks[2].damage_max = 120
tt.melee.attacks[2].damage_type = DAMAGE_TRUE
tt.melee.attacks[2].hit_time = fts(26)
tt.melee.attacks[2].cooldown = 6
tt.melee.attacks[2].sound = "MeleeSword"
tt.melee.attacks[2].vis_bans = bor(F_CLIFF)
tt.melee.attacks[2].vis_flags = F_BLOCK
tt.melee.attacks[2].hit_offset = v(55, 22)
tt.melee.cooldown = 2
tt.melee.range = 72
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "catapult_barrage"
tt.timed_attacks.list[1].bullet = "bullet_denas_bombardement"
tt.timed_attacks.list[1].cooldown = 20
tt.timed_attacks.list[1].max_range = 300
tt.timed_attacks.list[1].min_targets = 3
tt.timed_attacks.list[1].cluster_radius = 75
tt.timed_attacks.list[1].shots = 1
tt.timed_attacks.list[1].edge_margin = 150
tt.timed_attacks.list[1].hero_margin = 100
tt.timed_attacks.list[1].cast_time = fts(51)
tt.timed_attacks.list[1].burst_interval = fts(11)
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animation = "summon_royal_guard"
tt.timed_attacks.list[2].entity = "soldier_denas_guard"
tt.timed_attacks.list[2].cooldown = 15
tt.timed_attacks.list[2].range_nodes_min = 0
tt.timed_attacks.list[2].range_nodes_max = 30
tt.timed_attacks.list[2].max_path_dist = 60
tt.timed_attacks.list[2].ahead_nodes = 5
tt.timed_attacks.list[2].initial_entity = "soldier_denas_guard_initial"
tt.timed_attacks.list[2].cast_time = fts(30)
tt.ui.click_rect = r(-25, 0, 50, 60)

-- 迪纳斯皇家卫队
tt = RT("soldier_denas_guard", "soldier_militia")
AC(tt, "reinforcement", "nav_grid", "tween")
tt.health.armor = 0.35
tt.health.hp_max = 150
tt.health_bar.offset = v(0, 30)
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.info.random_name_format = "SOLDIER_REINFORCEMENTS_M_%i_NAME"
tt.info.random_name_count = 6
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = 8
tt.melee.attacks[1].damage_max = 12
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].hit_offset = v(30, 10)
tt.melee.range = 72
tt.motion.max_speed = 64
tt.regen.cooldown = 1
tt.regen.health = 8
tt.reinforcement.duration = 12
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].prefix = "denas_reinforcements_lvl3_"
tt.soldier.melee_slot_offset = v(3, 0)
tt.sound_events.insert = "ReinforcementTaunt"
tt.sound_events.change_rally_point = tt.sound_events.insert
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.tween.reverse = false
tt.unit.hit_offset = v(0, 5)
tt.unit.mod_offset = v(0, 14)
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
tt.vis.flags = bor(F_BLOCK, F_FRIEND)
tt.ui.click_rect = r(-15, -5, 30, 35)
tt.ui.click_rect_offset_y = -10

tt = RT("soldier_denas_guard_initial", "soldier_denas_guard")
tt.reinforcement.duration = nil

tt = RT("decal_denas_sword_tombstone", "decal")
tt.render.sprites[1].prefix = "animations_denasDef"
tt.render.sprites[1].name = "death_idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true

tt = RT("fx_denas_catapult_explosion", "fx")
tt.render.sprites[1].prefix = "explosion_catapulta_terreno_2Def"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true

tt = RT("fx_denas_catapult_explosion_1", "fx_denas_catapult_explosion")
tt.render.sprites[1].prefix = "explosion_catapulta_terreno_1Def"

tt = RT("decal_denas_catapult_floor", "decal_scripted")
tt.render.sprites[1].prefix = "decal_piso_catapultaDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = scripts.decal_utils.animation_in_loop_out.update
tt.duration = 2.5
tt.animation_start = "in"
tt.animation_idle = "idle"
tt.animation_end = "out"

tt = RT("decal_denas_catapult_floor_1", "decal_denas_catapult_floor")
tt.render.sprites[1].prefix = "decal_piso_catapulta_terreno_1Def"

tt = RT("ps_denas_catapult_trail", "particle_system")
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.name = "denas_vfx_multiexport_trail_catapulta_run"
tt.particle_system.emission_rate = 70
tt.particle_system.track_rotation = true
tt.particle_system.emit_area_spread = v(10, 0)
tt.particle_system.scales_x = {2}
tt.particle_system.scales_y = {2}
tt.particle_system.particle_lifetime = {fts(10), fts(10)}

tt = RT("bullet_denas_bombardement", "bullet")
AC(tt, "tween")
tt.bullet.flight_time = fts(50)
tt.bullet.g = -1.5 / (fts(1) * fts(1))
tt.bullet.align_with_trajectory = true
tt.bullet.particles_name = "ps_denas_catapult_trail"
tt.bullet.hit_fx = "fx_denas_catapult_explosion"
tt.bullet.hit_decal = "decal_denas_catapult_floor"
tt.bullet.damage_type = DAMAGE_EXPLOSION
tt.bullet.damage_radius = 60
tt.bullet.damage_min = 200
tt.bullet.damage_max = 450
tt.bullet.damage_factor = 1
tt.bullet.damage_flags = F_AREA
tt.render.sprites[1].prefix = "animations_proyectilDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BULLETS
tt.main_script.insert = scripts.bomb.insert
tt.main_script.update = scripts.bomb.update
tt.tween.remove = false
tt.tween.props[1].sprite_id = 1
tt.tween.props[1].name = "scale"
tt.screenshake_amplitude = 0.3
tt.screenshake_duration = 0.4
tt.screenshake_freq_factor = 3
tt.tween.props[1].keys = {{0, v(1.7, 1.7)}, {tt.bullet.flight_time, v(0.7, 0.7)}}
tt.sound_events.insert = "Stage218DenasBombardmentCast"
tt.sound_events.hit = "Stage218DenasBombardmentImpact"
