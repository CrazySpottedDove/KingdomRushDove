-- chunkname: @./all/templates.lua
local bit = require("bit")
local bor = bit.bor
local band = bit.band
local bnot = bit.bnot
local E = require("entity_db")
local i18n = require("i18n")

require("constants")

local scale_scale = TEXTURE_SIZE_ALIAS.ipad / TEXTURE_SIZE_ALIAS.fullhd
local features = require("features")
local anchor_y = 0
local image_y = 0
local tt
local scripts = require("scripts")
local game_scripts = require("game_scripts")
local IS_PHONE = KR_TARGET == "phone"
local IS_PHONE_OR_TABLET = KR_TARGET == "phone" or KR_TARGET == "tablet"
local IS_KR1 = KR_GAME == "kr1"
local IS_KR2 = KR_GAME == "kr2"
local IS_KR3 = KR_GAME == "kr3"

local function v(v1, v2)
    return {
        x = v1,
        y = v2
    }
end

local function vv(v1)
    return {
        x = v1,
        y = v1
    }
end

local function r(x, y, w, h)
    return {
        pos = v(x, y),
        size = v(w, h)
    }
end

local function fts(v)
    return v / FPS
end

local function ady(v)
    return v - anchor_y * image_y
end

local function np(pi, spi, ni)
    return {
        dir = 1,
        pi = pi,
        spi = spi,
        ni = ni
    }
end

local damage = E:register_t("damage", E:get_component("damage"))
local decal = E:register_t("decal")

E:add_comps(decal, "pos", "render")

local decal_timed = E:register_t("decal_timed", "decal")

E:add_comps(decal_timed, "timed")

decal_timed.render.sprites[1].loop = false

local decal_tween = E:register_t("decal_tween", "decal")

E:add_comps(decal_tween, "tween")

decal_tween.tween.remove = true

local decal_scripted = E:register_t("decal_scripted", "decal")

E:add_comps(decal_scripted, "main_script")

tt = E:register_t("decal_static", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].scale = v(1, 1)
tt.editor.props = {{"render.sprites[1].name", PT_STRING}, {"render.sprites[1].scale", PT_COORDS},
                   {"render.sprites[1].r", PT_NUMBER, math.pi / 180}}
tt = E:register_t("decal_loop", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].random_ts = 1
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].scale = v(1, 1)
tt.editor.props = {{"render.sprites[1].name", PT_STRING}, {"render.sprites[1].scale", PT_COORDS},
                   {"render.sprites[1].r", PT_NUMBER, math.pi / 180}}
tt = E:register_t("decal_delayed_play", "decal")

E:add_comps(tt, "main_script", "delayed_play", "editor")

tt.render.sprites[1].loop = false
tt.render.sprites[1].scale = v(1, 1)
tt.main_script.update = scripts.delayed_play.update
tt.editor.props = {{"render.sprites[1].r", PT_NUMBER, math.pi / 180}, {"render.sprites[1].scale", PT_COORDS},
                   {"delayed_play.min_delay", PT_NUMBER}, {"delayed_play.max_delay", PT_NUMBER}}
tt.editor.overrides = {
    ["render.sprites[1].hidden"] = false,
    ["render.sprites[1].loop"] = true
}
tt = E:register_t("decal_delayed_click_play", "decal")

E:add_comps(tt, "main_script", "delayed_play", "ui")

tt.render.sprites[1].loop = false
tt.main_script.update = scripts.delayed_play.update
tt.ui.can_click = true
tt = E:register_t("decal_click_play", "decal")

E:add_comps(tt, "main_script", "click_play", "ui")

tt.render.sprites[1].loop = false
tt.main_script.update = scripts.click_play.update
tt.ui.can_click = true
tt = E:register_t("decal_click_pause", "decal")

E:add_comps(tt, "main_script", "ui")

tt.main_script.update = scripts.click_pause.update
tt.ui.can_click = true
tt = E:register_t("decal_sequence", "decal")

E:add_comps(tt, "main_script", "sequence")

tt.main_script.update = scripts.sequence.update
tt.render.sprites[1].loop = false
tt = E:register_t("decal_delayed_sequence", "decal")

E:add_comps(tt, "main_script", "delayed_sequence")

tt.main_script.update = scripts.delayed_sequence.update
tt.render.sprites[1].loop = false
tt = E:register_t("decal_background", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].animated = false
tt.pos = v(REF_W * 0.5, REF_H * 0.5)
tt.editor.props = {{"render.sprites[1].name", PT_STRING}, {"render.sprites[1].z", PT_NUMBER, 1},
                   {"render.sprites[1].sort_y", PT_NUMBER, 1}}
tt = E:register_t("decal_defend_point", "decal_tween")

E:add_comps(tt, "main_script", "editor")

tt.main_script.insert = scripts.decal_defend_point.insert
tt.tween.remove = false
tt.tween.props[1].keys = {{2, 255}, {5, 0}}
tt.tween.props[1].sprite_id = 2
tt.render.sprites[1].name = "defendFlag_0069"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "defendFlag_0060"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.editor.exit_id = 1
tt.editor.props = {{"editor.exit_id", PT_NUMBER}}

local tt = E:register_t("decal_defense_flag", "decal")

E:add_comps(tt, "editor")

tt.editor.tag = 0
tt.editor.props = {{"editor.tag", PT_NUMBER}}
tt.render.sprites[1].name = "DefenseFlag"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.5, 0.17)

local tt = E:register_t("decal_defense_flag_water", "decal")

tt.render.sprites[1].name = "decal_defense_flag_water"
tt.render.sprites[1].anchor = v(0.5, 0.12962962962962962)

local decal_bomb_crater = E:register_t("decal_bomb_crater", "decal_tween")

decal_bomb_crater.tween.props[1].keys = {{1, 255}, {2.5, 0}}
decal_bomb_crater.render.sprites[1].name = "decal_bomb_crater"
decal_bomb_crater.render.sprites[1].animated = false
tt = E:register_t("decal_ground_hit", "decal_timed")
tt.render.sprites[1].name = "ground_hit_decal"
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_entity_marker_small", "decal")
tt.render.sprites[1].name = "selected_small"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].animated = false
tt = E:register_t("decal_entity_marker_med", "decal_entity_marker_small")
tt.render.sprites[1].name = "selected_med"
tt = E:register_t("decal_entity_marker_big", "decal_entity_marker_small")
tt.render.sprites[1].name = "selected_big"
tt = E:register_t("decal_entity_marker_soldier_small", "decal_entity_marker_small")
tt.render.sprites[1].name = "selected_soldier_small"
tt = E:register_t("entity_marker_controller")

E:add_comps(tt, "main_script")

tt.main_script.insert = scripts.entity_marker_controller.insert
tt.main_script.update = scripts.entity_marker_controller.update
tt.target = nil
tt.done = nil
tt = E:register_t("clickable_hover_controller")

E:add_comps(tt, "main_script", "render", "tween")

