local E = require("entity_db")
local scripts = require("scripts")
require("all.constants")
require("lib.klua.table")
local function fts(t)
	return t / FPS
end
local tt
tt = E:register_t_hot("bomb_volcano", "bullet", true)
tt.bullet.damage_max = 160
tt.bullet.damage_min = 100
tt.bullet.damage_radius = 50
tt.bullet.g = -0.8 / (fts(1) * fts(1))
tt.bullet.hit_decal = "decal_bomb_crater"
tt.bullet.hit_fx = "fx_fireball_explosion"
tt.bullet.particles_name = "ps_bomb_volcano"
tt.bullet.pop = {"pop_kboom"}
tt.bullet.rotation_speed = 20 * FPS * math.pi / 180
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.flight_time_base = fts(35)
tt.bullet.flight_time_factor = fts(0.066667)
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "Stage9_lavaShot"
tt.sound_events.insert = "SpecialVolcanoLavaShoot"
tt.sound_events.hit = "SpecialVolcanoLavaShootHit"
tt.sound_events.remove = "BombExplosionSound"
tt = E:register_t_hot("decal_volcano_bubble", "decal_delayed_play", true)
tt.render.sprites[1].prefix = "volcano_lava"
tt.render.sprites[1].name = "bubble"
tt.delayed_play.min_delay = 5
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "bubble"
tt = E:register_t_hot("decal_volcano_smoke", "decal_delayed_play", true)
tt.render.sprites[1].prefix = "volcano_lava"
tt.render.sprites[1].name = "smoke"
tt.delayed_play.min_delay = 3
tt.delayed_play.max_delay = 3
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "smoke"
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
