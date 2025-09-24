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

local function archer_towers()
    tt = RT("tower_ranger", "tower_archer_1")
    AC(tt, "attacks", "powers")
    image_y = 90
    tt.tower.type = "ranger"
    tt.tower.level = 1
    tt.tower.price = 230
    tt.tower.size = TOWER_SIZE_LARGE
    tt.info.enc_icon = 13
    tt.info.i18n_key = "TOWER_RANGERS"
    tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_towers_0010" or "info_portraits_towers_0006"
    tt.powers.poison = CC("power")
    tt.powers.poison.price_base = 250
    tt.powers.poison.price_inc = 200
    tt.powers.poison.mods = {"mod_ranger_poison", "mod_ranger_slow"}
    tt.powers.poison.enc_icon = 8
    tt.powers.thorn = CC("power")
    tt.powers.thorn.price_base = 225
    tt.powers.thorn.price_inc = 175
    tt.powers.thorn.aura = "aura_ranger_thorn"
    tt.powers.thorn.enc_icon = 9
    tt.powers.thorn.name = "thorns"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrain_archer_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)
    tt.render.sprites[2] = CC("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "archer_tower_0005"
    tt.render.sprites[2].offset = vec_2(0, 40)
    tt.render.sprites[3] = CC("sprite")
    tt.render.sprites[3].prefix = "tower_ranger_shooter"
    tt.render.sprites[3].name = "idleDown"
    tt.render.sprites[3].angles = {
        idle = {"idleUp", "idleDown"},
        shoot = {"shootingUp", "shootingDown"}
    }
    tt.render.sprites[3].offset = vec_2(-8, 65)
    tt.render.sprites[4] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[4].offset.x = 8
    tt.render.sprites[5] = CC("sprite")
    tt.render.sprites[5].prefix = "tower_ranger_druid"
    tt.render.sprites[5].name = "idle"
    tt.render.sprites[5].hidden = true
    tt.render.sprites[5].offset = vec_2(31, 15)
    tt.main_script.update = scripts.tower_ranger.update
    tt.attacks.range = 200
    tt.attacks.list[1] = CC("bullet_attack")
    tt.attacks.list[1].animation = "shoot"
    tt.attacks.list[1].bullet = "arrow_ranger"
    tt.attacks.list[1].cooldown = 0.39
    tt.attacks.list[1].shoot_time = fts(4)
    tt.attacks.list[1].shooters_delay = 0.1
    tt.attacks.list[1].bullet_start_offset = {vec_2(8, 4), vec_2(4, -5)}
    tt.sound_events.insert = "ArcherRangerTaunt"

    tt = RT("aura_ranger_thorn", "aura")
    tt.aura.mod = "mod_thorn"
    tt.aura.duration = -1
    tt.aura.radius = 200
    tt.aura.vis_flags = bor(F_THORN, F_MOD)
    tt.aura.vis_bans = bor(F_FLYING, F_BOSS)
    tt.aura.cooldown = 8 + fts(34)
    -- tt.aura.max_times = 3
    tt.aura.max_count = 2
    tt.aura.max_count_inc = 2
    tt.aura.min_count = 2
    tt.aura.owner_animation = "shoot"
    tt.aura.owner_sid = 5
    tt.aura.hit_time = fts(17)
    tt.aura.hit_sound = "ThornSound"
    tt.main_script.update = scripts.aura_ranger_thorn.update

    tt = RT("arrow_ranger", "arrow")
    tt.bullet.damage_min = 13
    tt.bullet.damage_max = 20
    tt.bullet.flight_time = fts(15.2)

    tt = RT("mod_ranger_poison", "mod_poison")
    tt.modifier.duration = 3
    tt.dps.damage_max = 0
    tt.dps.damage_min = 0
    tt.dps.damage_inc = 5
    tt.dps.damage_every = 1
    tt.dps.kill = true
    tt.dps.damage_type = bor(DAMAGE_POISON, DAMAGE_NO_SHIELD_HIT)

    tt = RT("mod_ranger_slow", "mod_slow")
    tt.modifier.duration = 3
    tt.slow.factor = 0.9

    tt = RT("mod_thorn", "modifier")
    AC(tt, "render")
    tt.animation_start = "thorn"
    tt.animation_end = "thornFree"
    tt.modifier.duration = 0
    tt.modifier.duration_inc = 1
    tt.modifier.type = MOD_TYPE_FREEZE
    tt.modifier.vis_flags = bor(F_THORN, F_MOD)
    tt.modifier.vis_bans = bor(F_FLYING, F_BOSS)
    tt.max_times_applied = 3
    tt.damage_min = 40
    tt.damage_max = 40
    tt.damage_type = DAMAGE_PHYSICAL
    tt.damage_every = 1
    tt.render.sprites[1].prefix = "mod_thorn_small"
    tt.render.sprites[1].name = "start"
    tt.render.sprites[1].size_prefixes = {"mod_thorn_small", "mod_thorn_big", "mod_thorn_big"}
    tt.render.sprites[1].size_scales = {vec_1(0.7), vec_1(0.8), vec_1(1)}
    tt.render.sprites[1].anchor.y = 0.22
    tt.main_script.queue = scripts.mod_thorn.queue
    tt.main_script.dequeue = scripts.mod_thorn.dequeue
    tt.main_script.insert = scripts.mod_thorn.insert
    tt.main_script.update = scripts.mod_thorn.update
    tt.main_script.remove = scripts.mod_thorn.remove


    local tower_crossbow = RT("tower_crossbow", "tower_archer_1")
    AC(tower_crossbow, "attacks", "powers")
    tower_crossbow.info.portrait = (IS_PHONE_OR_TABLET and "portraits_towers_" or "kr2_info_portraits_towers_") .. "0009"
    tower_crossbow.info.enc_icon = 17
    tower_crossbow.tower.type = "crossbow"
    tower_crossbow.tower.price = 230
    tower_crossbow.powers.multishot = CC("power")
    tower_crossbow.powers.multishot.price_base = 250
    tower_crossbow.powers.multishot.price_inc = 150
    tower_crossbow.powers.multishot.name = "BARRAGE"
    tower_crossbow.powers.multishot.enc_icon = 28
    tower_crossbow.powers.multishot.attack_idx = 2
    tower_crossbow.powers.eagle = CC("power")
    tower_crossbow.powers.eagle.price_base = 225
    tower_crossbow.powers.eagle.price_inc = 200
    tower_crossbow.powers.eagle.name = "FALCONER"
    tower_crossbow.powers.eagle.enc_icon = 29
    tower_crossbow.main_script.update = scripts.tower_crossbow.update
    tower_crossbow.main_script.remove = scripts.tower_crossbow.remove
    tower_crossbow.attacks.range = 200
    tower_crossbow.attacks.list[1] = CC("bullet_attack")
    tower_crossbow.attacks.list[1].bullet = "arrow_crossbow"
    tower_crossbow.attacks.list[1].cooldown = 0.5
    tower_crossbow.attacks.list[1].shoot_time = fts(8)
    tower_crossbow.attacks.list[1].bullet_start_offset = {vec_2(-11, 60), vec_2(11, 60)}
    tower_crossbow.attacks.list[1].critical_chance = 0.12
    tower_crossbow.attacks.list[1].critical_chance_inc = 0.06
    tower_crossbow.attacks.list[2] = CC("bullet_attack")
    tower_crossbow.attacks.list[2].bullet = "multishot_crossbow"
    tower_crossbow.attacks.list[2].cooldown = 6
    tower_crossbow.attacks.list[2].shoot_time = fts(1)
    tower_crossbow.attacks.list[2].cycle_time = fts(3)
    tower_crossbow.attacks.list[2].shots = 4
    tower_crossbow.attacks.list[2].shots_inc = 2
    tower_crossbow.attacks.list[2].near_range = 70
    tower_crossbow.attacks.list[2].near_range_base = 35
    tower_crossbow.attacks.list[2].near_range_inc = 35
    tower_crossbow.attacks.list[2].bullet_start_offset = {vec_2(-11, 60), vec_2(11, 60)}
    tower_crossbow.attacks.list[3] = CC("mod_attack")
    tower_crossbow.attacks.list[3].mod = "mod_crossbow_eagle"
    tower_crossbow.attacks.list[3].cooldown = 1
    tower_crossbow.attacks.list[3].fly_cooldown = 10
    tower_crossbow.attacks.list[3].range = 128
    tower_crossbow.attacks.list[3].range_inc = 32
    tower_crossbow.render.sprites[1].name = "terrain_archer_%04i"
    tower_crossbow.render.sprites[1].offset = vec_2(0, 14)
    tower_crossbow.render.sprites[2].name = "CossbowHunter_tower"
    tower_crossbow.render.sprites[2].offset = vec_2(0, 33)
    tower_crossbow.render.sprites[3].prefix = "shootercrossbow"
    tower_crossbow.render.sprites[3].offset = vec_2(-9, 58)
    tower_crossbow.render.sprites[3].angles.multishot_start = {"multishotStartUp", "multishotStartDown"}
    tower_crossbow.render.sprites[3].angles.multishot_loop = {"multishotLoopUp", "multishotLoopDown"}
    tower_crossbow.render.sprites[3].angles.multishot_end = {"multishotEndUp", "multishotEndDown"}
    tower_crossbow.render.sprites[4].prefix = "shootercrossbow"
    tower_crossbow.render.sprites[4].offset = vec_2(12, 58)
    tower_crossbow.render.sprites[4].angles.multishot_start = {"multishotStartUp", "multishotStartDown"}
    tower_crossbow.render.sprites[4].angles.multishot_loop = {"multishotLoopUp", "multishotLoopDown"}
    tower_crossbow.render.sprites[4].angles.multishot_end = {"multishotEndUp", "multishotEndDown"}
    tower_crossbow.render.sprites[5] = CC("sprite")
    tower_crossbow.render.sprites[5].prefix = "crossbow_eagle"
    tower_crossbow.render.sprites[5].name = "idle"
    tower_crossbow.render.sprites[5].offset = vec_2(2, 53)
    tower_crossbow.render.sprites[5].hidden = true
    tower_crossbow.render.sprites[5].draw_order = 6
    tower_crossbow.sound_events.insert = "CrossbowTauntReady"

    local arrow_crossbow = RT("arrow_crossbow", "arrow")

    arrow_crossbow.bullet.flight_time = fts(15)
    arrow_crossbow.bullet.damage_min = 15
    arrow_crossbow.bullet.damage_max = 23
    arrow_crossbow.bullet.pop = {"pop_shunt_violet"}

    local multishot_crossbow = RT("multishot_crossbow", "shotgun")

    multishot_crossbow.bullet.damage_type = DAMAGE_SHOT
    multishot_crossbow.bullet.min_speed = 20 * FPS
    multishot_crossbow.bullet.max_speed = 20 * FPS
    multishot_crossbow.bullet.damage_min = 30
    multishot_crossbow.bullet.damage_max = 40
    multishot_crossbow.bullet.hide_radius = 12
    multishot_crossbow.bullet.hit_blood_fx = "fx_blood_splat"
    multishot_crossbow.bullet.miss_fx = "fx_smoke_bullet"
    multishot_crossbow.bullet.miss_fx_water = "fx_splash_small"
    multishot_crossbow.render.sprites[1].name = "proy_crossbow_special"
    multishot_crossbow.render.sprites[1].animated = false
    multishot_crossbow.sound_events.insert = "ArrowSound"

    local mod_crossbow_eagle = RT("mod_crossbow_eagle", "modifier")
    AC(mod_crossbow_eagle, "render", "tween")
    mod_crossbow_eagle.range_factor = 1.03
    mod_crossbow_eagle.range_factor_inc = 0.03
    mod_crossbow_eagle.cooldown_factor = 0.965
    mod_crossbow_eagle.cooldown_factor_inc = -0.025
    mod_crossbow_eagle.main_script.insert = scripts.mod_crossbow_eagle.insert
    mod_crossbow_eagle.main_script.remove = scripts.mod_crossbow_eagle.remove
    mod_crossbow_eagle.tween.remove = false
    mod_crossbow_eagle.tween.props[1].name = "scale"
    mod_crossbow_eagle.tween.props[1].loop = true
    mod_crossbow_eagle.tween.props[1].keys = {{0, vec_2(1, 1)}, {0.5, vec_2(0.9, 0.9)}, {1, vec_2(1, 1)}}
    mod_crossbow_eagle.render.sprites[1].name = "CossbowHunter_towerBuff"
    mod_crossbow_eagle.render.sprites[1].animated = false
    mod_crossbow_eagle.render.sprites[1].anchor.y = 0.21
    mod_crossbow_eagle.render.sprites[1].z = Z_TOWER_BASES + 1

    for i, p in ipairs({vec_2(22, 45), vec_2(40, 35), vec_2(58, 30), vec_2(77, 35), vec_2(95, 45)}) do
        mod_crossbow_eagle.render.sprites[i + 1] = CC("sprite")
        mod_crossbow_eagle.render.sprites[i + 1].prefix = "crossbow_eagle_buff"
        mod_crossbow_eagle.render.sprites[i + 1].name = "idle"
        mod_crossbow_eagle.render.sprites[i + 1].anchor.y = 0.21
        mod_crossbow_eagle.render.sprites[i + 1].offset = vec_2(p.x - 58, p.y - 27)
        mod_crossbow_eagle.render.sprites[i + 1].ts = math.random()
    end

    local decal_crossbow_eagle_preview = RT("decal_crossbow_eagle_preview", "decal_tween")

    decal_crossbow_eagle_preview.render.sprites[1].name = "CrossbowHunterDecalDotted"
    decal_crossbow_eagle_preview.render.sprites[1].animated = false
    decal_crossbow_eagle_preview.render.sprites[1].anchor = vec_2(0.5, 0.32)
    decal_crossbow_eagle_preview.render.sprites[1].offset.y = 0
    decal_crossbow_eagle_preview.tween.remove = false
    decal_crossbow_eagle_preview.tween.props[1].name = "scale"
    decal_crossbow_eagle_preview.tween.props[1].loop = true
    decal_crossbow_eagle_preview.tween.props[1].keys = {{0, vec_2(1, 1)}, {0.25, vec_2(1.15, 1.15)}, {0.5, vec_2(1, 1)}}

    local tower_totem = RT("tower_totem", "tower_archer_1")
    AC(tower_totem, "powers")
    tower_totem.info.portrait = (IS_PHONE and "portraits_towers_" or "kr2_info_portraits_towers_") .. "0010"
    tower_totem.info.enc_icon = 18
    tower_totem.tower.type = "totem"
    tower_totem.tower.price = 215
    tower_totem.powers.weakness = CC("power")
    tower_totem.powers.weakness.price_base = 200
    tower_totem.powers.weakness.price_inc = 200
    tower_totem.powers.weakness.enc_icon = 30
    tower_totem.powers.weakness.attack_idx = 2
    tower_totem.powers.silence = CC("power")
    tower_totem.powers.silence.price_base = 145
    tower_totem.powers.silence.price_inc = 145
    tower_totem.powers.silence.name = "SPIRITS"
    tower_totem.powers.silence.enc_icon = 31
    tower_totem.powers.silence.attack_idx = 3
    tower_totem.main_script.update = scripts.tower_totem.update
    tower_totem.attacks.range = 180
    tower_totem.attacks.list[1].bullet = "axe_totem"
    tower_totem.attacks.list[1].cooldown = 0.8
    tower_totem.attacks.list[1].shoot_time = fts(8)
    tower_totem.attacks.list[1].bullet_start_offset = {vec_2(-12, 72), vec_2(12, 72)}
    tower_totem.attacks.list[2] = CC("bullet_attack")
    tower_totem.attacks.list[2].bullet = "totem_weakness"
    tower_totem.attacks.list[2].cooldown = 9.5
    tower_totem.attacks.list[2].vis_bans = bor(F_CLIFF)
    tower_totem.attacks.list[3] = CC("bullet_attack")
    tower_totem.attacks.list[3].bullet = "totem_silence"
    tower_totem.attacks.list[3].cooldown = 8
    tower_totem.attacks.list[3].vis_bans = bor(F_CLIFF)
    tower_totem.render.sprites[1].name = "terrain_archer_%04i"
    tower_totem.render.sprites[1].offset = vec_2(0, 12)
    tower_totem.render.sprites[2].name = "TotemTower"
    tower_totem.render.sprites[2].offset = vec_2(0, 37)
    tower_totem.render.sprites[3].prefix = "shootertotem"
    tower_totem.render.sprites[3].offset = vec_2(-10, 58)
    tower_totem.render.sprites[4].prefix = "shootertotem"
    tower_totem.render.sprites[4].offset = vec_2(10, 58)
    tower_totem.render.sprites[5] = CC("sprite")
    tower_totem.render.sprites[5].name = "totem_fire"
    tower_totem.render.sprites[5].offset = vec_2(-25, 10)
    tower_totem.render.sprites[6] = CC("sprite")
    tower_totem.render.sprites[6].name = "totem_fire"
    tower_totem.render.sprites[6].offset = vec_2(25, 10)
    tower_totem.render.sprites[7] = CC("sprite")
    tower_totem.render.sprites[7].name = "totem_eyes_lower"
    tower_totem.render.sprites[7].offset = vec_2(0, 17)
    tower_totem.render.sprites[7].hidden = true
    tower_totem.render.sprites[7].loop = false
    tower_totem.render.sprites[8] = CC("sprite")
    tower_totem.render.sprites[8].name = "totem_eyes_upper"
    tower_totem.render.sprites[8].offset = vec_2(0, 41)
    tower_totem.render.sprites[8].hidden = true
    tower_totem.render.sprites[8].loop = false
    tower_totem.sound_events.insert = "TotemTauntReady"

    local axe_totem = RT("axe_totem", "arrow")
    axe_totem.render.sprites[1].name = "TotemAxe_0001"
    axe_totem.render.sprites[1].animated = false
    axe_totem.bullet.rotation_speed = 30 * FPS * math.pi / 180
    axe_totem.bullet.miss_decal = "TotemAxe_0002"
    axe_totem.bullet.damage_min = 25
    axe_totem.bullet.damage_max = 40
    axe_totem.bullet.damage_type = DAMAGE_PHYSICAL
    axe_totem.reduce_armor = 0.2
    axe_totem.bullet.pop = {"pop_thunk"}
    axe_totem.bullet.pop_chance = 1
    axe_totem.bullet.pop_conds = DR_KILL
    axe_totem.sound_events.insert = "AxeSound"

    local mod_silence_totem = RT("mod_silence_totem", "modifier")
    AC(mod_silence_totem, "render")
    mod_silence_totem.modifier.duration = 3
    mod_silence_totem.modifier.bans = {"mod_shaman_armor", "mod_shaman_magic_armor", "mod_shaman_priest_heal", "mod_shaman_rage"}
    mod_silence_totem.modifier.remove_banned = true
    mod_silence_totem.main_script.insert = scripts.mod_silence.insert
    mod_silence_totem.main_script.remove = scripts.mod_silence.remove
    mod_silence_totem.main_script.update = scripts.mod_track_target.update
    mod_silence_totem.render.sprites[1].prefix = "silence"
    mod_silence_totem.render.sprites[1].size_names = {"small", "big", "big"}
    mod_silence_totem.render.sprites[1].name = "small"
    mod_silence_totem.render.sprites[1].loop = true
    mod_silence_totem.render.sprites[1].draw_order = 2

    local mod_weakness_totem = RT("mod_weakness_totem", "modifier")
    -- AC(mod_weakness_totem, "render")
    mod_weakness_totem.inflicted_damage_factor = 0.5
    mod_weakness_totem.received_damage_factor = 1.4
    mod_weakness_totem.modifier.duration = 3
    mod_weakness_totem.modifier.resets_same = false
    mod_weakness_totem.modifier.use_mod_offset = false
    mod_weakness_totem.main_script.insert = scripts.mod_damage_factors.insert
    mod_weakness_totem.main_script.remove = scripts.mod_damage_factors.remove
    mod_weakness_totem.main_script.update = scripts.mod_track_target.update
    -- mod_weakness_totem.render.sprites[1].prefix = "weakness"
    -- mod_weakness_totem.render.sprites[1].size_names = {"small", "big", "big"}
    -- mod_weakness_totem.render.sprites[1].name = "small"
    -- mod_weakness_totem.render.sprites[1].loop = true
    -- mod_weakness_totem.render.sprites[1].z = Z_DECALS

    local totem_silence = RT("totem_silence", "aura")
    AC(totem_silence, "render", "tween")
    totem_silence.aura.mod = "mod_silence_totem"
    totem_silence.aura.cycle_time = 0.3
    totem_silence.aura.duration = 2
    totem_silence.aura.duration_inc = 2
    totem_silence.aura.radius = 80
    totem_silence.aura.vis_bans = F_BOSS
    totem_silence.aura.vis_flags = F_MOD
    totem_silence.render.sprites[1].name = "TotemTower_GroundEffect-Violet_0002"
    totem_silence.render.sprites[1].animated = false
    totem_silence.render.sprites[1].scale = vec_2(0.64, 0.64)
    totem_silence.render.sprites[1].alpha = 50
    totem_silence.render.sprites[1].z = Z_DECALS
    totem_silence.render.sprites[2] = CC("sprite")
    totem_silence.render.sprites[2].name = "TotemTower_GroundEffect-Violet_0001"
    totem_silence.render.sprites[2].animated = false
    totem_silence.render.sprites[2].z = Z_DECALS
    totem_silence.render.sprites[3] = CC("sprite")
    totem_silence.render.sprites[3].prefix = "totem_violet"
    totem_silence.render.sprites[3].name = "start"
    totem_silence.render.sprites[3].loop = false
    totem_silence.render.sprites[3].anchor = vec_2(0.5, 0.11)
    totem_silence.main_script.update = scripts.aura_totem.update
    totem_silence.sound_events.insert = "TotemSpirits"
    totem_silence.tween.remove = false
    totem_silence.tween.props[1].name = "scale"
    totem_silence.tween.props[1].keys = {{0, vec_2(0.64, 0.64)}, {fts(15), vec_2(1, 1)}, {fts(30), vec_2(1.6, 1.6)}}
    totem_silence.tween.props[1].loop = true
    totem_silence.tween.props[2] = CC("tween_prop")
    totem_silence.tween.props[2].keys = {{0, 50}, {fts(10), 255}, {fts(20), 255}, {fts(30), 0}}
    totem_silence.tween.props[2].loop = true

    local totem_weakness = RT("totem_weakness", "totem_silence")
    totem_weakness.aura.mods = {"mod_weakness_totem", "mod_totem_fire"}
    totem_weakness.aura.duration = 0
    totem_weakness.aura.duration_inc = 3
    totem_weakness.aura.vis_bans = 0
    totem_weakness.render.sprites[1].name = "TotemTower_GroundEffect-Red_0002"
    totem_weakness.render.sprites[2].name = "TotemTower_GroundEffect-Red_0001"
    totem_weakness.render.sprites[3].prefix = "totem_red"
    totem_weakness.render.sprites[3].anchor = vec_2(0.45, 0.17)
    totem_weakness.sound_events.insert = "TotemWeakness"

    tt = RT("mod_totem_fire", "mod_lava")
    tt.modifier.duration = 3
    tt.dps.damage_min = 1
    tt.dps.damage_max = 1
    tt.dps.damage_inc = 1
    tt.dps.damage_type = DAMAGE_TRUE
    tt.dps.damage_every = 0.5
    tt.render.sprites[1].color = {255, 100, 100}
    tt.render.sprites[1].alpha = 150
    -- 火枪
    tt = RT("tower_musketeer", "tower_archer_1")
    AC(tt, "attacks", "powers")
    image_y = 90
    tt.tower.type = "musketeer"
    tt.tower.level = 1
    tt.tower.price = 230
    tt.tower.size = TOWER_SIZE_LARGE
    tt.info.enc_icon = 17
    tt.info.i18n_key = "TOWER_MUSKETEERS"
    tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_towers_0009" or "info_portraits_towers_0004"
    tt.powers.sniper = CC("power")
    tt.powers.sniper.attack_idx = 2
    tt.powers.sniper.price_base = 300
    tt.powers.sniper.price_inc = 250
    tt.powers.sniper.damage_factor_inc = 0.2
    tt.powers.sniper.instakill_chance_inc = 0.15
    tt.powers.sniper.enc_icon = 3
    tt.powers.shrapnel = CC("power")
    tt.powers.shrapnel.attack_idx = 4
    tt.powers.shrapnel.price_base = 300
    tt.powers.shrapnel.price_inc = 300
    tt.powers.shrapnel.enc_icon = 4
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrain_archer_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)
    tt.render.sprites[2] = CC("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "archer_tower_0004"
    tt.render.sprites[2].offset = vec_2(0, 37)
    tt.render.sprites[3] = CC("sprite")
    tt.render.sprites[3].prefix = "tower_musketeer_shooter"
    tt.render.sprites[3].name = "idleDown"
    tt.render.sprites[3].angles = {
        idle = {"idleUp", "idleDown"},
        shoot = {"shootingUp", "shootingDown"},
        sniper_shoot = {"sniperShootUp", "sniperShootDown"},
        sniper_seek = {"sniperSeekUp", "sniperSeekDown"},
        cannon_shoot = {"cannonShootUp", "cannonShootDown"},
        cannon_fuse = {"cannonFuseUp", "cannonFuseDown"}
    }
    tt.render.sprites[3].offset = vec_2(-8, 56)
    tt.render.sprites[4] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[4].offset.x = 8
    tt.main_script.update = scripts.tower_musketeer.update
    tt.sound_events.insert = "ArcherMusketeerTaunt"
    tt.attacks.range = 235
    tt.attacks.list[1] = CC("bullet_attack")
    tt.attacks.list[1].animation = "shoot"
    tt.attacks.list[1].bullet = "shotgun_musketeer"
    tt.attacks.list[1].cooldown = 1.5
    tt.attacks.list[1].shoot_time = fts(6)
    tt.attacks.list[1].shooters_delay = 0.1
    tt.attacks.list[1].bullet_start_offset = {vec_2(6, 8), vec_2(4, -5)}
    tt.attacks.list[2] = CC("bullet_attack")
    tt.attacks.list[2].animation = "sniper_shoot"
    tt.attacks.list[2].animation_seeker = "sniper_seek"
    tt.attacks.list[2].bullet = "shotgun_musketeer_sniper"
    tt.attacks.list[2].bullet_start_offset = tt.attacks.list[1].bullet_start_offset
    tt.attacks.list[2].cooldown = 14
    tt.attacks.list[2].power_name = "sniper"
    tt.attacks.list[2].shoot_time = fts(22)
    tt.attacks.list[2].vis_flags = F_RANGED
    tt.attacks.list[2].range = tt.attacks.range * 1.5
    tt.attacks.list[3] = table.deepclone(tt.attacks.list[2])
    tt.attacks.list[3].chance = 0
    tt.attacks.list[3].bullet = "shotgun_musketeer_sniper_instakill"
    tt.attacks.list[4] = CC("bullet_attack")
    tt.attacks.list[4].animation = "cannon_shoot"
    tt.attacks.list[4].animation_seeker = "cannon_fuse"
    tt.attacks.list[4].bullet = "bomb_musketeer"
    tt.attacks.list[4].loops = 6
    tt.attacks.list[4].bullet_start_offset = tt.attacks.list[1].bullet_start_offset
    tt.attacks.list[4].cooldown = 9
    tt.attacks.list[4].power_name = "shrapnel"
    tt.attacks.list[4].range = tt.attacks.range * 0.4
    tt.attacks.list[4].shoot_time = fts(16)
    tt.attacks.list[4].node_prediction = fts(6)
    tt.attacks.list[4].min_spread = 12.5
    tt.attacks.list[4].max_spread = 32.5
    tt.attacks.list[4].shoot_fx = "fx_rifle_smoke"

    tt = RT("ps_shotgun_musketeer", "particle_system")
    tt.particle_system.animated = true
    tt.particle_system.emission_rate = 20
    tt.particle_system.loop = false
    tt.particle_system.name = "ps_shotgun_musketeer"
    tt.particle_system.particle_lifetime = {fts(13), fts(13)}
    tt.particle_system.track_rotation = true

    tt = RT("shotgun_musketeer", "shotgun")
    tt.bullet.damage_max = 65
    tt.bullet.damage_min = 35
    tt.bullet.damage_type = bor(DAMAGE_SHOT, DAMAGE_NO_DODGE)
    tt.bullet.hit_blood_fx = "fx_blood_splat"
    tt.bullet.miss_fx = "fx_smoke_bullet"
    tt.bullet.start_fx = "fx_rifle_smoke"
    tt.bullet.min_speed = 20 * FPS
    tt.bullet.max_speed = 20 * FPS
    tt.sound_events.insert = "ShotgunSound"

    tt = RT("shotgun_musketeer_sniper", "shotgun_musketeer")
    tt.bullet.particles_name = "ps_shotgun_musketeer"
    tt.sound_events.insert = "SniperSound"
    tt.bullet.damage_type = bor(DAMAGE_SHOT, DAMAGE_FX_EXPLODE, DAMAGE_NO_DODGE)
    tt.bullet.pop = nil

    tt = RT("shotgun_musketeer_sniper_instakill", "shotgun_musketeer_sniper")
    tt.bullet.damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_FX_EXPLODE, DAMAGE_NO_DODGE)
    tt.bullet.pop = {"pop_headshot"}

    tt = RT("bomb_musketeer", "bomb")
    tt.bullet.damage_max = 0
    tt.bullet.damage_max_inc = 40
    tt.bullet.damage_min = 0
    tt.bullet.damage_min_inc = 10
    tt.bullet.damage_radius = 48
    tt.bullet.flight_time_min = fts(4)
    tt.bullet.flight_time_max = fts(8)
    tt.bullet.hit_fx = "fx_explosion_shrapnel"
    tt.bullet.pop = nil
    tt.render.sprites[1].name = "bombs_0007"
    tt.sound_events.insert = "ShrapnelSound"
    tt.sound_events.hit = nil
    tt.sound_events.hit_water = nil

    tt = RT("fx_explosion_shrapnel", "fx")
    tt.render.sprites[1].anchor.y = 0.2
    tt.render.sprites[1].sort_y_offset = -2
    tt.render.sprites[1].prefix = "explosion"
    tt.render.sprites[1].name = "shrapnel"

    tt = RT("tower_archer_dwarf", "tower_archer_1")
    AC(tt, "powers")
    tt.attacks.list[1] = CC("bullet_attack")
    tt.attacks.list[1].animation = "shoot"
    tt.attacks.list[1].bullet = "dwarf_shotgun"
    tt.attacks.list[1].bullet_start_offset = {vec_2(-15, 55), vec_2(15, 55)}
    tt.attacks.list[1].cooldown = 1.5
    tt.attacks.list[1].shoot_time = fts(14)
    tt.attacks.list[2] = CC("bullet_attack")
    tt.attacks.list[2].animation = "shoot_barrel"
    tt.attacks.list[2].bullet = "dwarf_barrel"
    tt.attacks.list[2].bullet_start_offset = {vec_2(-15, 68), vec_2(15, 68)}
    tt.attacks.list[2].cooldown = 10
    tt.attacks.list[2].disabled = true
    tt.attacks.list[2].power_name = "barrel"
    tt.attacks.list[2].shoot_time = fts(22)
    tt.attacks.list[2].vis_bans = F_FLYING
    tt.attacks.list[2].node_prediction = fts(22) + fts(21)
    tt.attacks.range = 220
    tt.info.fn = scripts.tower_archer_dwarf.get_info
    tt.info.portrait = (IS_PHONE and "portraits_towers_" or "kr2_info_portraits_towers_") .. "0017"
    tt.main_script.update = scripts.tower_archer_dwarf.update
    tt.powers.barrel = CC("power")
    tt.powers.barrel.price_base = 225
    tt.powers.barrel.price_inc = 125
    tt.powers.barrel.attack_idx = 2
    tt.powers.extra_damage = CC("power")
    tt.powers.extra_damage.price_base = 185
    tt.powers.extra_damage.price_inc = 185
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrain_archer_%04i"
    tt.render.sprites[1].offset = vec_2(0, 9)
    tt.render.sprites[2] = CC("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "DwarfRiflemen"
    tt.render.sprites[2].offset = vec_2(0, 31)
    tt.render.sprites[3] = CC("sprite")
    tt.render.sprites[3].angles = {}
    tt.render.sprites[3].angles.idle = {"idleUp", "idleDown"}
    tt.render.sprites[3].angles.shoot = {"shootingUp", "shootingDown"}
    tt.render.sprites[3].angles.shoot_barrel = {"shootBarrelUp", "shootBarrelDown"}
    tt.render.sprites[3].name = "idleDown"
    tt.render.sprites[3].offset = vec_2(-12, 58)
    tt.render.sprites[3].prefix = "shooterarcherdwarf"
    tt.render.sprites[4] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[4].offset = vec_2(12, 58)
    tt.render.sprites[5] = CC("sprite")
    tt.render.sprites[5].animated = false
    tt.render.sprites[5].name = "DwarfRiflemenTop"
    tt.render.sprites[5].offset = vec_2(0, 31)
    tt.sound_events.insert = "DwarfArcherTaunt2"
    tt.tower.price = 230
    tt.tower.type = "archer_dwarf"

    tt = RT("dwarf_shotgun", "shotgun")
    tt.bullet.level = 0
    tt.bullet.damage_min = 40
    tt.bullet.damage_max = 70
    tt.bullet.damage_inc = 35
    tt.bullet.min_speed = 40 * FPS
    tt.bullet.max_speed = 40 * FPS
    tt.bullet.hit_blood_fx = "fx_blood_splat"
    tt.bullet.miss_fx = "fx_smoke_bullet"
    tt.bullet.start_fx = "fx_rifle_smoke"
    tt.bullet.damage_type = DAMAGE_SHOT
    tt.sound_events.insert = "ShotgunSound"

    tt = RT("dwarf_barrel", "bomb")
    tt.bullet.damage_max = 45
    tt.bullet.damage_max_inc = 65
    tt.bullet.damage_min = 45
    tt.bullet.damage_min_inc = 35
    tt.bullet.damage_radius = 65
    tt.bullet.damage_radius_inc = 5
    tt.bullet.flight_time = fts(21)
    tt.bullet.g = -1 / (fts(1) * fts(1))
    tt.bullet.level = 0
    tt.render.sprites[1].name = "DwarfShooter_Barril"
    tt.sound_events.insert = "AxeSound"

    tt = RT("tower_pirate_watchtower", "tower_archer_1")
    AC(tt, "powers")
    tt.attacks.list[1] = CC("bullet_attack")
    tt.attacks.list[1].animation = "shoot"
    tt.attacks.list[1].bullet = "pirate_watchtower_shotgun"
    tt.attacks.list[1].bullet_start_offset = {vec_2(0, 73)}
    tt.attacks.list[1].cooldown = 3.2
    tt.attacks.list[1].shoot_time = fts(14)
    tt.attacks.range = 220
    tt.parrots = {}
    tt.info.fn = scripts.tower_pirate_watchtower.get_info
    tt.info.portrait = (IS_PHONE and "portraits_towers_" or "kr2_info_portraits_towers_") .. "0020"
    tt.main_script.update = scripts.tower_pirate_watchtower.update
    tt.main_script.remove = scripts.tower_pirate_watchtower.remove
    tt.powers.reduce_cooldown = CC("power")
    tt.powers.reduce_cooldown.price_base = 40
    tt.powers.reduce_cooldown.price_inc = 40
    tt.powers.reduce_cooldown.values = {2.2, 1.5, 1}
    tt.powers.parrot = CC("power")
    tt.powers.parrot.price_base = 250
    tt.powers.parrot.price_inc = 250
    tt.powers.parrot.max_level = 3
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "pirateTower"
    tt.render.sprites[1].offset = vec_2(0, 23)
    tt.render.sprites[1].hidden = true
    tt.render.sprites[1].hover_off_hidden = true
    tt.render.sprites[2] = CC("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "pirateTower"
    tt.render.sprites[2].offset = vec_2(0, 50)
    tt.render.sprites[3] = CC("sprite")
    tt.render.sprites[3].angles = {}
    tt.render.sprites[3].angles.idle = {"idleUp", "idleDown"}
    tt.render.sprites[3].angles.shoot = {"shootingUp", "shootingDown"}
    tt.render.sprites[3].name = "idleDown"
    tt.render.sprites[3].offset = vec_2(0, 71)
    tt.render.sprites[3].prefix = "pirate_watchtower_shooter"
    tt.render.sprites[4] = CC("sprite")
    tt.render.sprites[4].name = "pirate_watchtower_flag"
    tt.render.sprites[4].offset = vec_2(0, 50)
    tt.sound_events.insert = "PirateTowerTaunt2"
    tt.tower.price = 170
    tt.tower.type = "pirate_watchtower"

    tt = RT("pirate_watchtower_shotgun", "shotgun")
    tt.bullet.level = 0
    tt.bullet.damage_min = 45
    tt.bullet.damage_max = 65
    tt.bullet.damage_inc = 30
    tt.bullet.min_speed = 40 * FPS
    tt.bullet.max_speed = 40 * FPS
    tt.bullet.damage_type = DAMAGE_SHOT
    tt.bullet.hit_blood_fx = "fx_blood_splat"
    tt.bullet.miss_fx = "fx_smoke_bullet"
    tt.bullet.miss_fx_water = "fx_splash_small"
    tt.bullet.start_fx = "fx_rifle_smoke"
    tt.sound_events.insert = "ShotgunSound"

    tt = RT("pirate_watchtower_parrot", "decal_scripted")
    AC(tt, "force_motion", "custom_attack")
    anchor_y = 0.5
    image_y = 30
    tt.flight_height = 60
    tt.flight_speed_idle = 100
    tt.ramp_dist_idle = 100
    tt.flight_speed_busy = 200
    tt.ramp_dist_busy = 50
    tt.bombs_pos = nil
    tt.idle_pos = nil
    tt.main_script.update = scripts.pirate_watchtower_parrot.update
    tt.custom_attack = CC("custom_attack")
    tt.custom_attack.min_range = 20
    tt.custom_attack.max_range = 40
    tt.custom_attack.bullet = "pirate_watchtower_bomb"
    tt.custom_attack.cooldown = 2
    tt.custom_attack.damage_type = DAMAGE_EXPLOSION
    tt.custom_attack.vis_flags = F_RANGED
    tt.custom_attack.vis_bans = F_FLYING
    tt.render.sprites[1].anchor.y = anchor_y
    tt.render.sprites[1].prefix = "pirate_watchtower_parrot"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].draw_order = 2
    tt.render.sprites[1].loop_forced = true
    tt.render.sprites[1].sort_y_offset = -12
    tt.render.sprites[2] = CC("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "decal_flying_shadow"
    tt.render.sprites[2].offset = vec_2(0, 0)
    tt.owner = nil

    tt = RT("pirate_watchtower_bomb", "bomb")
    tt.bullet.flight_time = fts(10)
    tt.bullet.rotation_speed = 0
    tt.bullet.damage_max = 40
    tt.bullet.damage_min = 20
    tt.bullet.hide_radius = nil
    tt.bullet.mod = "mod_pirate_watchtower_bomb"
    tt.render.sprites[1].name = "pirateTower_bomb"
    tt.sound_events.insert = nil

    tt = RT("mod_pirate_watchtower_bomb", "mod_stun")
    tt.modifier.duration = 0.3

    tt = RT("tower_arcane", "tower")
    AC(tt, "attacks", "powers")
    image_y = 90
    tt.tower.type = "arcane"
    tt.tower.level = 1
    tt.tower.price = 220
    tt.tower.size = TOWER_SIZE_LARGE
    tt.info.enc_icon = 17
    tt.info.fn = scripts.tower_arcane.get_info
    tt.info.portrait = (IS_PHONE and "portraits_towers" or "kr3_info_portraits_towers") .. "_0009"
    tt.info.i18n_key = "TOWER_ARCANE_ARCHER"
    tt.powers.burst = CC("power")
    tt.powers.burst.price_base = 180
    tt.powers.burst.price_inc = 180
    tt.powers.burst.attack_idx = 2
    tt.powers.burst.enc_icon = 2
    tt.powers.slumber = CC("power")
    tt.powers.slumber.price_base = 225
    tt.powers.slumber.price_inc = 75
    tt.powers.slumber.enc_icon = 1
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrain_archer_%04i"
    tt.render.sprites[1].offset = vec_2(0, 10)
    tt.render.sprites[2] = CC("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "archer_towers_0004"
    tt.render.sprites[2].offset = vec_2(0, 33)
    tt.render.sprites[3] = CC("sprite")
    tt.render.sprites[3].prefix = "tower_arcane_shooter"
    tt.render.sprites[3].name = "idleDown"
    tt.render.sprites[3].angles = {}
    tt.render.sprites[3].angles.idle = {"idleUp", "idleDown"}
    tt.render.sprites[3].angles.shoot = {"shootUp", "shootDown"}
    tt.render.sprites[3].angles.special = {"specialUp", "specialDown"}
    tt.render.sprites[3].offset = vec_2(-9, 57)
    tt.render.sprites[4] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[4].offset.x = 9
    tt.render.sprites[5] = CC("sprite")
    tt.render.sprites[5].animated = false
    tt.render.sprites[5].name = "archer_arcane_top"
    tt.render.sprites[5].offset = vec_2(0, 33)
    tt.render.sprites[6] = CC("sprite")
    tt.render.sprites[6].name = "tower_arcane_bubbles"
    tt.render.sprites[6].offset = vec_2(-15, 17)
    tt.render.sprites[7] = table.deepclone(tt.render.sprites[6])
    tt.render.sprites[7].offset.x = 13
    tt.render.sprites[7].ts = fts(15)
    tt.main_script.update = scripts.tower_arcane.update
    tt.attacks.range = 200
    tt.attacks.list[1] = CC("bullet_attack")
    tt.attacks.list[1].animation = "shoot"
    tt.attacks.list[1].bullet = "arrow_arcane"
    tt.attacks.list[1].cooldown = 0.8
    tt.attacks.list[1].shoot_time = fts(4)
    tt.attacks.list[1].shooters_delay = 0.1
    tt.attacks.list[1].bullet_start_offset = {vec_2(9, 4), vec_2(6, -5)}
    tt.attacks.list[2] = table.deepclone(tt.attacks.list[1])
    tt.attacks.list[2].animation = "special"
    tt.attacks.list[2].bullet = "arrow_arcane_burst"
    tt.attacks.list[2].cooldown = 12
    tt.attacks.list[2].shoot_time = fts(13)
    tt.attacks.list[3] = table.deepclone(tt.attacks.list[1])
    tt.attacks.list[3].chance = 0
    tt.attacks.list[3].chance_base = 0.04
    tt.attacks.list[3].chance_inc = 0.02
    tt.attacks.list[3].animation = "special"
    tt.attacks.list[3].bullet = "arrow_arcane_slumber"
    tt.attacks.list[3].shoot_time = fts(13)
    tt.attacks.list[3].vis_bans = bor(F_BOSS)
    tt.attacks.list[3].vis_flags = bor(F_STUN)
    tt.sound_events.insert = "ElvesArcherArcaneTaunt"

    tt = RT("arrow_arcane", "arrow_1")
    tt.bullet.damage_max = 18
    tt.bullet.damage_min = 11
    tt.bullet.damage_type = DAMAGE_MIXED
    tt.bullet.miss_decal = "archer_arcane_proy2_decal-f"
    tt.bullet.mod = {"mod_arrow_arcane"}
    tt.bullet.hit_fx = "fx_arrow_arcane_hit"
    tt.bullet.pop = {"pop_arcane"}
    tt.render.sprites[1].name = "archer_arcane_proy2_0001-f"
    tt.bullet.flight_time_min = fts(10)
    tt.bullet.flight_time_factor = fts(5) * 1.8

    tt = RT("arrow_arcane_burst", "arrow_arcane")
    tt.bullet.flight_time_min = fts(14)
    tt.bullet.miss_decal = "archer_arcane_proy_decal-f"
    tt.bullet.mod = {"mod_arrow_arcane"}
    tt.bullet.particles_name = "ps_arrow_arcane_special"
    tt.bullet.payload = "aura_arcane_burst"
    tt.bullet.payload_props = {
        ["sleep_chance"] = 0
    }
    tt.sleep_chance = 0
    tt.render.sprites[1].name = "archer_arcane_proy_0001-f"
    tt.sound_events.insert = "TowerArcanePreloadAndTravel"

    tt = RT("aura_arcane_burst", "aura")
    AC(tt, "render")
    tt.aura.damage_inc = 80
    tt.aura.damage_type = DAMAGE_MAGICAL_EXPLOSION
    tt.aura.radius = 57.5
    tt.main_script.update = scripts.aura_arcane_burst.update
    tt.render.sprites[1].anchor.y = 0.2916666666666667
    tt.render.sprites[1].name = "arcane_burst_explosion"
    tt.render.sprites[1].sort_y_offset = -7
    tt.render.sprites[1].z = Z_EFFECTS
    tt.sound_events.insert = "TowerArcaneExplotion"

    tt = RT("arrow_arcane_slumber", "arrow_arcane")
    tt.bullet.damage_max = 36
    tt.bullet.damage_min = 22
    tt.bullet.flight_time_min = fts(14)
    tt.bullet.miss_decal = "archer_arcane_proy2_decal-f"
    tt.bullet.hit_fx = "fx_arcane_slumber_explosion"
    tt.bullet.mod = {"mod_arrow_arcane_slumber"}
    tt.bullet.particles_name = "ps_arrow_arcane_special"
    tt.render.sprites[1].name = "archer_arcane_proy_0001-f"
    tt.sound_events.insert = "TowerArcanePreloadAndTravel"

    tt = RT("mod_arrow_arcane", "mod_damage")
    tt.damage_min = 0.035
    tt.damage_max = 0.035
    tt.damage_type = DAMAGE_MAGICAL_ARMOR

    tt = RT("mod_arrow_arcane_slumber", "modifier")
    AC(tt, "render")
    tt.main_script.insert = scripts.mod_arrow_arcane_slumber.insert
    tt.main_script.update = scripts.mod_stun.update
    tt.main_script.remove = scripts.mod_stun.remove
    tt.sound_events.insert = "TowerArcaneWaterEnergyBlast"
    tt.modifier.duration = 2
    tt.render.sprites[1].prefix = "arcane_slumber_bubbles"
    tt.render.sprites[1].loop = true
    tt.render.sprites[2] = CC("sprite")
    tt.render.sprites[2].prefix = "arcane_slumber_z"
    tt.render.sprites[2].loop = true

    tt = RT("tower_silver", "tower")
    AC(tt, "attacks", "powers")
    image_y = 90
    tt.info.enc_icon = 18
    tt.tower.type = "silver"
    tt.tower.level = 1
    tt.tower.price = 250
    tt.tower.size = TOWER_SIZE_LARGE
    tt.attacks.range = 300
    tt.attacks.short_range = 162.5
    tt.attacks.list[1] = CC("bullet_attack")
    tt.attacks.list[1].animations = {"shoot", "shoot_long"}
    tt.attacks.list[1].bullet = "arrow_silver_long"
    tt.attacks.list[1].bullets = {"arrow_silver", "arrow_silver_long"}
    tt.attacks.list[1].cooldowns = {0.7, 1.5}
    tt.attacks.list[1].cooldown = 0.7
    tt.attacks.list[1].critical_chances = {0.01, 0.06}
    tt.attacks.list[1].shoot_times = {fts(6), fts(15)}
    tt.attacks.list[1].bullet_start_offsets = {{vec_2(9, 4), vec_2(6, -5)}, {vec_2(9, 4), vec_2(6, -5)}}
    -- tt.attacks.list[1].use_obsidian_upgrade = true
    tt.attacks.list[2] = CC("bullet_attack")
    tt.attacks.list[2].animations = {"sentence", "sentence"}
    tt.attacks.list[2].bullets = {"arrow_silver_sentence", "arrow_silver_sentence_long"}
    tt.attacks.list[2].chance = 0
    tt.attacks.list[2].cooldowns = {0.7, 1.25}
    tt.attacks.list[2].cooldown = 0.7
    tt.attacks.list[2].shoot_times = {fts(13), fts(13)}
    tt.attacks.list[2].bullet_start_offsets = {{vec_2(9, 4), vec_2(6, -5)}, {vec_2(9, 4), vec_2(6, -5)}}
    tt.attacks.list[2].vis_flags = bor(F_RANGED)
    tt.attacks.list[2].vis_bans = 0
    tt.attacks.list[2].shot_fx = "fx_arrow_silver_sentence_shot"
    tt.attacks.list[2].sound = "TowerGoldenBowInstakillArrowShot"
    -- tt.attacks.list[2].use_obsidian_upgrade = true
    tt.attacks.list[3] = CC("bullet_attack")
    tt.attacks.list[3].animations = {"mark", "mark_long"}
    tt.attacks.list[3].cooldown = 13
    tt.attacks.list[3].cooldown_inc = -1
    tt.attacks.list[3].bullets = {"arrow_silver_mark", "arrow_silver_mark_long"}
    tt.attacks.list[3].bullet_start_offsets = {{vec_2(9, 4), vec_2(6, -5)}, {vec_2(9, 4), vec_2(6, -5)}}
    tt.attacks.list[3].shoot_times = {fts(21), fts(21)}
    tt.attacks.list[3].sound = "TowerGoldenBowFlareShot"
    tt.attacks.list[3].sound_args = {
        delay = fts(15)
    }
    tt.info.portrait = (IS_PHONE and "portraits_towers" or "kr3_info_portraits_towers") .. "_0010"
    tt.info.fn = scripts.tower_silver.get_info
    tt.powers.sentence = CC("power")
    tt.powers.sentence.attack_idx = 2
    tt.powers.sentence.price_base = 250
    tt.powers.sentence.price_inc = 250
    tt.powers.sentence.chances = {{0.04, 0.07, 0.1}, {0.08, 0.14, 0.2}}
    tt.powers.sentence.enc_icon = 3
    tt.powers.mark = CC("power")
    tt.powers.mark.attack_idx = 3
    tt.powers.mark.price_base = 225
    tt.powers.mark.price_inc = 150
    tt.powers.mark.enc_icon = 4
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrain_archer_%04i"
    tt.render.sprites[1].offset = vec_2(0, 10)
    tt.render.sprites[2] = CC("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "archer_towers_0005"
    tt.render.sprites[2].offset = vec_2(0, 33)
    tt.render.sprites[3] = CC("sprite")
    tt.render.sprites[3].prefix = "tower_silver_shooter"
    tt.render.sprites[3].name = "idleDown"
    tt.render.sprites[3].angles = {}
    tt.render.sprites[3].angles.idle = {"idleUp", "idleDown"}
    tt.render.sprites[3].angles.shoot = {"shootShortUp", "shootShortDown"}
    tt.render.sprites[3].angles.shoot_long = {"shootUp", "shootDown"}
    tt.render.sprites[3].angles.mark = {"shootSpecialShortUp", "shootSpecialShortDown"}
    tt.render.sprites[3].angles.mark_long = {"shootSpecialUp", "shootSpecialDown"}
    tt.render.sprites[3].angles.sentence = {"instakillUp", "instakillDown"}
    tt.render.sprites[3].offset = vec_2(0, 62)
    tt.main_script.update = scripts.tower_silver.update
    tt.sound_events.insert = "ElvesArcherGoldenBowTaunt"

    tt = RT("arrow_silver", "arrow_1")
    tt.bullet.flight_time_min = fts(8.1)
    tt.bullet.flight_time_factor = fts(0.0135)
    tt.bullet.miss_decal = "archer_silver_proys_0002-f"
    tt.bullet.damage_max = 20
    tt.bullet.damage_min = 15
    tt.bullet.pop = {"pop_golden"}
    tt.bullet.pop_conds = DR_KILL
    tt.render.sprites[1].name = "archer_silver_proys_0001-f"
    tt.sound_events.insert = "TowerGoldenBowArrowShot"
    tt.main_script.update = scripts.arrow_missile.update
    tt.bullet.particles_name = "ps_arrow_silver"
    tt = RT("arrow_silver_long", "arrow_silver")
    tt.bullet.flight_time_factor = fts(0.0264)
    tt.bullet.damage_max = 60
    tt.bullet.damage_min = 45
    tt = RT("arrow_silver_sentence", "arrow_silver")
    tt.render.sprites[1].name = "archer_silver_instaKill_bullet"
    tt.bullet.g = 0
    tt.bullet.hit_fx = "fx_arrow_silver_sentence_hit"
    tt.bullet.flight_time_min = fts(3.6)
    tt.bullet.flight_time_factor = fts(0.009)
    tt.bullet.damage_type = bor(DAMAGE_FX_NOT_EXPLODE, DAMAGE_PHYSICAL, DAMAGE_IGNORE_SHIELD)
    tt.bullet.damage_max = 60
    tt.bullet.damage_min = 45
    tt.bullet.pop = {"pop_headshot"}
    tt.bullet.pop_conds = DR_KILL
    tt.main_script.update = scripts.arrow.update

    tt = RT("arrow_silver_sentence_long", "arrow_silver_sentence")
    tt = RT("arrow_silver_mark", "arrow_silver")
    tt.bullet.hit_fx = "fx_arrow_silver_mark_hit"
    tt.bullet.mod = "mod_arrow_silver_mark"
    tt.bullet.particles_name = "ps_arrow_silver_mark"
    tt.bullet.miss_decal = "archer_silver_proys_0004-f"
    tt.render.sprites[1].name = "archer_silver_proys_0003-f"
    tt.sound_events.insert = nil

    tt = RT("arrow_silver_mark_long", "arrow_silver_mark")
    tt.bullet.flight_time_factor = fts(0.033)
    tt.bullet.damage_max = 60
    tt.bullet.damage_min = 45

    tt = RT("ps_arrow_silver")
    AC(tt, "pos", "particle_system")
    tt.particle_system.names = {"arrow_silver_mark_particle_1", "arrow_silver_mark_particle_2"}
    tt.particle_system.loop = false
    tt.particle_system.cycle_names = true
    tt.particle_system.animated = true
    tt.particle_system.particle_lifetime = {fts(10), fts(10)}
    tt.particle_system.scales_y = {0.3, 0.1}
    tt.particle_system.scales_x = {1, 0.25}
    tt.particle_system.alphas = {255, 0}
    tt.particle_system.emission_rate = 60
    tt.particle_system.color = {255, 100, 100}

    tt = RT("ps_arrow_silver_mark")
    AC(tt, "pos", "particle_system")
    tt.particle_system.names = {"arrow_silver_mark_particle_1", "arrow_silver_mark_particle_2"}
    tt.particle_system.loop = false
    tt.particle_system.cycle_names = true
    tt.particle_system.animated = true
    tt.particle_system.particle_lifetime = {fts(10), fts(10)}
    tt.particle_system.scales_y = {0.85, 0.85}
    tt.particle_system.scales_x = {0.85, 0.85}
    tt.particle_system.emission_rate = 30

    tt = RT("mod_arrow_silver_mark", "modifier")
    AC(tt, "tween", "render", "sound_events", "count_group")
    tt.count_group.name = "mod_arrow_silver_mark"
    tt.count_group.type = COUNT_GROUP_CONCURRENT
    tt.received_damage_factor = 2
    tt.main_script.insert = scripts.mod_arrow_silver_mark.insert
    tt.main_script.update = scripts.mod_arrow_silver_mark.update
    tt.main_script.remove = scripts.mod_arrow_silver_mark.remove
    tt.modifier.durations = {5, 6, 7}
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "archer_silver_mark_effect_below"
    tt.render.sprites[1].sort_y_offset = 1
    tt.render.sprites[1].anchor.y = 0.08823529411764706
    tt.render.sprites[2] = CC("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "archer_silver_mark_effect_over"
    tt.render.sprites[2].anchor.y = 0.08823529411764706
    tt.render.sprites[2].sort_y_offset = -1
    tt.tween.remove = false
    tt.tween.props[1].name = "scale"
    tt.tween.props[1].keys = {{0, vec_2(1, 1)}, {fts(6), vec_2(0.87, 1)}, {fts(11), vec_2(1, 1)}}
    tt.tween.props[1].sprite_id = 1
    tt.tween.props[1].loop = true
    tt.tween.props[2] = table.deepclone(tt.tween.props[1])
    tt.tween.props[2].sprite_id = 2
    tt.tween.props[3] = CC("tween_prop")
    tt.tween.props[3].disabled = true
    tt.tween.props[3].sprite_id = 1
    tt.tween.props[3].keys = {{0, 255}, {0.25, 0}}
    tt.tween.props[4] = table.deepclone(tt.tween.props[3])
    tt.tween.props[4].sprite_id = 1
    tt.sound_events.insert = "TowerGoldenBowFlareHit"

    -- 暮光长弓
    local balance = require("kr1.data.balance")
    tt = RT("tower_build_dark_elf", "tower_build")
    tt.build_name = "tower_dark_elf_lvl1"
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)
    tt.render.sprites[2].name = "Tower_construction"
    tt.render.sprites[2].offset = vec_2(0, 10)
    tt.render.sprites[3].offset.y = 75
    tt.render.sprites[4].offset.y = 75

    tt = RT("tower_dark_elf_lvl4", "tower")
    AC(tt, "powers", "barrack", "attacks")
    local b = balance.towers.dark_elf
    tt.is_kr5 = true
    tt.tower.level = 1
    tt.tower.type = "dark_elf"
    tt.tower.price = b.price[4]
    tt.info.i18n_key = "TOWER_DARK_ELF_4"
    tt.info.fn = scripts.tower_dark_elf.get_info
    tt.info.portrait = "portraits_towers_0020"
    tt.info.enc_icon = 1
    tt.info.tower_portrait = "tower_room_portraits_big_tower_dark_elf_0001"
    tt.info.room_portrait = "quickmenu_main_icons_main_icons_0018_0001"
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_cooldown = b.stats.cooldown
    tt.info.stat_range = b.stats.range
    tt.main_script.update = scripts.tower_dark_elf.update
    tt.main_script.remove = scripts.tower_dark_elf.remove
    tt.main_script.insert = scripts.tower_dark_elf.insert
    tt.ui.click_rect = r(-38, -10, 70, 60)
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrain_artillery_%04i"
    tt.render.sprites[1].offset = vec_2(0, 10)
    tt.render.sprites[2] = CC("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "Tower_lvl4"
    tt.render.sprites[2].sort_y_offset = 11
    tt.render.sprites[3] = CC("sprite")
    tt.render.sprites[3].prefix = "Archer_lvl4"
    tt.render.sprites[3].name = "idle"
    tt.render.sprites[3].angles = {}
    tt.render.sprites[3].angles.idle = {
        "idleback",
        "idle"
    }
    tt.render.sprites[3].angles.shot_prepare = {
        "shootbackstart",
        "shootstart"
    }
    tt.render.sprites[3].angles.shot = {
        "shootbackhigher",
        "shootbackhigher",
        "shootlower",
        "shoothigher"
    }
    tt.render.sprites[3].angles.shot_end = {
        "transitionback",
        "transition"
    }
    tt.render.sprites[3].offset = vec_2(0, 48)
    tt.render.sprites[3].fps = 36
    tt.render.sid_archer = 3
    tt.attacks.range = b.basic_attack.range[4]
    tt.attacks.list[1] = CC("bullet_attack")
    tt.attacks.list[1].cooldown = b.basic_attack.cooldown
    -- exactly, cooldown only based on the animation time 3.38 * 5 / 6 = 2.8166, bigger than this cooldown assigned
    -- tt.attacks.list[1].shoot_time = fts(13)
    tt.attacks.list[1].shoot_time = fts(65 / 6)
    tt.attacks.list[1].vis_flags = bor(F_RANGED)
    tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
    tt.attacks.list[1].node_prediction_prepare = fts(60)
    tt.attacks.list[1].node_prediction = fts(15)
    tt.attacks.list[1].bullet = "bullet_tower_dark_elf_lvl4"
    tt.attacks.list[1].bullet_start_offset = {
        vec_2(18, 86),
        vec_2(18, 86),
        vec_2(18, 76),
        vec_2(18, 86)
    }
    tt.attacks.list[1].first_cooldown = 2
    tt.attacks.list[1].mod_target = "mod_tower_dark_elf_big_target"
    tt.tower_upgrade_persistent_data.current_mode = 0
    tt.tower_upgrade_persistent_data.max_current_mode = 1
    tt.tower_upgrade_persistent_data.souls_extra_damage_min = 0
    tt.tower_upgrade_persistent_data.souls_extra_damage_max = 0
    tt.powers.skill_soldiers = CC("power")
    tt.powers.skill_soldiers.price_base = 225
    tt.powers.skill_soldiers.price_inc = 100
    tt.powers.skill_soldiers.cooldown = b.skill_soldiers.cooldown
    tt.powers.skill_soldiers.hp = b.soldier.hp
    tt.powers.skill_soldiers.damage_min = b.soldier.basic_attack.damage_min
    tt.powers.skill_soldiers.damage_max = b.soldier.basic_attack.damage_max
    tt.powers.skill_soldiers.dodge_chance = b.soldier.dodge_chance
    tt.powers.skill_soldiers.enc_icon = 31
    tt.powers.skill_soldiers.show_rally = true
    tt.powers.skill_buff = CC("power")
    tt.powers.skill_buff.price_base = 250
    tt.powers.skill_buff.enc_icon = 32
    tt.powers.skill_buff.damage_min = b.skill_buff.extra_damage_min
    tt.powers.skill_buff.damage_max = b.skill_buff.extra_damage_max
    tt.powers.skill_buff.max_level = 1
    tt.barrack.rally_range = b.rally_range
    tt.barrack.rally_radius = 25
    tt.barrack.soldier_type = "soldier_tower_dark_elf"
    tt.barrack.max_soldiers = 2
    tt.barrack.respawn_offset = vec_2(0, 0)
    tt.attacks.list[2] = CC("custom_attack")
    tt.attacks.list[2].disabled = true
    tt.attacks.list[2].spawn_delay = 1
    tt.controller_soldiers_template = "controller_tower_dark_elf_soldiers"
    tt.sound_events.change_rally_point = "TowerDarkElfUnitTaunt"

    tt = RT("soldier_tower_dark_elf", "soldier_militia")
    AC(tt, "nav_grid", "dodge")
    b = balance.towers.dark_elf.soldier
    tt.is_kr5 = true
    tt.info.portrait = "gui_bottom_info_image_soldiers_0045"
    tt.info.random_name_count = 9
    tt.info.random_name_format = "SOLDIER_TOWER_DARK_ELF_%i_NAME"
    tt.main_script.update = scripts.soldier_barrack.update
    tt.main_script.insert = scripts.soldier_barrack.insert
    tt.render.sprites[1].prefix = "harrasser"
    tt.render.sprites[1].angles.walk = {
        "run"
    }
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.unit.hit_offset = vec_2(0, 12)
    tt.unit.marker_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, 13)
    tt.health.hp_max = b.hp[1]
    tt.health.armor = b.armor[1]
    tt.health_bar.offset = vec_2(0, 30)
    tt.health.dead_lifetime = b.dead_lifetime
    tt.motion.max_speed = b.speed
    tt.melee.range = b.basic_attack.range
    tt.melee.cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].animation = "attack"
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min[1]
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max[1]
    tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
    tt.melee.attacks[1].hit_time = fts(17)
    tt.melee.attacks[1].shared_cooldown = true
    tt.melee.attacks[1].never_interrupt = true
    tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
    tt.melee.attacks[2].animation = "attack2"
    tt.melee.attacks[2].shared_cooldown = true
    tt.melee.attacks[2].chance = 0.5
    tt.soldier.melee_slot_spread = vec_2(-8, -8)
    tt.dodge.chance = b.dodge_chance[1]
    tt.dodge.animation = "evade"
    tt.dodge.time_before_hit = fts(5)
    tt.dodge.sound = "HeroVesperDisengageCast"
    tt.ui.click_rect = r(-10, -2, 20, 25)

    tt = RT("bullet_tower_dark_elf", "bullet")
    b = balance.towers.dark_elf.basic_attack
    tt.bullet.hit_fx = "fx_bullet_tower_dark_elf_hit"
    tt.bullet.flight_time = fts(23)
    tt.bullet.hit_time = fts(1)
    tt.bullet.damage_type = b.damage_type
    tt.bullet.level = 1
    tt.main_script.update = scripts.bullet_tower_dark_elf.update
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].name = "shot_run"
    tt.render.sprites[1].loop = false
    tt.image_width = 170
    tt.ray_duration = fts(23)
    tt.hit_delay = fts(1)
    tt.bullet.reduce_armor = 0.1
    tt.sound_events.insert = "TowerDarkElfBasicAttackCast"

    tt = RT("bullet_tower_dark_elf_lvl4", "bullet_tower_dark_elf")
    b = balance.towers.dark_elf.basic_attack
    tt.bullet.damage_max = b.damage_max[4]
    tt.bullet.damage_min = b.damage_min[4]
    tt.skill_buff_mod = "mod_tower_dark_elf_skill_buff"

    tt = RT("fx_bullet_tower_dark_elf_hit", "fx")
    tt.render.sprites[1].name = "shotexplosion_run"

    tt = RT("bullet_tower_dark_elf_skill_buff", "bullet")
    AC(tt, "tween")
    tt.main_script.insert = scripts.bullet_tower_dark_elf_skill_buff.insert
    tt.main_script.update = scripts.bullet_tower_dark_elf_skill_buff.update
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].loop = false
    tt.bullet.acceleration_factor = 0.1
    tt.bullet.min_speed = 25
    tt.bullet.max_speed = 450
    tt.bullet.ignore_hit_offset = true
    tt.bullet.ignore_rotation = true
    tt.bullet.hit_fx = "fx_tower_dark_elf_skill_buff"
    tt.tween.props[1].keys = {
        {
            0,
            255
        },
        {
            fts(7),
            0
        }
    }
    tt.tween.remove = true
    tt.tween.reverse = false
    tt.tween.disabled = true
    tt.sound_start = "TowerDarkElfThrillOfTheHuntCast"
    tt._parent = true

    tt = RT("fx_tower_dark_elf_skill_buff", "fx")
    tt.render.sprites[1].name = "souldrain_run"
    tt.render.sprites[1].offset.y = 25

    tt = RT("mod_tower_dark_elf_skill_buff", "modifier")
    tt.modifier.duration = fts(3)
    tt.main_script.update = scripts.mod_track_target.update
    tt.main_script.remove = scripts.mod_tower_dark_elf_skill_buff.remove
    tt.skill_buff_bullet = "bullet_tower_dark_elf_skill_buff"
    tt.tower_offset = vec_2(0, 35)

    tt = RT("mod_tower_dark_elf_big_target", "modifier")
    AC(tt, "render")
    tt.main_script.update = scripts.mod_tower_dark_elf_big_target.update
    tt.modifier.use_mod_offset = true
    tt.modifier.duration = fts(60) + fts(13) + fts(2)
    tt.render.sprites[1].prefix = "twilight_longbows_tower_mira"
    tt.render.sprites[1].draw_order = DO_MOD_FX

    tt = RT("controller_tower_dark_elf_soldiers")
    AC(tt, "render", "main_script", "pos")
    tt.render.sprites[1].prefix = "Tower_lvl4_door"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].hidden = true
    tt.render.sprites[1].sort_y_offset = 10
    tt.main_script.update = scripts.controller_tower_dark_elf_soldiers.update
    tt.main_script.remove = scripts.controller_tower_dark_elf_soldiers.remove
    tt.spawn_delay = 1
    tt.check_soldiers_cooldown = fts(10)
    tt.sound_open = "TowerDarkElfSupportBladesSpawn"
end

return archer_towers