tt.main_script.insert = scripts.clickable_hover_controller.insert
tt.main_script.update = scripts.clickable_hover_controller.update
tt.main_script.remove = scripts.clickable_hover_controller.remove
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_TOWER_BASES - 1
tt.render.sprites[1].draw_order = -1
tt.tween.props[1].keys = {{0, HOVER_PULSE_ALPHA_MAX_INGAME}, {HOVER_PULSE_PERIOD * 0.5, HOVER_PULSE_ALPHA_MIN_INGAME},
                          {HOVER_PULSE_PERIOD, HOVER_PULSE_ALPHA_MAX_INGAME}}
tt.tween.props[1].loop = true
tt.tween.remove = false
tt.target = nil
tt.done = nil
tt = E:register_t("decal_rally_range", "decal")
tt.actual_radius = 137
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "rally_circle"
tt.render.sprites[1].anchor = v(1, 0)
tt.render.sprites[1].scale = v(1, 1)
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].scale = v(-1, 1)
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].scale = v(1, -1)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[4].scale = v(-1, -1)
tt = E:register_t("decal_tower_range", "decal_rally_range")
tt.render.sprites[1].name = "range_circle"
tt.render.sprites[2].name = "range_circle"
tt.render.sprites[3].name = "range_circle"
tt.render.sprites[4].name = "range_circle"

local decal_hero_tombstone = E:register_t("decal_hero_tombstone", "decal")

decal_hero_tombstone.render.sprites[1].animated = false
decal_hero_tombstone.render.sprites[1].name = "hero_death_0039"
decal_hero_tombstone.render.sprites[1].anchor = v(0.5, 0.16)
decal_hero_tombstone.render.sprites[1].z = Z_OBJECTS

local spell = E:register_t("spell")

E:add_comps(spell, "spell", "main_script")

local bullet = E:register_t("bullet")
E:add_comps(bullet, "bullet", "pos", "render", "sound_events", "main_script")
bullet.render.sprites[1].z = Z_BULLETS
bullet.bullet.vis_flags = F_RANGED

local arrow = E:register_t("arrow", "bullet")
arrow.bullet.hit_distance = 22
arrow.bullet.hit_blood_fx = "fx_blood_splat"
arrow.bullet.miss_decal = "decal_arrow"
arrow.bullet.miss_fx_water = "fx_splash_small"
arrow.bullet.flight_time = fts(22)
arrow.bullet.damage_type = DAMAGE_PHYSICAL
arrow.bullet.pop = {"pop_shunt", "pop_oof"}
arrow.bullet.pop_chance = 1
arrow.bullet.pop_conds = DR_KILL
arrow.bullet.vis_flags = F_RANGED
arrow.render.sprites[1].name = "arrow"
arrow.render.sprites[1].animated = false
arrow.main_script.insert = scripts.arrow.insert
arrow.main_script.update = scripts.arrow.update
arrow.sound_events.insert = "ArrowSound"
arrow.bullet.predict_target_pos = true
arrow.bullet.hide_radius = 6

local arrow_legionnaire = E:register_t("arrow_legionnaire", "arrow")

arrow_legionnaire.bullet.flight_time = fts(20)
arrow_legionnaire.bullet.damage_min = 15
arrow_legionnaire.bullet.damage_max = 30

local shotgun = E:register_t("shotgun", "bullet")

shotgun.main_script.insert = scripts.shotgun.insert
shotgun.main_script.update = scripts.shotgun.update
shotgun.render.sprites[1].name = "bullet"
shotgun.render.sprites[1].animated = false
shotgun.bullet.pop = {"pop_aack"}
shotgun.bullet.pop_chance = 1
shotgun.bullet.pop_conds = DR_KILL
shotgun.bullet.max_track_distance = REF_H / 6
shotgun.bullet.hide_radius = 25
shotgun.bullet.vis_flags = F_RANGED
local bomb = E:register_t("bomb", "bullet")

E:add_comps(bomb, "sound_events")

bomb.bullet.flight_time = fts(31)
bomb.bullet.rotation_speed = 20 * FPS * math.pi / 180
bomb.bullet.hit_fx = "fx_explosion_small"
bomb.bullet.hit_decal = "decal_bomb_crater"
bomb.bullet.hit_fx_water = "fx_explosion_water"
bomb.bullet.damage_type = DAMAGE_EXPLOSION
bomb.bullet.damage_min = 9
bomb.bullet.damage_max = 17
bomb.bullet.damage_radius = 62.400000000000006
bomb.bullet.pop = {"pop_kboom"}
bomb.bullet.damage_flags = F_AREA
bomb.bullet.hide_radius = 8
bomb.render.sprites[1].name = "bombs_0001"
bomb.render.sprites[1].animated = false
bomb.main_script.insert = scripts.bomb.insert
bomb.main_script.update = scripts.bomb.update
bomb.sound_events.insert = "BombShootSound"
bomb.sound_events.hit = "BombExplosionSound"
bomb.sound_events.hit_water = "RTWaterExplosion"

local bomb_dynamite = E:register_t("bomb_dynamite", "bomb")

bomb_dynamite.render.sprites[1].name = "bombs_0002"
bomb_dynamite.bullet.damage_min = 22
bomb_dynamite.bullet.damage_max = 44
bomb_dynamite.bullet.damage_radius = 62.400000000000006

local bomb_black = E:register_t("bomb_black", "bomb")

bomb_black.render.sprites[1].name = "bombs_0003"
bomb_black.bullet.align_with_trajectory = true
bomb_black.bullet.damage_min = 33
bomb_black.bullet.damage_max = 66
bomb_black.bullet.damage_radius = 67.2
tt = E:register_t("bolt", "bullet")
tt.main_script.insert = scripts.bolt.insert
tt.main_script.update = scripts.bolt.update
tt.render.sprites[1].prefix = "bolt"
tt.render.sprites[1].anchor = v(0.4875, 0.4423076923076923)
tt.bullet.acceleration_factor = 0.05
tt.bullet.min_speed = 30
tt.bullet.max_speed = 300
tt.bullet.max_track_distance = REF_H / 6
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.hit_fx = "fx_bolt_hit"
tt.bullet.pop = {"pop_zap"}
tt.bullet.pop_conds = DR_KILL
tt.sound_events.insert = "BoltSound"
tt = E:register_t("bolt_enemy", "bolt")
tt.main_script.insert = scripts.bolt_enemy.insert
tt.main_script.update = scripts.bolt_enemy.update
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.damage_type = DAMAGE_MAGICAL

local fx = E:register_t("fx")

E:add_comps(fx, "pos", "render", "timed")

fx.timed.runs = 1
fx.render.sprites[1].loop = false
fx.render.sprites[1].z = Z_EFFECTS

local fx5 = E:register_t("fx5", "fx")

local fx_fade = E:register_t("fx_fade")

E:add_comps(fx_fade, "pos", "render", "tween")

