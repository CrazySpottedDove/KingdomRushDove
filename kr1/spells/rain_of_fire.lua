local M = {}

M.id = "rain_of_fire"
M.i18n = "POWER_RAIN_OF_FIRE"
M.control = "power_rain_of_fire_control"
M.button_icon = "in_game_icon_power_rain_of_fire"
M.pointer_icon = "pointer_power_rain_of_fire"
M.portrait = "power_portraits_big_rain_of_fire"
M.name_style = {
	font_name = "h",
	font_size = 30,
	color = {255, 206, 122, 255},
	shaders = {"p_outline", "p_glow"},
	shader_args = {{
		thickness = 3,
		outline_color = {0.34, 0.14, 0.03, 1}
	}, {
		thickness = 2,
		glow_color = {0.95, 0.56, 0.16, 0.75}
	}},
	shader_margin = 16
}
M.required_textures = {"go_power_rain_of_fire"}
M.plugin_required_textures = {}
M.required_sounds = {"spell_rain_of_fire"}
M.plugin_required_sounds = {}
M.required_exoskeletons = {}
M.plugin_required_exoskeletons = {}

function M.register_templates(E)
	local V = require("lib.klua.vector")
	local v = V.v
	local bit = require("bit")
	local band = bit.band
	local bor = bit.bor
	local U = require("utils")
	local S = require("sound_db")
	local GR = require("grid_db")
	local UP = require("kr1.upgrades")
	local P = require("path_db")
	local scripts = require("game_scripts")

	local function fts(x)
		return x / FPS
	end

	local function queue_damage(store, damage)
		store.damage_queue[#store.damage_queue + 1] = damage
	end

	local tt

	tt = E:register_t_tmp("ps_power_rain_of_fire", "particle_system")
	tt.particle_system.name = "rain_of_fire_particle_action"
	tt.particle_system.animated = true
	tt.particle_system.loop = false
	tt.particle_system.z = Z_BULLET_PARTICLES
	tt.particle_system.animation_fps = 26
	tt.particle_system.emission_rate = 54
	tt.particle_system.emit_rotation_spread = math.pi * 2
	tt.particle_system.emit_spread = math.pi * 2
	tt.particle_system.emit_area_spread = v(6, 6)

	tt = E:register_t_tmp("fx_power_rain_of_fire_hit", "fx")
	tt.render.sprites[1].name = "hit"
	tt.render.sprites[1].prefix = "rain_of_fire_hit"
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = -1

	tt = E:register_t_tmp("decal_power_rain_of_fire_crack", "decal_tween")
	tt.render.sprites[1].name = "rain_of_fire_decal1"
	tt.render.sprites[1].animated = false
	tt.render.sprites[1].scale = v(1.2, 1.2)
	tt.render.sprites[1].z = Z_DECALS
	tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}

	tt = E:register_t_tmp("decal_power_rain_of_fire_scorch", "decal_tween")
	E:add_comps(tt, "main_script")
	tt.render.sprites[1].prefix = "rain_of_fire_decal2"
	tt.render.sprites[1].name = "loop"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].scale = v(1.2, 1.2)
	tt.render.sprites[1].z = Z_DECALS
	tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}
	tt.tween.disabled = true
	tt.duration = 0.5
	tt.main_script.update = function(this, store)
		U.y_wait(store, this.duration)

		this.tween.ts = store.tick_ts
		this.tween.disabled = false
	end

	tt = E:register_t_tmp("decal_power_rain_of_fire_extra_explosion", "decal_scripted")
	E:add_comps(tt, "render", "aura")
	tt.render.sprites[1].prefix = "rain_of_fire_hit_explosion"
	tt.render.sprites[1].name = "hit"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].z = Z_BULLETS
	tt.aura.radius = 60
	tt.aura.vis_flags = bor(F_AREA)
	tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
	tt.explosion_delay = fts(14)
	tt.damage_min = 28
	tt.damage_max = 35
	tt.damage_type = DAMAGE_TRUE
	tt.main_script.update = function(this, store)
		U.animation_start(this, "hit", nil, store.tick_ts, false)
		U.y_wait(store, this.explosion_delay)

		local enemies = U.find_enemies_in_range(store, this.pos, 0, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)

		if enemies then
			for _, enemy in ipairs(enemies) do
				local damage
				if UP:get_upgrade("engineer_efficiency") then
					damage = this.damage_max
				else
					damage = math.floor(this.damage_max - (this.damage_max - this.damage_min) * U.dist_factor_inside_ellipse(enemy.pos, this.pos, this.aura.radius))
				end
				local d = E.assign_damage(this.damage_type, damage, this.id, enemy.id)

				queue_damage(store, d)
			end
		end

		U.y_animation_wait(this)
		simulation:queue_remove_entity(this)
	end

	tt = E:register_t_tmp("aura_bullet_power_rain_of_fire_dmg", "aura")
	tt.aura.mod = "mod_bullet_power_rain_of_fire_burn"
	tt.aura.radius = 50
	tt.aura.vis_flags = bor(F_AREA)
	tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
	tt.aura.cycle_time = 0.25
	tt.aura.duration = 3
	tt.main_script.insert = scripts.aura_apply_mod.insert
	tt.main_script.update = scripts.aura_apply_mod.update

	tt = E:register_t_tmp("aura_bullet_power_rain_of_fire_slow", "aura")
	tt.aura.mod = "mod_bullet_power_rain_of_fire_slow"
	tt.aura.radius = 50
	tt.aura.vis_flags = bor(F_AREA)
	tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
	tt.aura.cycle_time = 0.3
	tt.aura.duration = 3
	tt.main_script.insert = scripts.aura_apply_mod.insert
	tt.main_script.update = scripts.aura_apply_mod.update

	tt = E:register_t_tmp("mod_bullet_power_rain_of_fire_slow", "mod_slow")
	tt.slow.factor = 0.5
	tt.modifier.duration = 0.5
	tt.modifier.vis_flags = bor(F_MOD)
	tt.main_script.insert = scripts.mod_slow.insert

	tt = E:register_t_tmp("mod_bullet_power_rain_of_fire_burn", "modifier")
	E:add_comps(tt, "dps", "render", "tween")
	tt.modifier.duration = 0.5
	tt.modifier.vis_flags = bor(F_MOD, F_BURN)
	tt.render.sprites[1].name = "loop"
	tt.render.sprites[1].prefix = "rain_of_fire_burning_mod"
	tt.render.sprites[1].z = Z_EFFECTS
	tt.render.sprites[1].animated = true
	tt.dps.damage_min = 4
	tt.dps.damage_max = 7
	tt.dps.damage_inc = 0
	tt.dps.damage_every = 0.25
	tt.dps.damage_type = DAMAGE_TRUE
	tt.tween.disabled = true
	tt.tween.props[1].keys = {{0, 255}, {0.2, 0}}
	tt.main_script.insert = scripts.mod_dps.insert
	tt.main_script.update = scripts.mod_dps.update
	tt.main_script.remove = scripts.tween_utils.reverse_remove

	tt = E:register_t_tmp("bullet_power_rain_of_fire", "bullet")
	tt.bullet.min_speed = 13 * FPS
	tt.bullet.max_speed = 13 * FPS
	tt.bullet.acceleration_factor = 0
	tt.bullet.hit_fx = "fx_power_rain_of_fire_hit"
	tt.bullet.hit_decal = "decal_power_rain_of_fire_crack"
	tt.bullet.damage_type = DAMAGE_TRUE
	tt.bullet.damage_radius = 60
	tt.bullet.damage_min = 45
	tt.bullet.damage_max = 63
	tt.bullet.damage_factor = 1
	tt.bullet.damage_flags = F_AREA
	tt.bullet.damage_bans = 0
	tt.bullet.hit_payload = "decal_power_rain_of_fire_extra_explosion"
	tt.render.sprites[1].prefix = "rain_of_fire_projectile"
	tt.render.sprites[1].name = "idle"
	tt.particles = "ps_power_rain_of_fire"
	tt.dmg_aura = "aura_bullet_power_rain_of_fire_dmg"
	tt.slow_aura = "aura_bullet_power_rain_of_fire_slow"
	tt.sound_events.insert = "PowersRainOfFireCast"
	tt.sound_events.hit = "PowersRainOfFireImpact"
	tt.upgrade_scorching_floor = false
	tt.upgrade_slow_floor = false
	tt.upgrade_extra_explosion = false
	tt.main_script.update = function(this, store)
		local b = this.bullet
		local mspeed = b.min_speed
		local particle = E:create_entity(this.particles)

		particle.particle_system.track_id = this.id
		simulation:queue_insert_entity(particle)

		while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
			mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
			mspeed = math.min(b.max_speed, math.max(b.min_speed, mspeed))
			b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
			this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
			this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

			coroutine.yield()
		end

		this.pos.x, this.pos.y = b.to.x, b.to.y
		particle.particle_system.source_lifetime = 0

		local enemies = U.find_enemies_in_range(store, b.to, 0, b.damage_radius, b.damage_flags, b.damage_bans)
		local damage_value = math.ceil(b.damage_factor * math.random(b.damage_min, b.damage_max))

		if enemies then
			for _, enemy in ipairs(enemies) do
				local d = E.assign_damage(b.damage_type, damage_value, this.id, enemy.id)

				queue_damage(store, d)
			end
		end

		S:queue(this.sound_events.hit)

		local cell_type = GR:cell_type(b.to.x, b.to.y)

		if band(cell_type, TERRAIN_WATER) ~= 0 then
			local fx = E:create_entity("fx_explosion_water")

			fx.pos.x, fx.pos.y = b.to.x, b.to.y
			fx.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(fx)
		else
			if b.hit_decal then
				local decal = E:create_entity(b.hit_decal)

				decal.pos.x, decal.pos.y = b.to.x, b.to.y
				decal.render.sprites[1].ts = store.tick_ts
				simulation:queue_insert_entity(decal)
			end

			if this.upgrade_scorching_floor then
				local scorched = E:create_entity(this.dmg_aura)

				scorched.pos.x, scorched.pos.y = b.to.x, b.to.y
				simulation:queue_insert_entity(scorched)
			end

			if this.upgrade_slow_floor then
				local slow = E:create_entity(this.slow_aura)

				slow.pos.x, slow.pos.y = b.to.x, b.to.y
				simulation:queue_insert_entity(slow)
			end

			if b.hit_fx then
				local fx = E:create_entity(b.hit_fx)

				fx.pos.x, fx.pos.y = b.to.x, b.to.y
				fx.render.sprites[1].ts = store.tick_ts
				simulation:queue_insert_entity(fx)
			end

			if this.upgrade_extra_explosion and b.hit_payload then
				local hp = E:create_entity(b.hit_payload)

				hp.pos.x, hp.pos.y = b.to.x, b.to.y
				simulation:queue_insert_entity(hp)
			end
		end

		simulation:queue_remove_entity(this)
	end

	tt = E:register_t_tmp(M.control, "power_control_custom")
	tt.main_script.update = function(this, store)
		local start_y = store.visible_coords and store.visible_coords.top or REF_H
		local burst_interval = 0.33

		local function spawn_meteor(x, y)
			local e = E:create_entity(this.bullet)

			e.pos.x, e.pos.y = x, start_y
			e.bullet.from = V.vclone(e.pos)
			e.bullet.to = v(x, y)
			simulation:queue_insert_entity(e)
		end

		local function predict_dest(target)
			local nav_path = target.nav_path

			if not target.motion or not target.motion.speed or not nav_path then
				return target.pos
			end

			local nodes = P.paths[nav_path.pi] and P.paths[nav_path.pi][nav_path.spi]

			if not nodes then
				return target.pos
			end

			local fall_speed = target.motion.speed.y + 13 * FPS
			local predicted_time = fall_speed > 0 and (start_y - target.pos.y) / fall_speed or 0
			local current_node = P:node_pos(nav_path.pi, nav_path.spi, nav_path.ni)
			local node_advance = math.ceil((predicted_time * (target.motion.real_speed or 0) + V.dist(target.pos.x, target.pos.y, current_node.x, current_node.y)) / P.average_node_dist)
			local predicted_node = math.min(#nodes, math.max(1, nav_path.ni + node_advance))

			return P:node_pos(nav_path.pi, nav_path.spi, predicted_node)
		end

		for i = 1, math.max(this.meteor_count, this.cataclysm_count) do
			if i <= this.meteor_count then
				if i == 1 then
					spawn_meteor(this.pos.x, this.pos.y)
				else
					local spread = math.random(this.min_spread, this.max_spread)

					spawn_meteor(this.pos.x + math.random(-spread, spread), this.pos.y + math.random(-spread, spread))
				end
			end

			if this.upgrade_cataclysm and i <= this.cataclysm_count then
				local dest
				local enemies = table.filter(store.enemies, function(_, enemy)
					return enemy and enemy.health and not enemy.health.dead and band(enemy.vis.bans, F_RANGED) == 0
				end)

				if #enemies > 0 then
					dest = predict_dest(table.random(enemies))
				else
					dest = P:get_random_position(10, bor(TERRAIN_LAND))
				end

				if dest then
					spawn_meteor(dest.x, dest.y)
				end
			end

			local ts = store.tick_ts

			while burst_interval > store.tick_ts - ts do
				coroutine.yield()
			end
		end

		simulation:queue_remove_entity(this)
	end
	tt.user_selection.can_select_point_fn = function(this, x, y, store)
		return GR:cell_is(x, y, bor(TERRAIN_LAND, TERRAIN_ICE)) and P:valid_node_nearby(x, y, nil, NF_RALLY)
	end
	tt.cooldown = 60
	tt.min_spread = 25
	tt.max_spread = 40
	tt.meteor_count = 3
	tt.cataclysm_count = 5
	tt.bullet = "bullet_power_rain_of_fire"
	tt.upgrade_cataclysm = false

	E:set_template("user_power_3", tt)
end

function M.apply(level)
	local E = require("entity_db")
	local ctrl = E:get_template(M.control)
	local bullet = E:get_template("bullet_power_rain_of_fire")
	local scorch = E:get_template("decal_power_rain_of_fire_scorch")
	local burn = E:get_template("aura_bullet_power_rain_of_fire_dmg")
	local slow = E:get_template("aura_bullet_power_rain_of_fire_slow")
	local burn_mod = E:get_template("mod_bullet_power_rain_of_fire_burn")

	ctrl.cooldown = 60
	ctrl.meteor_count = 3
	ctrl.upgrade_cataclysm = false
	bullet.bullet.damage_factor = 1
	bullet.bullet.hit_decal = "decal_power_rain_of_fire_crack"
	bullet.upgrade_scorching_floor = false
	bullet.upgrade_slow_floor = false
	bullet.upgrade_extra_explosion = false
	burn.aura.duration = 3
	slow.aura.duration = 3
	burn_mod.dps.damage_inc = 0
	scorch.duration = 0.5

	if level >= 2 then
		ctrl.cooldown = 55
		bullet.bullet.damage_factor = 1.1
	end

	if level >= 3 then
		bullet.upgrade_scorching_floor = true
		bullet.bullet.hit_decal = "decal_power_rain_of_fire_scorch"
	end

	if level >= 4 then
		burn.aura.duration = 7
		slow.aura.duration = 7
		burn_mod.dps.damage_inc = 2
		scorch.duration = 4.5
		ctrl.meteor_count = 5
	end

	if level >= 5 then
		bullet.upgrade_slow_floor = true
		bullet.upgrade_extra_explosion = true
	end

	if level >= 6 then
		ctrl.upgrade_cataclysm = true
		ctrl.cooldown = 45
	end
end

return M
