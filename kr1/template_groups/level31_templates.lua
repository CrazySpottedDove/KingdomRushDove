local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local V = require("lib.klua.vector")
require("all.constants")
require("lib.klua.table")
local v = V.v
local function fts(t)
	return t / FPS
end
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function pirate_cannons_update(this, store)
	local decal
	local a = this.attacks.list[1]
	a.ts = store.tick_ts
	while true do
		a.cooldown = U.frandom(a.min_cooldown, a.max_cooldown)
		if store.tick_ts - a.ts > a.cooldown then
			local targets = table.filter(store.entities, function(_, e)
				return e and e.soldier and e.health and not e.health.dead and e.soldier.target_id ~= nil and e.motion and V.veq(e.motion.speed, v(0, 0)) and e.vis and band(e.vis.flags, a.vis_bans) == 0 and band(e.vis.bans, a.vis_flags) == 0 and U.is_inside_ellipse(e.pos, this.pos, a.max_range) and not U.is_inside_ellipse(e.pos, this.pos, a.min_range)
			end)
			local target = targets[math.random(1, #targets)]
			if not target then
			else
				decal = E:create_entity("decal_pirate_cannon_target")
				decal.pos = V.vclone(target.pos)
				decal.render.sprites[1].ts = store.tick_ts
				simulation:queue_insert_entity(decal)
				U.animation_start_default(this, "fire", nil, store.tick_ts, false)
				U.y_wait_unconditional(store, a.shoot_time)
				S:queue("PirateBombShootSound")
				local dest = V.vclone(target.pos)
				U.y_wait_unconditional(store, fts(28))
				local b1 = E:create_entity("bomb_pirate_cannon")
				local b2 = E:create_entity("bomb_pirate_cannon")
				b1.bullet.to = v(dest.x + U.random_sign() * math.random(a.min_error, a.max_error), dest.y + U.random_sign() * math.random(a.min_error, a.max_error))
				b2.bullet.to = v(dest.x + U.random_sign() * math.random(a.min_error, a.max_error), dest.y + U.random_sign() * math.random(a.min_error, a.max_error))
				b1.pos = b1.bullet.to
				b2.pos = b2.bullet.to
				simulation:queue_insert_entity(b1)
				U.y_wait_unconditional(store, fts(4))
				simulation:queue_insert_entity(b2)
				U.y_animation_wait_default(this)
				a.ts = store.tick_ts
			end
		end
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("decal_lumberjack", "decal", true)
tt.render.sprites[1].prefix = "lumberjack"
tt.render.sprites[1].anchor.y = 0.19
tt.render.sprites[1].flip_x = true
tt = E:register_t_hot("decal_ship_door", "decal", true)
tt.render.sprites[1].prefix = "decal_ship_door"
tt.render.sprites[1].name = "closed"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt = E:register_t_hot("pirate_cannons", "decal_scripted", true)
AC(tt, "attacks")
tt.main_script.update = pirate_cannons_update
tt.render.sprites[1].prefix = "pirate_cannon_left"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "pirate_cannon_right"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].z = Z_OBJECTS_COVERS + 1
tt.render.sprites[2].offset = vec_2(169, -65)
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].min_range = 100
tt.attacks.list[1].max_range = 600
tt.attacks.list[1].min_cooldown = 40
tt.attacks.list[1].max_cooldown = 60
tt.attacks.list[1].shoot_time = fts(29)
tt.attacks.list[1].max_error = 20
tt.attacks.list[1].min_error = 5
local function queue_damage(store, damage)
	store.damage_queue[#store.damage_queue + 1] = damage
end
local SU = require("script_utils")
local function bomb_pirate_cannon_update(this, store)
	local b = this.bullet
	S:queue(this.sound_events.hit)
	local targets = table.filter(store.entities, function(_, e)
		return e and e.health and not e.health.dead and e.vis and band(e.vis.flags, b.damage_bans) == 0 and band(e.vis.bans, b.damage_flags) == 0 and U.is_inside_ellipse(e.pos, b.to, b.damage_radius)
	end)
	for _, target in ipairs(targets) do
		local d = E.assign_damage(b.damage_type, b.damage_min + U.frandom(0, b.damage_max - b.damage_min), this.id, target.id)
		queue_damage(store, d)
	end
	local p = SU.create_bullet_pop(store, this)
	if p then
		simulation:queue_insert_entity(p)
	end
	local sfx = E:create_entity(b.hit_fx)
	sfx.pos = V.vclone(b.to)
	sfx.render.sprites[1].ts = store.tick_ts
	simulation:queue_insert_entity(sfx)
	local decal = E:create_entity(b.hit_decal)
	decal.pos = V.vclone(b.to)
	decal.render.sprites[1].ts = store.tick_ts
	simulation:queue_insert_entity(decal)
	simulation:queue_remove_entity(this)
end
tt = E:register_t_hot("decal_pirate_cannon_target", "decal_tween", true)
tt.render.sprites[1].name = "Stage4_ShipCrosshair"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_2(1.86, 1.86)}, {fts(20), vec_2(1.05, 1.05)}, {fts(23), vec_2(0.95, 0.95)}, {fts(26), vec_2(1.05, 1.05)}, {fts(28), vec_2(1, 1)}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {{0, 0}, {fts(20), 255}, {fts(74), 255}, {fts(78), 0}}
tt = E:register_t_hot("bomb_pirate_cannon", "bullet", true)
tt.render = nil
tt.main_script.update = bomb_pirate_cannon_update
tt.bullet.damage_min = 50
tt.bullet.damage_max = 100
tt.bullet.damage_radius = 67.2
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.hit_fx = "fx_explosion_small"
tt.bullet.hit_decal = "decal_bomb_crater"
tt.sound_events.hit = "BombExplosionSound"