fx_fade.render.sprites[1].loop = false
fx_fade.render.sprites[1].z = Z_EFFECTS
fx_fade.tween.props[1].keys = {{0.5, 255}, {1.5, 0}}

local fx_unit_explode = E:register_t("fx_unit_explode", "fx")

fx_unit_explode.render.sprites[1].prefix = "explode"
fx_unit_explode.render.sprites[1].name = "small"
fx_unit_explode.render.sprites[1].size_names = {"small", "big", "big"}
fx_unit_explode.render.sprites[1].anchor.y = 0.22
fx_unit_explode.render.sprites[1].z = Z_OBJECTS
fx_unit_explode.render.sprites[1].draw_order = 1

local fx_soldier_desintegrate = E:register_t("fx_soldier_desintegrate", "fx")

fx_soldier_desintegrate.render.sprites[1].name = "desintegrate_soldier"
fx_soldier_desintegrate.render.sprites[1].anchor.y = 0.24
fx_soldier_desintegrate.render.sprites[1].z = Z_OBJECTS
fx_soldier_desintegrate.render.sprites[1].draw_order = 1

local fx_enemy_desintegrate = E:register_t("fx_enemy_desintegrate", "fx_fade")

fx_enemy_desintegrate.render.sprites[1].prefix = "desintegrate_enemy"
fx_enemy_desintegrate.render.sprites[1].name = "small"
fx_enemy_desintegrate.render.sprites[1].anchor.y = 0.22
fx_enemy_desintegrate.render.sprites[1].size_names = {"small", "small", "big"}
fx_enemy_desintegrate.render.sprites[1].draw_order = 1
fx_enemy_desintegrate.render.sprites[1].z = Z_OBJECTS

local fx_enemy_desintegrate_air = E:register_t("fx_enemy_desintegrate_air", "fx")

fx_enemy_desintegrate_air.render.sprites[1].prefix = "desintegrate_enemy_air"
fx_enemy_desintegrate_air.render.sprites[1].name = "small"
fx_enemy_desintegrate_air.render.sprites[1].anchor.y = 0.36923076923076925
fx_enemy_desintegrate_air.render.sprites[1].draw_order = 1
fx_enemy_desintegrate_air.render.sprites[1].z = Z_OBJECTS

local fx_spider_explode = E:register_t("fx_spider_explode", "fx")

fx_spider_explode.render.sprites[1].prefix = "spider_explode"
fx_spider_explode.render.sprites[1].name = "small"
fx_spider_explode.render.sprites[1].offset = v(0, 12)
fx_spider_explode.render.sprites[1].size_names = {"small", "small", "big"}
fx_spider_explode.render.sprites[1].draw_order = 1
fx_spider_explode.render.sprites[1].z = Z_OBJECTS

local decal_blood_pool = E:register_t("decal_blood_pool", "decal_tween")

decal_blood_pool.tween.props[1].keys = {{1, 255}, {5, 0}}
decal_blood_pool.render.sprites[1].prefix = "blood_pool"
decal_blood_pool.render.sprites[1].name = "red"
decal_blood_pool.render.sprites[1].z = Z_DECALS

local fx_bleeding = E:register_t("fx_bleeding", "fx")

fx_bleeding.render.sprites[1].prefix = "bleeding"
fx_bleeding.render.sprites[1].name = "big_red"
fx_bleeding.render.sprites[1].size_names = {"small", "big", "big"}
fx_bleeding.render.sprites[1].use_blood_color = true
fx_bleeding.render.sprites[1].z = Z_OBJECTS
fx_bleeding.render.sprites[1].draw_order = 20

local fx_blood_splat = E:register_t("fx_blood_splat", "fx")

E:add_comps(fx_blood_splat, "sound_events")

fx_blood_splat.render.sprites[1].prefix = "blood_splat"
fx_blood_splat.render.sprites[1].name = "red"
fx_blood_splat.render.sprites[1].anchor.x = 0.42857142857142855
fx_blood_splat.use_blood_color = true
fx_blood_splat.sound_events.insert = "HitSound"

local fx_explosion_big = E:register_t("fx_explosion_big", "fx")

fx_explosion_big.render.sprites[1].prefix = "explosion"
fx_explosion_big.render.sprites[1].name = "big"
fx_explosion_big.render.sprites[1].anchor.y = 0.13
fx_explosion_big.render.sprites[1].z = Z_OBJECTS
fx_explosion_big.render.sprites[1].sort_y_offset = -2

local fx_explosion_small = E:register_t("fx_explosion_small", "fx_explosion_big")

fx_explosion_small.render.sprites[1].scale = v(0.9, 0.9)

local fx_explosion_fragment = E:register_t("fx_explosion_fragment", "fx")

fx_explosion_fragment.render.sprites[1].prefix = "explosion"
fx_explosion_fragment.render.sprites[1].name = "fragment"
fx_explosion_fragment.render.sprites[1].anchor.y = 0.13
fx_explosion_fragment.render.sprites[1].z = Z_OBJECTS
fx_explosion_fragment.render.sprites[1].sort_y_offset = -2

local fx_explosion_air = E:register_t("fx_explosion_air", "fx")

fx_explosion_air.render.sprites[1].prefix = "explosion"
fx_explosion_air.render.sprites[1].name = "air"

local fx_explosion_water = E:register_t("fx_explosion_water", "fx")

fx_explosion_water.render.sprites[1].prefix = "explosion"
fx_explosion_water.render.sprites[1].name = "water"
fx_explosion_water.render.sprites[1].anchor.y = 0.2
fx_explosion_water.render.sprites[1].z = Z_OBJECTS
fx_explosion_water.render.sprites[1].sort_y_offset = -2

local fx_splash_small = E:register_t("fx_splash_small", "fx")

fx_splash_small.render.sprites[1].prefix = "water_splash"
fx_splash_small.render.sprites[1].name = "small"
fx_splash_small.render.sprites[1].anchor.y = 0.286

local fx_enemy_splash = E:register_t("fx_enemy_splash", "fx")

fx_enemy_splash.render.sprites[1].prefix = "enemy_water_splash"
fx_enemy_splash.render.sprites[1].name = "small"
fx_enemy_splash.render.sprites[1].size_names = {"small", "small", "big"}
fx_enemy_splash.render.sprites[1].anchor.y = 0.23684210526315788
fx_enemy_splash.render.sprites[1].z = Z_OBJECTS
fx_enemy_splash.render.sprites[1].sort_y_offset = -8

local fx_smoke_bullet = E:register_t("fx_smoke_bullet", "fx")

fx_smoke_bullet.render.sprites[1].prefix = "smoke"
fx_smoke_bullet.render.sprites[1].name = "bullet"
fx_smoke_bullet.render.sprites[1].anchor.y = 0
tt = E:register_t("fx_rifle_smoke", "fx")
tt.render.sprites[1].name = "fx_rifle_smoke"
tt.render.sprites[1].anchor = v(-0.2, 0.5)

local fx_tower_buy_dust = E:register_t("fx_tower_buy_dust", "fx")

fx_tower_buy_dust.render.sprites[1].name = "tower_build_dust"

local fx_tower_sell_dust = E:register_t("fx_tower_sell_dust", "fx")

fx_tower_sell_dust.render.sprites[1].name = "tower_sell_dust"

local fx_bolt_hit = E:register_t("fx_bolt_hit", "fx")

fx_bolt_hit.render.sprites[1].name = "bolt_hit"

local fx_coin_jump = E:register_t("fx_coin_jump", "fx")

E:add_comps(fx_coin_jump, "tween", "sound_events")

fx_coin_jump.render.sprites[1].name = "fx_coin_jump"
fx_coin_jump.render.sprites[1].z = Z_BULLETS
fx_coin_jump.render.sprites[1].offset.y = 40
fx_coin_jump.tween.props[1].name = "alpha"
fx_coin_jump.tween.props[1].keys = {{0, 255}, {0.5, 255}, {0.8, 0}}
fx_coin_jump.sound_events.insert = "AssassinGold"
tt = E:register_t("fx_ground_hit", "fx")
tt.render.sprites[1].name = "ground_hit_smoke"
tt.render.sprites[1].anchor.y = 0.27
tt = E:register_t("fx_coin_shower", "decal_scripted")
tt.main_script.update = scripts.fx_coin_shower.update
tt.coin_count = 10
tt.coin_delay = fts(5)
tt.coin_fx = "fx_coin_jump"
tt.coin_tween_time = {fts(7), fts(10)}
tt.coin_tween_x_offset = {13, 25}

local modifier = E:register_t("modifier")
E:add_comps(modifier, "pos", "modifier", "sound_events", "main_script")

tt = E:register_t("mod_blood", "modifier")
E:add_comps(tt, "dps")
tt.modifier.level = 1
tt.modifier.duration = 3
tt.modifier.vis_flags = F_BLOOD
tt.dps.damage_min = 10
tt.dps.damage_max = 10
tt.dps.damage_inc = 15
tt.dps.damage_every = 1
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.fx = "fx_bleeding"
tt.dps.fx_with_blood_color = true
tt.dps.fx_target_flip = true
tt.dps.fx_tracks_target = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_blood.update

local mod_poison = E:register_t("mod_poison", "modifier")
E:add_comps(mod_poison, "dps", "render")
mod_poison.modifier.duration = 5
mod_poison.modifier.vis_flags = F_POISON
mod_poison.modifier.type = MOD_TYPE_POISON
mod_poison.render.sprites[1].prefix = "poison"
mod_poison.render.sprites[1].size_names = {"small", "big", "big"}
mod_poison.render.sprites[1].name = "small"
mod_poison.render.sprites[1].draw_order = 2
mod_poison.dps.damage_min = 3
mod_poison.dps.damage_max = 3
mod_poison.dps.damage_type = DAMAGE_POISON
mod_poison.dps.damage_every = fts(3)
mod_poison.dps.kill = false
mod_poison.main_script.insert = scripts.mod_dps.insert
mod_poison.main_script.update = scripts.mod_dps.update

local mod_pestilence = E:register_t("mod_pestilence", "mod_poison")
mod_pestilence.dps.damage_min = 2
mod_pestilence.dps.damage_max = 2
mod_pestilence.dps.damage_every = fts(3)
mod_pestilence.dps.kill = true
mod_pestilence.modifier.duration = 1

local mod_slow = E:register_t("mod_slow", "modifier")
E:add_comps(mod_slow, "slow")
mod_slow.modifier.duration = 0.5
mod_slow.modifier.type = MOD_TYPE_SLOW
mod_slow.slow.factor = 0.5
mod_slow.main_script.insert = scripts.mod_slow.insert
mod_slow.main_script.remove = scripts.mod_slow.remove
mod_slow.main_script.update = scripts.mod_track_target.update

local mod_slow_oil = E:register_t("mod_slow_oil", "mod_slow")

mod_slow_oil.modifier.duration = 1
mod_slow_oil.slow.factor = 0.25

local mod_slow_dwaarp = E:register_t("mod_slow_dwaarp", "mod_slow")

mod_slow_dwaarp.modifier.duration = fts(12)
mod_slow_dwaarp.slow.factor = 0.35

local mod_stun = E:register_t("mod_stun", "modifier")
E:add_comps(mod_stun, "render")
mod_stun.main_script.insert = scripts.mod_stun.insert
mod_stun.main_script.update = scripts.mod_stun.update
mod_stun.main_script.remove = scripts.mod_stun.remove
mod_stun.modifier.duration = 2
mod_stun.modifier.type = MOD_TYPE_STUN
mod_stun.modifier.vis_flags = F_STUN
mod_stun.modifier.vis_bans = bor(mod_stun.modifier.vis_bans, F_BOSS)
mod_stun.render.sprites[1].prefix = "stun"
mod_stun.render.sprites[1].size_names = {"small", "big", "big"}
mod_stun.render.sprites[1].name = "small"
mod_stun.render.sprites[1].draw_order = 20

-- 用于使实体对于某些效果不可见
local mod_ban = E:register_t("mod_ban", "modifier")
mod_ban.main_script.insert = scripts.mod_ban.insert
mod_ban.main_script.update = scripts.mod_ban.update
mod_ban.main_script.remove = scripts.mod_ban.remove
mod_ban.modifier.duration = 6
mod_ban.modifier.ban_vis = 0

local mod_shock_and_awe = E:register_t("mod_shock_and_awe", "mod_stun")
local mod_lava = E:register_t("mod_lava", "modifier")
E:add_comps(mod_lava, "dps", "render")
mod_lava.modifier.duration = 2
mod_lava.modifier.vis_flags = F_BURN
mod_lava.dps.damage_min = 1
mod_lava.dps.damage_max = 1
mod_lava.dps.damage_inc = 3
mod_lava.dps.damage_type = DAMAGE_TRUE
mod_lava.dps.damage_every = 0.2
mod_lava.render.sprites[1].size_names = {"small", "medium", "large"}
mod_lava.render.sprites[1].prefix = "fire"
mod_lava.render.sprites[1].name = "small"
mod_lava.render.sprites[1].draw_order = 2
mod_lava.render.sprites[1].loop = true
mod_lava.main_script.insert = scripts.mod_dps.insert
mod_lava.main_script.update = scripts.mod_dps.update

tt = E:register_t("mod_track_target_fx", "modifier")
E:add_comps(tt, "render")
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update
tt = E:register_t("mod_damage", "modifier")
tt.damage_max = 0
tt.damage_min = 0
tt.damage_type = DAMAGE_PHYSICAL
tt.main_script.insert = scripts.mod_damage.insert
tt = E:register_t("mod_teleport", "modifier")
tt.main_script.queue = scripts.mod_teleport.queue
tt.main_script.dequeue = scripts.mod_teleport.dequeue
tt.main_script.update = scripts.mod_teleport.update
tt.main_script.insert = scripts.mod_teleport.insert
tt.main_script.remove = scripts.mod_teleport.remove
tt.max_times_applied = 1
tt.modifier.replaces_lower = false
tt.modifier.resets_same = false
tt.modifier.type = MOD_TYPE_TELEPORT
tt.nodeslimit = 10
tt.delay_start = nil
tt.hold_time = 0.3
tt.delay_end = nil
tt.fx_start = nil
tt.fx_end = nil
tt.damage_base = 0
tt.damage_inc = 0
tt.damage_type = DAMAGE_MAGICAL_EXPLOSION

tt = E:register_t("mod_freeze", "modifier")
tt.modifier.duration = 5
tt.modifier.type = MOD_TYPE_FREEZE
tt.main_script.insert = scripts.mod_freeze.insert
tt.main_script.update = scripts.mod_freeze.update
tt.main_script.remove = scripts.mod_freeze.remove
tt.freeze_decal_name = "decal_freeze_enemy"
tt = E:register_t("decal_freeze_enemy", "decal")
tt.shader = "p_tint"
tt.shader_args = {
    tint_color = {0.6235294117647059, 0.9176470588235294, 1, 1}
}
tt = E:register_t("mod_polymorph", "modifier")

E:add_comps(tt, "polymorph")

tt.main_script.insert = scripts.mod_polymorph.insert
tt.modifier.type = MOD_TYPE_POLYMORPH

local aura = E:register_t("aura")

E:add_comps(aura, "aura", "pos", "sound_events", "main_script")

local lava = E:register_t("lava", "aura")

lava.aura.mod = "mod_lava"
lava.aura.duration = 3
lava.aura.cycle_time = 0.3
lava.aura.radius = 70.4
lava.aura.vis_bans = bor(F_FRIEND, F_FLYING)
lava.aura.vis_flags = bor(F_MOD, F_BURN)
lava.main_script.insert = scripts.aura_apply_mod.insert
lava.main_script.update = scripts.aura_apply_mod.update

tt = E:register_t("tunnel", "aura")
E:add_comps(tt, "tunnel")
tt.main_script.update = scripts.tunnel.update
tt.tunnel.speed_factor = 2

tt = E:register_t("aura_screen_shake", "aura")
tt.main_script.update = scripts.aura_screen_shake.update
tt.aura.duration = 0.5
tt.aura.amplitude = 1
tt.aura.freq_factor = 1

local particle_system = E:register_t("particle_system")

E:add_comps(particle_system, "pos", "particle_system")

local ps_power_fireball = E:register_t("ps_power_fireball", "particle_system")

ps_power_fireball.particle_system.name = "fireball_particle"
ps_power_fireball.particle_system.animated = true
ps_power_fireball.particle_system.loop = false
ps_power_fireball.particle_system.particle_lifetime = {0.25, 0.35}
ps_power_fireball.particle_system.alphas = {255, 0}
ps_power_fireball.particle_system.scales_x = {1, 2.5}
ps_power_fireball.particle_system.scales_y = {1, 2.5}
ps_power_fireball.particle_system.scale_var = {0.4, 0.9}
ps_power_fireball.particle_system.scale_same_aspect = false
ps_power_fireball.particle_system.emit_spread = math.pi
ps_power_fireball.particle_system.emission_rate = 60

local ps_water_trail = E:register_t("ps_water_trail", "particle_system")

ps_water_trail.particle_system.name = "UnderwaterParticle2"
ps_water_trail.particle_system.animated = false
ps_water_trail.particle_system.particle_lifetime = {0.3, 1.2}
ps_water_trail.particle_system.alphas = {255, 10}
ps_water_trail.particle_system.scales_x = {1, 0.05}
ps_water_trail.particle_system.scales_y = {1, 0.05}
ps_water_trail.particle_system.scale_var = {0.9, 1.1}
ps_water_trail.particle_system.emission_rate = 30
ps_water_trail.particle_system.z = Z_OBJECTS
tt = E:register_t("ps_missile")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "particle_smokelet"
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {1.6, 1.8}
tt.particle_system.alphas = {255, 0}
tt.particle_system.scales_x = {1, 3}
tt.particle_system.scales_y = {1, 3}
tt.particle_system.scale_var = {0.4, 0.95}
tt.particle_system.scale_same_aspect = false
tt.particle_system.emit_spread = math.pi
tt.particle_system.emission_rate = 30
tt = E:register_t("pop")

E:add_comps(tt, "pos", "render", "tween")

tt.pop_y_offset = 30
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].hidden = features.pops_hidden
tt.tween.remove = true
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, v(0.75, 0.75)}, {0.1, v(1.2, 1.2)}, {0.2, v(1, 1)}, {0.3, v(1.1, 1.1)}, {0.4, v(1, 1)},
                          {0.9, v(1, 1)}}
tt = E:register_t("pop_aack", "pop")
tt.render.sprites[1].name = "pop_0015"
tt = E:register_t("pop_bzzt", "pop")
tt.render.sprites[1].name = "pop_0011"
tt = E:register_t("pop_instakill", "pop")
tt.render.sprites[1].name = "pop_0020"
tt.pop_over_target = true
tt = E:register_t("pop_kapow", "pop")
tt.render.sprites[1].name = "pop_0008"
tt.pop_y_offset = 40
tt = E:register_t("pop_kboom", "pop")
tt.render.sprites[1].name = "pop_0004"
tt = E:register_t("pop_oof", "pop")
tt.render.sprites[1].name = "pop_0002"
tt = E:register_t("pop_pow", "pop")
tt.render.sprites[1].name = "pop_0005"
tt.pop_y_offset = 40
tt = E:register_t("pop_puff", "pop")
tt.render.sprites[1].name = "pop_0010"
tt = E:register_t("pop_shunt", "pop")
tt.render.sprites[1].name = "pop_0013"
tt = E:register_t("pop_shunt_violet", "pop")
tt.render.sprites[1].name = "pop_0016"
tt = E:register_t("pop_sishh", "pop")
tt.render.sprites[1].name = "pop_0018"
tt = E:register_t("pop_slurp", "pop")
tt.render.sprites[1].name = "pop_0021"
tt = E:register_t("pop_sok", "pop")
tt.render.sprites[1].name = "pop_0006"
tt.pop_y_offset = 40
tt = E:register_t("pop_splat", "pop")
tt.render.sprites[1].name = "pop_0020"
tt.pop_over_target = true
tt = E:register_t("pop_thunk", "pop")
tt.render.sprites[1].name = "pop_0019"
tt = E:register_t("pop_whaam", "pop")
tt.render.sprites[1].name = "pop_0009"
tt.pop_y_offset = 40
tt = E:register_t("pop_zap", "pop")
tt.render.sprites[1].name = "pop_0001"
tt = E:register_t("pop_zap_arcane", "pop")
tt.render.sprites[1].name = "pop_0012"
tt = E:register_t("pop_zap_sorcerer", "pop")
tt.render.sprites[1].name = "pop_0014"
tt = E:register_t("pop_zapow", "pop")
tt.render.sprites[1].name = "pop_0017"
tt = E:register_t("editor_wave_flag")

E:add_comps(tt, "pos", "editor", "editor_script", "main_script", "render")
tt.editor.path_id = 1
tt.editor.r = 0
tt.editor.len = 240
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "waveFlag_0001"
tt.render.sprites[1].scale = vv(scale_scale)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "waveFlag_0004"
tt.render.sprites[2].scale = vv(scale_scale)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "line_red_dotted"
tt.render.sprites[3].anchor.x = 0
tt.render.sprites[3]._width = 128
tt.render.sprites[3].z = tt.render.sprites[1].z - 1
tt.render.sprites[3].scale = vv(scale_scale)
tt.main_script.insert = scripts.editor_wave_flag.insert
tt.editor_script.update = scripts.editor_wave_flag.editor_update
tt.editor.props = {{"editor.path_id", PT_NUMBER}, {"editor.r", PT_NUMBER, math.pi / 180}, {"editor.len", PT_NUMBER}}

tt = E:register_t("editor_spawner_arrow")
E:add_comps(tt, "pos", "render", "editor")
tt.editor.scaffold = true
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "editor_square_blue"
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[1].scale = vv(scale_scale)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "line_blue_dotted_thin"
tt.render.sprites[2].anchor.x = 0
tt.render.sprites[2].scale = vv(scale_scale)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "editor_triangle_blue"
tt.render.sprites[3].scale = vv(scale_scale)
tt.line_image_width = 128

tt = E:register_t("editor_shape_square_blue")
E:add_comps(tt, "pos", "render", "editor")
tt.editor.scaffold = true
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "editor_square_blue"
tt.render.sprites[1].scale = vv(scale_scale)

tt = E:register_t("editor_shape_triangle_blue")
E:add_comps(tt, "pos", "render", "editor")
tt.editor.scaffold = true
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "editor_triangle_blue"
tt.render.sprites[1].scale = vv(scale_scale)

tt = E:register_t("editor_rally_point")
E:add_comps(tt, "pos", "editor", "editor_script", "render")
tt.editor.scaffold = true
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "rally_feedback_0002"
tt.render.sprites[1].scale = vv(scale_scale)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "line_white_dotted"
tt.render.sprites[2].anchor.x = 0
tt.render.sprites[2].scale = vv(scale_scale)
tt.tower_id = nil
tt.image_width = 180
tt.editor_script.update = scripts.editor_rally_point.update
tt.editor_script.remove = scripts.editor_rally_point.remove

tt = E:register_t("tower_build")
E:add_comps(tt, "pos", "tower", "main_script", "render", "tween", "sound_events", "ui")
tt.tower.type = "build_animation"
tt.tower.can_be_mod = false
tt.main_script.update = scripts.tower_build.update
tt.build_name = ""
tt.build_duration = 0.8
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_archer_%04i"
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = ""
tt.render.sprites[2].offset = v(0, 39)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "buildbar_bg"
tt.render.sprites[3].offset = v(0, 50)
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].animated = false
tt.render.sprites[4].name = "buildbar"
tt.render.sprites[4].offset = v(-21, 50)
tt.render.sprites[4].anchor = v(0, 0.5)
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, v(0, 1)}, {0.8, v(1, 1)}}
tt.tween.props[1].sprite_id = 4
tt.tween.remove = false
tt.ui.can_click = false
tt.ui.can_select = false
tt.sound_events.insert = "GUITowerBuilding"

local tower = E:register_t("tower")
E:add_comps(tower, "tower", "pos", "render", "main_script", "ui", "info", "sound_events", "editor", "editor_script",
"vis", "tower_upgrade_persistent_data")
tower.tower.level = 1
tower.render.sprites[1].z = Z_TOWER_BASES
tower.ui.click_rect = r(-40, -12, 80, 70)
tower.ui.has_nav_mesh = true
tower.info.fn = scripts.tower_common.get_info
tower.sound_events.sell = "GUITowerSell"
tower.editor.props = {{"tower.terrain_style", PT_NUMBER}, {"tower.default_rally_pos", PT_COORDS},
                      {"tower.holder_id", PT_STRING}, {"ui.nav_mesh_id", PT_STRING}, {"editor.game_mode", PT_NUMBER}}
tower.editor_script.insert = scripts.editor_tower.insert
tower.editor_script.remove = scripts.editor_tower.remove

local tower5 = E:register_t("tower5", "tower")
tower5.is_kr5 = true

local unit = E:register_t("unit")

E:add_comps(unit, "unit", "pos", "heading", "health", "health_bar", "render", "ui")

unit.ui.click_rect = IS_PHONE_OR_TABLET and r(-20, -5, 40, 40) or r(-15, 0, 30, 30)
unit.damage_buff = 0
unit.cooldown_factor = 1

local soldier = E:register_t("soldier", "unit")
E:add_comps(soldier, "soldier", "motion", "nav_rally", "main_script", "vis", "regen", "idle_flip", "sound_events",
    "info")

soldier.vis.flags = F_FRIEND
soldier.sound_events.death_by_explosion = "DeathEplosion"

tt = E:register_t("soldier_militia", "soldier")
E:add_comps(tt, "melee")
image_y = 52
anchor_y = 0.17
tt.health.dead_lifetime = 10
tt.health.hp_max = 50
tt.health_bar.offset = v(0, 25.16)
tt.health_bar.type = HEALTH_BAR_SIZE_SMALL
tt.idle_flip.chance = 0.4
tt.idle_flip.cooldown = 5
tt.info.fn = scripts.soldier_barrack.get_info
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0001" or IS_KR1 and "info_portraits_sc_0001" or
                       "info_portraits_soldiers_0001"
tt.info.random_name_count = 40
tt.info.random_name_format = "SOLDIER_RANDOM_%i_NAME"
tt.main_script.insert = scripts.soldier_barrack.insert
tt.main_script.remove = scripts.soldier_barrack.remove
tt.main_script.update = scripts.soldier_barrack.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 3
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.range = 60
tt.motion.max_speed = 75
tt.regen.cooldown = 1
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"running"}
tt.render.sprites[1].prefix = "soldiermilitia"
tt.soldier.melee_slot_offset = v(5, 0)
tt.ui.click_rect = IS_PHONE_OR_TABLET and r(-20, -5, 40, 40) or r(-10, -2, 20, 25)
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, ady(8))
tt.unit.mod_offset = v(0, ady(21))

tt = E:register_t("soldier_footmen", "soldier_militia")
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0002" or IS_KR1 and "info_portraits_sc_0002" or
                       "info_portraits_soldiers_0002"
tt.render.sprites[1].prefix = "soldierfootmen"
tt.health.hp_max = 100
tt.health.armor = 0.15
tt.melee.attacks[1].cooldown = 1 + fts(11)
tt.melee.attacks[1].damage_min = 3
tt.melee.attacks[1].damage_max = 4

tt = E:register_t("soldier_knight", "soldier_militia")
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0003" or IS_KR1 and "info_portraits_sc_0003" or
                       "info_portraits_soldiers_0003"
tt.render.sprites[1].prefix = "soldierknight"
tt.health.hp_max = 150
tt.health.armor = 0.3
tt.melee.attacks[1].cooldown = 1 + fts(11)
tt.melee.attacks[1].damage_min = 6
tt.melee.attacks[1].damage_max = 10

local hero = E:register_t("hero", "soldier")
E:add_comps(hero, "hero", "nav_grid")
hero.health_bar.hidden = true
hero.vis.flags = bor(F_HERO, F_FRIEND)
hero.vis.bans = bor(F_POLYMORPH, F_DISINTEGRATED, F_CANNIBALIZE, F_SKELETON)
hero.main_script.insert = scripts.hero_basic.insert
hero.info.fn = scripts.hero_basic.get_info
hero.regen.last_hit_standoff_time = 1
hero.render.sprites[1].angles = {}
hero.render.sprites[1].angles.walk = {"running"}
hero.render.sprites[1].name = "idle"
hero.ui.click_rect = IS_PHONE_OR_TABLET and r(-35, -15, 70, 70) or r(-20, -5, 40, 40)
hero.ui.z = 2
hero.unit.hit_offset = v(0, 12)

local stage_hero = E:register_t("stage_hero", "hero")

stage_hero.hero.stage_hero = true

local enemy = E:register_t("enemy", "unit")
E:add_comps(enemy, "enemy", "motion", "nav_path", "main_script", "sound_events", "vis", "info")
enemy.vis.flags = F_ENEMY
enemy.render.sprites[1].angles = {}
enemy.render.sprites[1].angles.walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
enemy.render.sprites[1].angles_stickiness = {
    walk = 10
}
enemy.info.fn = scripts.enemy_basic.get_info
enemy.main_script.insert = scripts.enemy_basic.insert
enemy.main_script.update = scripts.enemy_mixed.update
enemy.ui.click_rect = IS_PHONE_OR_TABLET and r(-25, -10, 50, 50) or r(-10, -5, 20, 30)
enemy.sound_events.death = "DeathHuman"
enemy.sound_events.death_by_explosion = "DeathEplosion"

local enemy_KR5 = E:register_t("enemy_KR5", "enemy")
enemy_KR5.is_kr5 = true

local boss = E:register_t("boss", "unit")

E:add_comps(boss, "enemy", "motion", "nav_path", "main_script", "vis", "info", "sound_events")

boss.vis.flags = bor(F_ENEMY, F_BOSS)
boss.info.fn = scripts.enemy_basic.get_info
boss.ui.click_rect = r(-20, -5, 40, 90)
boss.health.armor_resilience = 0.5
boss.silence_cast_count = -1

tt = E:register_t("mega_spawner")
E:add_comps(tt, "main_script", "editor", "editor_script")
tt.main_script.insert = scripts.mega_spawner.insert
tt.main_script.update = scripts.mega_spawner.update
tt.manual_wave = nil
tt.interrupt = false
tt.editor_script.insert = scripts.editor_mega_spawner.insert
tt.editor_script.remove = scripts.editor_mega_spawner.remove

tt = E:register_t("background_sounds")
E:add_comps(tt, "main_script")
tt.main_script.update = scripts.background_sounds.insert
tt.main_script.update = scripts.background_sounds.update
tt.min_delay = 15
tt.max_delay = 25
tt.sounds = {}

tt = E:register_t("user_item")
E:add_comps(tt, "user_item", "pos", "main_script", "user_selection")

tt = E:register_t("power_fireball_control")
E:add_comps(tt, "user_power", "pos", "main_script", "user_selection")

tt.main_script.update = scripts.power_fireball_control.update
tt.cooldown = 80
tt.max_spread = 20
tt.fireball_count = 3
tt.cataclysm_count = 0
tt.user_selection.can_select_point_fn = scripts.power_fireball_control.can_select_point

tt = E:register_t("power_fireball", "bullet")
tt.bullet.min_speed = 0
tt.bullet.max_speed = 15 * FPS
tt.bullet.acceleration_factor = 0.05
tt.bullet.hit_fx = "fx_fireball_explosion"
tt.bullet.hit_decal = "decal_bomb_crater"
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_radius = 60
tt.bullet.damage_min = 30
tt.bullet.damage_max = 60
tt.bullet.damage_flags = F_AREA
tt.render.sprites[1].name = "fireball_proyectile"
tt.main_script.update = scripts.power_fireball.update
tt.scorch_earth = false
tt.sound_events.insert = "FireballRelease"
tt.sound_events.hit = "FireballHit"

tt = E:register_t("fx_fireball_explosion", "fx")
tt.render.sprites[1].name = "fireball_explosion"
tt.render.sprites[1].anchor.y = 0.15
tt.render.sprites[1].z = Z_OBJECTS

tt = E:register_t("decal_fireball_shadow", "decal")
tt.render.sprites[1].name = "fireball_shadow"
tt.render.sprites[1].loop = false

tt = E:register_t("power_scorched_water", "aura")
E:add_comps(tt, "render", "tween")
tt.main_script.update = scripts.aura_apply_damage.update
tt.aura.duration = 5
tt.aura.radius = 65
tt.aura.cycle_time = 1
tt.aura.damage_min = 10
tt.aura.damage_max = 20
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.vis_flags = bor(F_MOD)
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.render.sprites[1].name = "fireball_vapor"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -2
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}, {"this.aura.duration-0.5", 255}, {"this.aura.duration", 0}}
tt.tween.props[1].loop = false
tt.tween.props[1].sprite_id = 1
tt = E:register_t("power_scorched_earth", "power_scorched_water")
tt.render.sprites[1].name = "decal_scorched_earth_base"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "decal_scorched_earth_fire"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].animated = false
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].loop = true
tt.tween.props[2].keys = {{0, 0}, {0.5, 255}, {1, 0}}

tt = E:register_t("mod_health_damage_factor_inc", "modifier")
tt.main_script.insert = scripts.mod_health_damage_factor_inc.insert
tt.main_script.update = nil
tt.modifier.health_damage_factor_inc = 0.01

tt = E:register_t("power_reinforcements_control")
E:add_comps(tt, "user_power", "pos", "main_script", "user_selection")
tt.main_script.insert = scripts.power_reinforcements_control.insert
tt.user_selection.can_select_point_fn = scripts.power_reinforcements_control.can_select_point
tt.cooldown = 99

tt = E:register_t("user_item_atomic_bomb")
E:add_comps(tt, "user_item", "pos", "main_script", "user_selection")
tt.main_script.update = scripts.user_item_atomic_bomb.update
tt.plane_transit_duration = 5
tt.plane_dest = nil
tt.bomb_dest = nil

tt = E:register_t("decal_atomic_bomb_plane", "decal_scripted")
E:add_comps(tt, "motion", "sound_events")
tt.render.sprites[1].name = "atomicBomb_plane"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "atomic_bomb_plane_engine"
tt.render.sprites[2].offset = v(52, -8)
tt.render.sprites[2].z = Z_OBJECTS_SKY
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "atomicBomb_bomb"
tt.render.sprites[3].animated = false
tt.render.sprites[3].offset = v(16, -38)
tt.render.sprites[3].z = Z_OBJECTS_SKY + 1
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].name = "atomic_bomb_plane_wing"
tt.render.sprites[4].offset = v(9, -27)
tt.render.sprites[4].z = Z_OBJECTS_SKY + 2
tt.render.sprites[5] = E:clone_c("sprite")
tt.render.sprites[5].name = "atomicBomb_shadow"
tt.render.sprites[5].animated = false
tt.render.sprites[5].scale = v(0.6, 0.6)
tt.render.sprites[5].alpha = 100
tt.render.sprites[5].offset = v(0, 0)
tt.render.sprites[5].z = Z_DECALS
tt.main_script.insert = scripts.decal_atomic_bomb_plane.insert
tt.main_script.update = scripts.decal_atomic_bomb_plane.update
tt.sound_events.insert = "InAppAtomicBomb"
tt = E:register_t("atomic_bomb", "bullet")
tt.bullet.damage_min = 3000
tt.bullet.damage_max = 3000
tt.bullet.damage_type = bor(DAMAGE_EXPLOSION, DAMAGE_FX_EXPLODE, DAMAGE_NO_SPAWNS, DAMAGE_IGNORE_SHIELD)
tt.bullet.flight_time = fts(26)
tt.bullet.hit_decal = "decal_atomic_bomb_crater"
tt.bullet.hit_fx = "fx_explosion_big"
tt.render.sprites[1].name = "atomicBomb_bomb"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_SKY + 1
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "atomicBomb_shadow"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].alpha = 0
tt.main_script.insert = scripts.atomic_bomb.insert
tt.main_script.update = scripts.atomic_bomb.update
tt.sound_events.insert = "InAppAtomicBombFalling"
tt = E:register_t("decal_atomic_bomb_crater", "decal_tween")
tt.render.sprites[1].name = "atomicBomb_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{2, 255}, {3.5, 0}}
tt = E:register_t("user_item_atomic_freeze")

E:add_comps(tt, "user_item", "pos", "main_script", "user_selection")

tt.duration = 15
tt.main_script.insert = scripts.user_item_atomic_freeze.insert
tt.main_script.update = scripts.user_item_atomic_freeze.update
tt.excluded_templates = {"eb_umbra", "enemy_umbra_piece", "enemy_umbra_piece_flying", "enemy_tremor",
                         "enemy_headless_horseman"}
tt.vis_flags = bor(F_RANGED, F_FREEZE)
tt.vis_bans = 0
tt.mod = "mod_user_item_freeze"
tt = E:register_t("decal_user_item_atomic_freeze_slab", "decal_tween")
tt.render.sprites[1].name = "freeze_decals_%04d"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{"this.duration", 255}, {"this.duration+0.5", 0}}
tt.decals_count = 4
tt = E:register_t("user_item_freeze", "bullet")

E:add_comps(tt, "sound_events", "user_item", "user_selection")

tt.bullet.flight_time = fts(21)
tt.bullet.g = -1.4 / (fts(1) * fts(1))
tt.bullet.rotation_speed = 20 * FPS * math.pi / 180
tt.bullet.hit_fx = "fx_user_item_freeze_explosion"
tt.bullet.hit_decal = "decal_user_item_freeze"
tt.bullet.damage_radius = 60
tt.bullet.mod = "mod_user_item_freeze"
tt.bullet.hide_radius = 4
tt.bullet.excluded_templates = E:get_template("user_item_atomic_freeze").excluded_templates
tt.bullet.half_time_templates = {"enemy_demon_cerberus", "enemy_hobgoblin"}
tt.bullet.vis_flags = bor(F_RANGED, F_FREEZE)
tt.render.sprites[1].name = "small_freeze_bomb"
tt.render.sprites[1].animated = false
tt.user_selection.can_select_point_fn = scripts.user_item_freeze.can_select_point
tt.main_script.insert = scripts.user_item_freeze.insert
tt.main_script.update = scripts.user_item_freeze.update
tt.sound_events.insert = "InAppFreeze"
tt = E:register_t("mod_user_item_freeze", "mod_freeze")

E:add_comps(tt, "render")

tt.modifier.duration = 5
tt.render.sprites[1].prefix = "freeze_creep"
tt.render.sprites[1].sort_y_offset = -2
tt.custom_offsets = {}
tt.custom_offsets.flying = v(-5, 32)
tt.custom_offsets.enemy_wasp_queen = v(-5, 38)
tt.custom_offsets.eb_efreeti = v(100, 15)
tt.custom_suffixes = {}
tt.custom_suffixes.flying = "_air"
tt.custom_animations = {"start", "end"}
tt = E:register_t("decal_user_item_freeze", "decal_tween")
tt.render.sprites[1].name = "small_freeze_decal"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{0.8, 255}, {2.1, 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, v(0, 0)}, {0.2, v(1, 1)}}
tt = E:register_t("fx_user_item_freeze_explosion", "fx")
tt.render.sprites[1].name = "small_freeze_explosion"
tt.render.sprites[1].anchor.y = 0.29
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -2
tt = E:register_t("user_item_hearts")

E:add_comps(tt, "pos", "user_item", "user_selection")

tt.reward = 5
tt = E:register_t("user_item_coins")

E:add_comps(tt, "pos", "user_item", "user_selection")

tt.reward = 500
tt = E:register_t("user_item_dynamite", "bomb")

E:add_comps(tt, "user_item", "user_selection")

tt.user_selection.can_select_point_fn = scripts.user_item_dynamite.can_select_point
tt.main_script.insert = scripts.user_item_dynamite.insert
tt.render.sprites[1].name = "dynamite"
tt.bullet.damage_min = 150
tt.bullet.damage_max = 250
tt.bullet.damage_radius = 45
tt.bullet.flight_time = fts(21)
tt.bullet.g = -1.4 / (fts(1) * fts(1))

tt = E:register_t("mod_soldier_cooldown", "modifier")
tt.main_script.insert = scripts.mod_soldier_cooldown.insert
tt.main_script.remove = scripts.mod_soldier_cooldown.remove
tt.main_script.update = scripts.mod_soldier_cooldown.update
tt.modifier.vis_flags = F_MOD
tt.modifier.duration = 10
tt.cooldown_factor = 0.9
