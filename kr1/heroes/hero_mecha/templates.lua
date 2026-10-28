local scripts = require("scripts")
local E = require("entity_db")
local LU = require("level_utils")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local UP = require("kr1.upgrades")
local V = require("lib.klua.vector")
local bit = require("bit")
local km = require("lib.klua.macros")
local HU = require("hero_utils")
local band = bit.band
local bor = bit.bor
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local vv = V.vv
local tt

local function drone_hero_mecha_update(this, store)
	local sd = this.render.sprites[1]
	local ss = this.render.sprites[2]
	local a = this.ranged.attacks[1]
	local fm = this.force_motion
	local hero = this.owner

	local function find_target(range)
		local target, targets = U.find_nearest_enemy(store, hero.pos, 0, range, a.vis_flags, a.vis_bans)

		if not target then
			return nil
		end

		local drones = LU.list_entities(store.entities, this.template_name)
		local drone_target_ids = table.map(drones, function(k, v)
			return v._chasing_target_id or 0
		end)
		local untargeted = table.filter(targets, function(k, v)
			return not table.contains(drone_target_ids, v.id) and V.dist2(v.pos.x, v.pos.y, hero.pos.x, hero.pos.y) < range * range
		end)

		for _, nt in ipairs(targets) do
			if table.contains(untargeted, nt) then
				return nt
			end
		end

		return target
	end

	local shoot_ts, search_ts = 0, 0
	local target, dist
	local dest = V.v(this.pos.x, this.pos.y)

	this.start_ts = store.tick_ts
	fm.a_step = fm.a_step + math.random(-3, 3)
	this.tween.ts = U.frandom(0, 1)

	local oos = {V.v(-15, 0), V.v(10, 7)}
	local oo = oos[this.drone_id]

	a.damage_min = a.damage_min_config[this.level]
	a.damage_max = a.damage_max_config[this.level]

	U.animation_start_specific(this, "idle", true, store.tick_ts, true, 1)

	local initial_pos_offset = {}

	if this.drone_id == 1 then
		initial_pos_offset = V.v(-50, 40)
	else
		initial_pos_offset = V.v(40, 30)
	end

	repeat
		dest.x, dest.y = this.owner.pos.x + initial_pos_offset.x, this.owner.pos.y + initial_pos_offset.y
		sd.flip_x = dest.x < this.pos.x

		U.force_motion_step(this, store.tick_length, dest)
		coroutine.yield()

		dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)
	until dist < 5

	while store.tick_ts - this.start_ts <= this.duration[this.level] do
		search_ts = store.tick_ts
		target = find_target(a.max_range)

		if target then
			this._chasing_target_id = target.id
		else
			this._chasing_target_id = nil
		end

		if target then
			repeat
				dest.x, dest.y = target.pos.x + oo.x, target.pos.y + oo.y
				sd.flip_x = dest.x < this.pos.x

				U.force_motion_step(this, store.tick_length, dest)
				coroutine.yield()

				dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)
			until dist < a.shoot_range or target.health.dead or band(a.vis_flags, target.vis.bans) ~= 0

			if store.entities[target.id] and not target.health.dead and band(a.vis_flags, target.vis.bans) == 0 and store.tick_ts - shoot_ts > a.cooldown then
				if math.random() < a.sound_chance then
					S:queue(a.sound)
				end

				U.animation_start(this, a.animation, this.pos.x < target.pos.x, store.tick_ts, false, 1)

				for i = 1, a.hit_cycles do
					local hit_ts = store.tick_ts

					while store.tick_ts - hit_ts < a.hit_time do
						U.force_motion_step(this, store.tick_length, dest)

						sd.flip_x = this.pos.x < target.pos.x

						coroutine.yield()
					end

					local d = SU.create_attack_damage(a, target.id, this)

					queue_damage(store, d)

					local fx = E:create_entity(a.hit_fx)

					fx.pos.x, fx.pos.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
					fx.render.sprites[1].ts = store.tick_ts
					fx.render.sprites[1].runs = 0

					simulation:queue_insert_entity(fx)
				end

				while not U.animation_finished_default(this) do
					U.force_motion_step(this, store.tick_length, dest)

					sd.flip_x = this.pos.x < target.pos.x

					coroutine.yield()
				end

				U.animation_start(this, "idle", nil, store.tick_ts, true, 1)

				shoot_ts = store.tick_ts
			end

			U.animation_start(this, "idle", nil, store.tick_ts, true, 1)
		end

		this._chasing_target_id = nil

		while store.tick_ts - search_ts < a.search_cooldown do
			U.force_motion_step(this, store.tick_length, dest)
			coroutine.yield()
		end
	end

	U.y_ease_keys(store, {sd, sd.offset, ss}, {"alpha", "y", "alpha"}, {255, this.flight_height, 255}, {0, 85, 0}, 0.4)
	simulation:queue_remove_entity(this)
end

local function bullet_hero_mecha_insert(this, store)
	local b = this.bullet
	local source = store.entities[b.source_id]
	local fx

	if source.ranged.attacks[1].disabled then
		fx = E:create_entity(b.spawn_fx_2)
	else
		fx = E:create_entity(b.spawn_fx_1)
	end

	fx.pos:copy(source.pos)

	local s = fx.render.sprites[1]

	s.ts = store.tick_ts
	s.flip_x = source.render.sprites[1].flip_x

	simulation:queue_insert_entity(fx)

	return true
end

local function bullet_hero_mecha_update(this, store)
	local b = this.bullet
	local fm = this.force_motion
	local target = store.entities[b.target_id]
	local source = store.entities[b.source_id]
	local ps
	local last_pos = V.vclone(this.pos)
	local started_curve = false
	local time_to_live = 2

	local function angle_between(x1, y1, x2, y2)
		local dot = x1 * x2 + y1 * y2
		local mags = V.len(x1, y1) * V.len(x2, y2)

		return math.acos(dot / mags)
	end

	local function move_step(dest)
		local last_dir = v(this.pos.x - last_pos.x, this.pos.y - last_pos.y)

		last_pos.x, last_pos.y = this.pos.x, this.pos.y

		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist2 = V.len2(dx, dy)
		local dist = V.len(dx, dy)
		local nx, ny = V.mul(fm.max_v, V.normalize(dx, dy))
		local stx, sty = V.sub(nx, ny, fm.v.x, fm.v.y)
		local dist_limit = 12 * fm.max_v * store.tick_length

		if dist2 <= dist_limit * dist_limit then
			stx, sty = V.mul(fm.max_a, V.normalize(stx, sty))
		end

		fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step, stx, sty)))
		fm.v.x, fm.v.y = V.trim(fm.max_v, V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y)))
		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
		fm.a.x, fm.a.y = 0, 0

		local new_dir = v(this.pos.x - last_pos.x, this.pos.y - last_pos.y)
		local angle_dif = angle_between(new_dir.x, new_dir.y, last_dir.x, last_dir.y)
		local max_angle_rot = km.deg2rad(this.max_rotation_speed)

		if started_curve and store.tick_ts - b.ts > 0.25 then
			dist_limit = 20

			local max_mult = 5

			max_angle_rot = max_angle_rot * (1 + km.clamp(0, max_mult, max_mult * (dist_limit / dist)))
		end

		if max_angle_rot < math.abs(angle_dif) then
			local dot = dx * -last_dir.y + dy * last_dir.x

			if dot < 0 then
				new_dir.x, new_dir.y = V.rotate(-max_angle_rot, last_dir.x, last_dir.y)
			else
				new_dir.x, new_dir.y = V.rotate(max_angle_rot, last_dir.x, last_dir.y)
			end

			if V.len2(new_dir.x, new_dir.y) < this.min_speed * this.min_speed then
				new_dir.x, new_dir.y = V.normalize(new_dir.x, new_dir.y)
				new_dir.x, new_dir.y = new_dir.x * this.min_speed, new_dir.y * this.min_speed
			end

			this.pos.x, this.pos.y = last_pos.x + new_dir.x, last_pos.y + new_dir.y
		end

		return dist2 <= fm.max_v * store.tick_length * 2 * (fm.max_v * store.tick_length * 2)
	end

	local function y_fly_to_pos(target_pos)
		local dx, dy = V.sub(target_pos.x, target_pos.y, this.pos.x, this.pos.y)
		local dist2 = V.len2(dx, dy)

		while dist2 > 400 do
			move_step(target_pos)

			this.render.sprites[1].r = V.angleTo(this.pos.x - last_pos.x, this.pos.y - last_pos.y)
			ps.particle_system.emit_offset.x, ps.particle_system.emit_offset.y = V.rotate(this.render.sprites[1].r, ps.emit_offset_relative.x, ps.emit_offset_relative.y)
			dx, dy = V.sub(target_pos.x, target_pos.y, this.pos.x, this.pos.y)
			dist2 = V.len2(dx, dy)

			coroutine.yield()
		end
	end

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.emit = true
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	local target_pos
	local impulse_length = 35

	if source.render.sprites[1].flip_x then
		fm.a.x, fm.a.y = -80, 0
		target_pos = v(b.from.x - impulse_length, b.from.y)
	else
		fm.a.x, fm.a.y = 80, 0
		target_pos = v(b.from.x + impulse_length, b.from.y)
	end

	last_pos.x, last_pos.y = this.pos.x - fm.a.x, this.pos.y - fm.a.y

	y_fly_to_pos(target_pos)

	::attack_start::

	fm.a_step = 5
	fm.max_a = 1800
	fm.max_v = 360
	b.ts = store.tick_ts
	started_curve = true

	if target and band(target.vis.flags, F_FLYING) ~= 0 then
		b.ignore_hit_offset = false
	end

	while true do
		target = store.entities[b.target_id]

		if target and target.health and not target.health.dead and band(target.vis.bans, F_RANGED) == 0 then
			local hit_offset = V.v(0, 0)

			if not b.ignore_hit_offset then
				hit_offset.x = target.unit.hit_offset.x
				hit_offset.y = target.unit.hit_offset.y
			end

			b.to.x, b.to.y = target.pos.x + hit_offset.x, target.pos.y + hit_offset.y
		end

		if move_step(b.to) then
			break
		end

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - last_pos.x, this.pos.y - last_pos.y)
			ps.particle_system.emit_offset.x, ps.particle_system.emit_offset.y = V.rotate(this.render.sprites[1].r, ps.emit_offset_relative.x, ps.emit_offset_relative.y)
		end

		if time_to_live < store.tick_ts - b.ts then
			target = nil

			break
		end

		coroutine.yield()
	end

	if not target or target.health.dead then
		target = U.find_first_enemy_in_range_filter_off(this.pos, b.damage_radius * 3, F_RANGED, F_NONE)

		if target then
			b.from.x, b.from.y = this.pos.x, this.pos.y
			b.target_id = target.id

			goto attack_start
		end
	end

	local mods

	if b.mod then
		mods = {b.mod}
	elseif b.mods then
		mods = b.mods
	end

	if target and band(target.vis.flags, F_FLYING) ~= 0 then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)

		if mods then
			for _, mod_name in ipairs(mods) do
				local mod = E:create_entity(mod_name)

				mod.modifier.damage_factor = b.damage_factor
				mod.modifier.target_id = target.id
				mod.modifier.source_id = this.id

				if U.flags_pass(target.vis, mod.modifier) then
					simulation:queue_insert_entity(mod)
				end
			end
		end

		S:queue(this.sound_events.hit)
	else
		local enemies = U.find_enemies_in_range_filter_off(this.pos, b.damage_radius, b.damage_flags, b.damage_bans)

		if enemies then
			for i = 1, #enemies do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops(b, enemy.id, this.id)

				if UP:get_upgrade("engineer_efficiency") then
					d.value = b.damage_max
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, b.damage_radius)

					d.value = b.damage_max - (b.damage_max - b.damage_min) * dist_factor
				end

				d.value = b.damage_factor * d.value

				queue_damage(store, d)

				if mods then
					for _, mod_name in ipairs(mods) do
						local mod = E:create_entity(mod_name)

						mod.modifier.damage_factor = b.damage_factor
						mod.modifier.target_id = enemy.id
						mod.modifier.source_id = this.id

						if U.flags_pass(enemy.vis, mod.modifier) then
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end

			S:queue(this.sound_events.hit)
		end
	end

	this.render.sprites[1].hidden = true

	if b.hit_fx then
		local fx = E:create_entity(b.hit_fx)

		if target then
			fx.pos.x, fx.pos.y = b.to.x, b.to.y
		else
			fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		end

		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].runs = 0

		simulation:queue_insert_entity(fx)
	end

	if ps and ps.particle_system.emit then
		ps.particle_system.emit = false

		U.y_wait_unconditional(store, ps.particle_system.particle_lifetime[2])
	end

	simulation:queue_remove_entity(this)
end

local function aura_bullet_hero_mecha_mine_insert(this, store)
	this.aura.ts = store.tick_ts

	if this.render then
		for _, s in ipairs(this.render.sprites) do
			s.ts = store.tick_ts
		end
	end

	U.animation_start_default(this, "in", nil, store.tick_ts, false)

	this.actual_duration = this.aura.duration

	return true
end

local function aura_bullet_hero_mecha_mine_update(this, store)
	U.y_animation_wait_default(this)
	U.animation_start_default(this, "idle", nil, store.tick_ts, true)

	while true do
		local targets = U.find_enemies_in_range_filter_off(this.pos, this.aura.radius * 0.75, this.aura.vis_flags, this.aura.vis_bans_trigger)

		if this.trigger or targets and #targets > 0 then
			S:queue(this.sound_explode)
			U.y_animation_play(this, "on", nil, store.tick_ts, false)

			local targets = U.find_enemies_in_range_filter_off(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans_damage)

			if targets and #targets > 0 then
				for _, enemy in ipairs(targets) do
					if enemy and not enemy.dead then
						local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, this.pos, this.aura.radius)
						local d = E.assign_damage(this.damage_type, math.floor(this.damage_max - (this.damage_max - this.damage_min) * dist_factor), this.id, enemy.id)

						queue_damage(store, d)
					end
				end
			end

			local fx = E:create_entity(this.explosion_fx)

			fx.pos:copy(this.pos)

			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].runs = 0

			simulation:queue_insert_entity(fx)

			this.render.sprites[1].hidden = true

			for _, e in pairs(store.entities) do
				if e.template_name == "hero_mecha" then
					e.max_mines_near = false

					break
				end
			end

			break
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function zeppelin_hero_mecha_update(this, store)
	local a = this.ranged.attacks[1]
	local shoot_ts = store.tick_ts
	local fps_normal = 30
	local fps_slow = 20
	local d = E:create_entity(this.decal)

	d.render.sprites[1].ts = store.tick_ts
	d.pos = V.vclone(this.target_pos)

	simulation:queue_insert_entity(d)

	local margin = this.flight_height + 100

	if this.pos.y > 768 - margin then
		this.pos.y = 768 - margin
		this.exit_pos.y = 768 - margin
		this.target_pos.y = 768 - margin
	end

	U.animation_start_group(this, "idle", this.exit_pos.x < this.pos.x, store.tick_ts, true, "layers")

	while math.abs(this.pos.x - this.target_pos.x) > this.attack_radius * 1.75 do
		U.force_motion_step(this, store.tick_length, this.target_pos)
		coroutine.yield()
	end

	this.tween.disabled = false
	this.tween.ts = store.tick_ts

	while this.render.sprites[2].offset.y > this.flight_height_attack + 5 do
		local height_factor = (this.render.sprites[2].offset.y - this.flight_height_attack) / (this.flight_height - this.flight_height_attack)

		this.force_motion.max_v = this.speed_in_range + (this.speed_out_of_range - this.speed_in_range) * height_factor * 0.5

		U.force_motion_step(this, store.tick_length, this.exit_pos)
		coroutine.yield()
	end

	while math.abs(this.pos.x - this.target_pos.x) <= this.attack_radius do
		if store.tick_ts - shoot_ts > a.cooldown then
			local flight_time = E:get_template(a.bullet).bullet.flight_time
			local target, _, pred_pos = U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range, flight_time + a.shoot_time, a.vis_flags, a.vis_bans)

			if target and not target.health.dead and pred_pos then
				local an, af = U.animation_name_facing_point(this, a.animation, this.exit_pos, 3)

				U.animation_start(this, an, af, store.tick_ts, false, 3)
				U.animation_start(this, an, af, store.tick_ts, false, 4)

				local a_ts = store.tick_ts

				while store.tick_ts - a_ts < a.shoot_time do
					U.force_motion_step(this, store.tick_length, this.exit_pos)
					coroutine.yield()
				end

				local b = E:create_entity(a.bullet)

				b.bullet.from = V.v(this.pos.x + a.bullet_start_offset[1].x, this.pos.y + a.bullet_start_offset[1].y + this.render.sprites[2].offset.y)

				b.bullet.to:copy(pred_pos)

				b.bullet.source_id = this.id
				b.bullet.target_id = target.id

				b.pos:copy(b.bullet.from)

				b.bullet.level = this.level
				b.bullet.source_id = this.id

				simulation:queue_insert_entity(b)

				while not U.animation_finished(this, 3) do
					U.force_motion_step(this, store.tick_length, this.exit_pos)
					coroutine.yield()
				end

				U.animation_start(this, "idle", this.exit_pos.x < this.pos.x, store.tick_ts, true, 3)
				U.animation_start(this, "idle", this.exit_pos.x < this.pos.x, store.tick_ts, true, 4)

				shoot_ts = store.tick_ts
			end
		end

		if (not this.render.sprites[5].fps or this.render.sprites[5].fps == fps_normal) and this.render.sprites[5].sync_flag then
			this.render.sprites[2].fps = fps_slow
			this.render.sprites[3].fps = fps_slow
			this.render.sprites[5].fps = fps_slow

			for i = 1, #this.render.sprites do
				if this.render.sprites[i].group == "layers" then
					U.animation_start(this, "idle", this.exit_pos.x < this.pos.x, store.tick_ts, true, i, true)
				end
			end
		end

		local height_factor = (this.render.sprites[2].offset.y - this.flight_height_attack) / (this.flight_height - this.flight_height_attack)

		this.force_motion.max_v = this.speed_in_range + (this.speed_out_of_range - this.speed_in_range) * height_factor

		U.force_motion_step(this, store.tick_length, this.exit_pos)
		coroutine.yield()
	end

	this.tween.reverse = true
	this.tween.ts = store.tick_ts
	this.force_motion.max_v = this.speed_out_of_range * 0.7

	while math.abs(this.pos.x - this.exit_pos.x) > 10 do
		if this.render.sprites[5].fps == fps_slow and this.render.sprites[5].sync_flag then
			this.render.sprites[2].fps = fps_normal
			this.render.sprites[3].fps = fps_normal
			this.render.sprites[5].fps = fps_normal

			for i = 1, #this.render.sprites do
				if this.render.sprites[i].group == "layers" then
					U.animation_start(this, "idle", this.exit_pos.x < this.pos.x, store.tick_ts, true, i, true)
				end
			end
		end

		U.force_motion_step(this, store.tick_length, this.exit_pos)

		local height_factor = (this.render.sprites[2].offset.y - this.flight_height_attack) / (this.flight_height - this.flight_height_attack)

		this.force_motion.max_v = this.speed_in_range + (this.speed_out_of_range - this.speed_in_range) * height_factor

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function bullet_hero_mecha_mine_insert(this, store)
	local b = this.bullet

	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)

	if b.rotation_speed then
		this.render.sprites[1].r = 0
		b.rotation_speed = b.rotation_speed * (b.to.x > b.from.x and -1 or 1)
	end

	this.render.sprites[1].hidden = false

	return true
end

local function bullet_hero_mecha_mine_update(this, store)
	local b = this.bullet

	this.render.sprites[1].hidden = false

	while store.tick_ts - b.ts + store.tick_length < b.flight_time do
		coroutine.yield()

		b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)

		if b.rotation_speed then
			this.render.sprites[1].r = this.render.sprites[1].r + b.rotation_speed * store.tick_length
		end
	end

	if b.hit_payload then
		local hp

		if type(b.hit_payload) == "string" then
			hp = E:create_entity(b.hit_payload)
		else
			hp = b.hit_payload
		end

		hp.pos.x, hp.pos.y = b.to.x, b.to.y
		hp.source_id = b.source_id

		if hp.aura then
			hp.aura.level = this.bullet.level
		end

		simulation:queue_insert_entity(hp)
	end

	simulation:queue_remove_entity(this)
end

local function hero_mecha_level_up(this, store, initial)
	local hl, ls = level_up_basic(this)

	this.ranged.attacks[1].damage_min = ls.ranged_damage_min[hl]
	this.ranged.attacks[1].damage_max = ls.ranged_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	upgrade_skill(this, "goblidrones", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
	end)
	upgrade_skill(this, "tar_bomb", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local bullet = E:get_template(a.bullet)
		local tar = E:get_template(bullet.bullet.hit_payload)

		tar.aura.duration = s.duration[s.level]
		tar.tween.props[1].keys = {{0, 255}, {tar.aura.duration - 0.5, 255}, {tar.aura.duration, 0}}
	end)
	upgrade_skill(this, "power_slam", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
	end)
	upgrade_skill(this, "mine_drop", function(this, s)
		local a = this.timed_attacks.list[4]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local bullet = E:get_template(a.bullet)
		local mine = E:get_template(bullet.bullet.hit_payload)

		mine.damage_min = s.damage_min[s.level]
		mine.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil
		this.ultimate.cooldown = s.cooldown[s.level]

		local uc = E:get_template(s.controller_name)

		uc.cooldown = s.cooldown[s.level]

		local zep = E:get_template(uc.entity)
		local bullet = E:get_template(zep.ranged.attacks[1].bullet)

		bullet.bullet.level = s.level
		bullet.bullet.damage_min = s.damage_min[s.level]
		bullet.bullet.damage_max = s.damage_max[s.level]
	end)
	update_hp(this)
end

local function hero_mecha_update(this, store)
	local h = this.health
	local a, skill
	local goblidrones_attack = this.timed_attacks.list[1]
	local tar_bomb_attack = this.timed_attacks.list[2]
	local power_slam_attack = this.timed_attacks.list[3]
	local mine_drop_attack = this.timed_attacks.list[4]
	local last_ts = store.tick_ts
	local idle_ts = store.tick_ts
	local ps1, ps2

	this.max_mines_near = false

	local function calculate_mine_pos(near_mines)
		local a = mine_drop_attack
		local valid_positions = P:get_all_valid_pos(this.pos.x, this.pos.y, a.min_range, a.max_range, bor(TERRAIN_LAND, TERRAIN_ICE), function(x, y)
			for _, mine in ipairs(near_mines) do
				if V.dist(mine.pos.x, mine.pos.y, x, y) <= a.min_dist_between_mines then
					return false
				end
			end

			return true
		end, nil, {1, 2, 3})

		return valid_positions[math.random(1, #valid_positions)]
	end

	if not goblidrones_attack.disabled then
		goblidrones_attack.ts = store.tick_ts - goblidrones_attack.cooldown
	end

	if not tar_bomb_attack.disabled then
		tar_bomb_attack.ts = store.tick_ts - tar_bomb_attack.cooldown
	end

	if not power_slam_attack.disabled then
		power_slam_attack.ts = store.tick_ts - power_slam_attack.cooldown
	end

	if not mine_drop_attack.disabled then
		mine_drop_attack.ts = store.tick_ts - mine_drop_attack.cooldown
	end

	this.health_bar.hidden = false
	ps1 = E:create_entity(this.particles_name_1)
	ps1.particle_system.emit = true
	ps1.particle_system.track_id = this.id

	simulation:queue_insert_entity(ps1)

	ps2 = E:create_entity(this.particles_name_2)
	ps2.particle_system.emit = true
	ps2.particle_system.track_id = this.id

	simulation:queue_insert_entity(ps2)

	while true do
		if h.dead then
			ps1.particle_system.emit = false
			ps2.particle_system.emit = false

			SU.y_hero_death_and_respawn(store, this)

			ps1.particle_system.emit = true
			ps2.particle_system.emit = true
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_hero_mecha_continue
				end

				this.max_mines_near = false
				idle_ts = store.tick_ts
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.goblidrones

			if not a.disabled and store.tick_ts - a.ts > a.cooldown and store.tick_ts - last_ts > a.min_cooldown then
				local target, targets = U.find_foremost_enemy_in_range_filter_off(this.pos, a.spawn_range, false, a.vis_flags, a.vis_bans)

				if not targets or #targets < a.min_targets then
				-- block empty
				else
					local start_ts = store.tick_ts
					local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

					U.animation_start(this, an, af, store.tick_ts, false, nil)
					S:queue(a.sound)

					if SU.y_hero_wait(store, this, a.cast_time) then
						goto label_hero_mecha_continue
					end

					for i = 1, 2 do
						local d = E:create_entity(a.entity)

						d.pos = V.vclone(this.pos)

						if this.render.sprites[1].flip_x then
							d.pos.x, d.pos.y = this.pos.x - a.spawn_pos_offset.x, this.pos.y - a.spawn_pos_offset.y
						else
							d.pos.x, d.pos.y = this.pos.x + a.spawn_pos_offset.x, this.pos.y + a.spawn_pos_offset.y
						end

						d.ranged.attacks[1].xp_dest_id = this.id
						d.owner = this
						d.drone_id = i
						d.level = this.hero.skills.goblidrones.level

						simulation:queue_insert_entity(d)
					end

					SU.y_hero_animation_wait(this)

					a.ts = start_ts
					last_ts = a.ts

					SU.hero_gain_xp_from_skill(this, skill)
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.tar_bomb

			if not a.disabled and store.tick_ts - a.ts > a.cooldown and store.tick_ts - last_ts > a.min_cooldown then
				local target, targets, pred_pos = U.find_foremost_enemy_in_range_filter_off(this.pos, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans)

				if not targets or #targets < a.min_targets or not pred_pos then
					a.ts = a.ts + fts(10)
				else
					local nearest = P:nearest_nodes(pred_pos.x, pred_pos.y)

					if #nearest > 0 then
						local path_pi, path_spi, path_ni = unpack(nearest[1])

						path_spi = 1
						pred_pos = P:node_pos(path_pi, path_spi, path_ni)
					end

					local start_ts = store.tick_ts
					local an, af = U.animation_name_facing_point(this, a.animation, pred_pos)

					U.animation_start(this, an, af, store.tick_ts, false, nil)
					S:queue(a.sound)

					if SU.y_hero_wait(store, this, a.cast_time) then
						goto label_hero_mecha_continue
					end

					local offset_x = a.bullet_start_offset[1].x

					if af then
						offset_x = -offset_x
					end

					local b = E:create_entity(a.bullet)

					b.bullet.from = V.v(this.pos.x + offset_x, this.pos.y + a.bullet_start_offset[1].y)
					b.bullet.to = V.v(pred_pos.x, pred_pos.y)
					b.bullet.target_id = target.id
					b.bullet.source_id = this.id

					b.pos:copy(b.bullet.from)
					simulation:queue_insert_entity(b)
					SU.y_hero_animation_wait(this)

					a.ts = start_ts
					last_ts = a.ts

					SU.hero_gain_xp_from_skill(this, skill)
				end
			end

			a = this.timed_attacks.list[3]
			skill = this.hero.skills.power_slam

			if not a.disabled and store.tick_ts - a.ts > a.cooldown and store.tick_ts - last_ts > a.min_cooldown then
				local _, targets, pred_pos = U.find_foremost_enemy_in_range_filter_off(this.pos, a.damage_radius, 0, a.vis_flags, a.vis_bans_trigger)

				if not targets or #targets < a.min_targets or not pred_pos then
					a.ts = a.ts + fts(10)
				else
					local start_ts = store.tick_ts
					local an, af = U.animation_name_facing_point(this, a.animation, pred_pos)

					U.animation_start(this, an, af, store.tick_ts, false, nil)
					S:queue(a.sound)

					if SU.y_hero_wait(store, this, a.cast_time) then
						goto label_hero_mecha_continue
					end

					local target, targets = U.find_foremost_enemy_in_range_filter_off(this.pos, a.damage_radius, 0, a.vis_flags, a.vis_bans_damage)

					if target and targets then
						for _, enemy in ipairs(targets) do
							if enemy and not enemy.dead then
								local d = E.assign_damage(a.damage_type, math.random(a.damage_min[skill.level], a.damage_max[skill.level]), this.id, enemy.id)

								queue_damage(store, d)

								local mod = E:create_entity(a.mod)

								mod.modifier.target_id = enemy.id
								mod.modifier.source_id = this.id
								mod.duration = fts(skill.stun_time[skill.level])

								simulation:queue_insert_entity(mod)
							end
						end
					end

					SU.y_hero_animation_wait(this)

					a.ts = start_ts
					last_ts = a.ts

					SU.hero_gain_xp_from_skill(this, skill)
				end
			end

			a = this.timed_attacks.list[4]
			skill = this.hero.skills.mine_drop

			if not a.disabled and store.tick_ts - a.ts > a.cooldown and store.tick_ts - last_ts > a.min_cooldown and store.tick_ts - idle_ts > a.cooldown and not this.max_mines_near and store.wave_group_number > 0 then
				local target, _, _ = U.find_foremost_enemy_in_range_filter_off(this.pos, a.max_range, 0, a.vis_flags, a.vis_bans)

				if target then
					a.ts = a.ts + fts(10)
				else
					local near_mines = table.filter(store.entities, function(k, v)
						return v.template_name == "aura_bullet_hero_mecha_mine" and V.dist2(v.pos.x, v.pos.y, this.pos.x, this.pos.y) <= a.max_range * a.max_range
					end)

					if #near_mines >= skill.max_mines[skill.level] then
						this.max_mines_near = true
						a.ts = a.ts + fts(10)
					else
						local mine_pos = calculate_mine_pos(near_mines)

						if not mine_pos then
							this.max_mines_near = true
							a.ts = a.ts + fts(10)
						else
							local all_mines = table.filter(store.entities, function(k, v)
								return v.template_name == "aura_bullet_hero_mecha_mine"
							end)

							if #all_mines >= skill.max_mines[skill.level] then
								local far_mines = table.filter(all_mines, function(k, v)
									return V.dist2(v.pos.x, v.pos.y, this.pos.x, this.pos.y) > a.max_range * a.max_range
								end)

								table.sort(far_mines, function(e1, e2)
									return V.dist2(e1.pos.x, e1.pos.y, this.pos.x, this.pos.y) > V.dist2(e2.pos.x, e2.pos.y, this.pos.x, this.pos.y)
								end)

								far_mines[1].trigger = true
							end

							local start_ts = store.tick_ts
							local an, af = U.animation_name_facing_point(this, a.animation, mine_pos)

							U.animation_start(this, an, af, store.tick_ts, false, nil)
							S:queue(a.sound_cast)

							if SU.y_hero_wait(store, this, a.cast_time) then
								goto label_hero_mecha_continue
							end

							local b = E:create_entity(a.bullet)

							b.bullet.from = V.v(this.pos.x + a.bullet_start_offset[1].x, this.pos.y + a.bullet_start_offset[1].y)
							b.bullet.to = V.v(mine_pos.x, mine_pos.y)
							b.bullet.source_id = this.id

							b.pos:copy(b.bullet.from)
							simulation:queue_insert_entity(b)
							SU.y_hero_animation_wait(this)

							a.ts = start_ts
							last_ts = a.ts

							SU.hero_gain_xp_from_skill(this, skill)
						end
					end
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local target = U.find_foremost_enemy_in_range_filter_off(this.pos, 200, 0, F_AREA, 0)

				if target and target.pos then
					local e = E:create_entity(this.hero.skills.ultimate.controller_name)

					e.level = this.hero.skills.ultimate.level
					e.pos = V.vclone(target.pos)

					simulation:queue_insert_entity(e)

					this.ultimate.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			do
				local _, sta = SU.y_soldier_ranged_attacks(store, this)

				if sta == A_DONE then
					if this.ranged.attacks[1].disabled then
						this.ranged.attacks[1].disabled = false
						this.ranged.attacks[2].disabled = true
					else
						this.ranged.attacks[1].disabled = true
						this.ranged.attacks[2].disabled = false
					end

					goto label_hero_mecha_continue
				end
			end

			if SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_hero_mecha_continue::

		coroutine.yield()
	end
end

local function hero_mecha_ultimate_update(this, store)
	local function spawn_zeppelin(pi, spi, ni)
		local pos = P:node_pos(pi, spi, ni)
		local x_center = (store.visible_coords.left + store.visible_coords.right) / 2
		local spawn_pos = V.vclone(pos)
		local exit_pos = V.vclone(pos)
		local out_of_screen_offset = 100

		if x_center > spawn_pos.x then
			spawn_pos.x = store.visible_coords.left - out_of_screen_offset
			exit_pos.x = store.visible_coords.right + out_of_screen_offset
		else
			spawn_pos.x = store.visible_coords.right + out_of_screen_offset
			exit_pos.x = store.visible_coords.left - out_of_screen_offset
		end

		local zep = E:create_entity(this.entity)

		zep.pos = V.vclone(spawn_pos)
		zep.target_pos = V.vclone(pos)
		zep.exit_pos = V.vclone(exit_pos)
		zep.sound = this.sound
		zep.level = this.level

		simulation:queue_insert_entity(zep)
	end

	local nearest = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

	if #nearest > 0 then
		local pi, _, ni = unpack(nearest[1])

		if P:is_node_valid(pi, ni) then
			S:queue(this.sound)
			spawn_zeppelin(pi, 1, ni)
		end
	end

	simulation:queue_remove_entity(this)
end

tt = RT("ps_hero_mecha_smoke_1")

AC(tt, "pos", "particle_system", "main_script")

tt.particle_system.name = "hero_onagro_back_smoke_particle_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 10
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_area_spread = v(2, 2)
tt.particle_system.emit_direction = 2 * math.pi / 3
tt.particle_system.emit_speed = {20, 25}
tt.particle_system.emit_offset = v(-30, 45)
tt.particle_system.z = Z_OBJECTS
tt.particle_system.sort_y_offset = -40
tt.main_script.update = scripts.ps_hero_mecha_smoke.update
tt.emit_direction_sides = {2 * math.pi / 3, math.pi / 3}
tt = RT("ps_hero_mecha_smoke_2", "ps_hero_mecha_smoke_1")
tt.particle_system.emit_offset = v(-10, 50)
tt = RT("ps_bullet_hero_mecha_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_onagro_attack_particle_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 50
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_area_spread = v(2, 2)
tt.particle_system.emit_offset = v(0, 0)
tt.particle_system.particle_lifetime = {fts(9), fts(9)}
tt.emit_offset_relative = v(-15, 0)
tt = RT("fx_bullet_hero_mecha_spawn_1", "fx")
tt.render.sprites[1].name = "hero_onagro_attack_1_cannon_particle_idle"
tt = RT("fx_bullet_hero_mecha_spawn_2", "fx")
tt.render.sprites[1].name = "hero_onagro_attack_2_cannon_particle_idle"
tt = RT("fx_bullet_hero_mecha_hit", "fx")
tt.render.sprites[1].name = "hero_onagro_attack_1_hit_idle"
tt = RT("fx_bullet_drone_hero_mecha", "fx")
tt.render.sprites[1].name = "hero_onagro_skill_1_drone_hit_fx_idle"
tt = RT("fx_bullet_hero_mecha_tar_bomb", "fx")
tt.render.sprites[1].name = "hero_onagro_skill_2_hit"
tt = RT("fx_hero_mecha_mine_explosion", "fx")
tt.render.sprites[1].name = "hero_onagro_skill_4_mine_explosion_idle"
tt = RT("fx_bullet_zeppelin_hero_mecha", "fx")
tt.render.sprites[1].name = "hero_onagro_ultimate_hit_idle"
tt = RT("decal_hero_mecha_ultimate", "decal_tween")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "hero_onagro_ultimate_decal"
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{1, 255}, {9, 255}, {12, 0}}
tt.tween.run_once = true
tt = RT("hero_mecha", "hero")

AC(tt, "ranged", "timed_attacks")

tt.hero.level_stats.armor = {0.1, 0.16, 0.22, 0.28, 0.34, 0.4, 0.46, 0.52, 0.58, 0.64}
tt.hero.level_stats.hp_max = {260, 273, 286, 299, 312, 325, 338, 351, 364, 377}
tt.hero.level_stats.ranged_damage_min = {12, 14, 15, 17, 19, 20, 23, 24, 26, 29}
tt.hero.level_stats.ranged_damage_max = {18, 20, 24, 26, 28, 31, 34, 37, 40, 45}
tt.hero.skills.goblidrones = CC("hero_skill")
tt.hero.skills.goblidrones.cooldown = {25, 25, 25}
tt.hero.skills.goblidrones.units = 2
tt.hero.skills.goblidrones.spawn_range = 110
tt.hero.skills.goblidrones.min_targets = 1
tt.hero.skills.goblidrones.attack_cooldown = 1
tt.hero.skills.goblidrones.min_range = 10
tt.hero.skills.goblidrones.max_range = 100
tt.hero.skills.goblidrones.damage_type = DAMAGE_SHOT
tt.hero.skills.goblidrones.damage_min = {4, 7, 10}
tt.hero.skills.goblidrones.damage_max = {5, 10, 15}
tt.hero.skills.goblidrones.xp_gain = {200, 400, 600}
tt.hero.skills.goblidrones.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.tar_bomb = CC("hero_skill")
tt.hero.skills.tar_bomb.cooldown = {30, 28, 26}
tt.hero.skills.tar_bomb.duration = {5, 6, 7}
tt.hero.skills.tar_bomb.min_range = 50
tt.hero.skills.tar_bomb.max_range = 200
tt.hero.skills.tar_bomb.min_targets = 1
tt.hero.skills.tar_bomb.xp_gain = {240, 448, 624}
tt.hero.skills.tar_bomb.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.power_slam = CC("hero_skill")
tt.hero.skills.power_slam.cooldown = {20, 20, 20}
tt.hero.skills.power_slam.damage_type = DAMAGE_PHYSICAL
tt.hero.skills.power_slam.damage_radius = 85
tt.hero.skills.power_slam.damage_min = {30, 60, 90}
tt.hero.skills.power_slam.damage_max = {30, 60, 90}
tt.hero.skills.power_slam.stun_time = {30, 45, 60}
tt.hero.skills.power_slam.xp_gain = {160, 320, 480}
tt.hero.skills.power_slam.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.mine_drop = CC("hero_skill")
tt.hero.skills.mine_drop.cooldown = {10, 8, 6}
tt.hero.skills.mine_drop.max_mines = {2, 3, 4}
tt.hero.skills.mine_drop.min_range = 35
tt.hero.skills.mine_drop.max_range = 80
tt.hero.skills.mine_drop.damage_min = {16, 24, 32}
tt.hero.skills.mine_drop.damage_max = {26, 38, 50}
tt.hero.skills.mine_drop.xp_gain = {80, 128, 144}
tt.hero.skills.mine_drop.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "controller_hero_mecha_ultimate"
tt.hero.skills.ultimate.cooldown = {36, 36, 36, 36}
tt.hero.skills.ultimate.min_range = 10
tt.hero.skills.ultimate.max_range = 200
tt.hero.skills.ultimate.damage_min = {40, 48, 56, 64}
tt.hero.skills.ultimate.damage_max = {60, 72, 84, 96}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.ultimate = {
	ts = 0,
	cooldown = 36
}
tt.hero.fn_level_up = hero_mecha_level_up
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 62)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.info.hero_portrait = "kr5_hero_portraits_0009"
tt.info.portrait = "kr5_info_portraits_heroes_0009"
tt.main_script.update = hero_mecha_update
tt.motion.max_speed = 50
tt.regen.cooldown = 1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_onagro_hero"
tt.render.sprites[1].draw_order = DO_HEROES
tt.render.sprites[1].scale = vv(1.15)
tt.ui.click_rect = r(-30, -4, 60, 60)
tt.particles_name_1 = "ps_hero_mecha_smoke_1"
tt.particles_name_2 = "ps_hero_mecha_smoke_2"
tt.soldier.melee_slot_offset = v(20, 0)
tt.sound_events.change_rally_point = "HeroMechaTaunt"
tt.sound_events.death = "HeroMechaDeath"
tt.sound_events.respawn = "HeroMechaTauntIntro"
tt.sound_events.hero_room_select = "HeroMechaTauntSelect"
tt.unit.hit_offset = v(0, 14)
tt.unit.mod_offset = v(0, 13)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "attack_1"
tt.ranged.attacks[1].bullet = "bullet_hero_mecha"
tt.ranged.attacks[1].bullet_start_offset = {v(10, 24)}
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].max_range = 250
tt.ranged.attacks[1].shoot_time = fts(8)
tt.ranged.attacks[1].sound = "HeroMechaBasicAttack"
tt.ranged.attacks[1].xp_gain_factor = 2.15
tt.ranged.attacks[1].basic_attack = true
tt.ranged.attacks[2] = table.deepclone(tt.ranged.attacks[1])
tt.ranged.attacks[2].animation = "attack_2"
tt.ranged.attacks[2].bullet_start_offset = {v(40, 26)}
tt.ranged.attacks[2].disabled = true
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "skill_1"
tt.timed_attacks.list[1].cast_time = fts(32)
tt.timed_attacks.list[1].entity = "drone_hero_mecha"
tt.timed_attacks.list[1].spawn_pos_offset = v(-10, 0)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].sound = "HeroMechaGoblidroneCast"
tt.timed_attacks.list[1].min_cooldown = 5
tt.timed_attacks.list[1].spawn_range = 110
tt.timed_attacks.list[1].min_targets = 1
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animation = "skill_2"
tt.timed_attacks.list[2].bullet = "bullet_hero_mecha_tar_bomb"
tt.timed_attacks.list[2].bullet_start_offset = {v(15, 22)}
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].cast_time = fts(20)
tt.timed_attacks.list[2].node_prediction = fts(60)
tt.timed_attacks.list[2].max_range = 200
tt.timed_attacks.list[2].min_targets = 1
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING, F_CLIFF)
tt.timed_attacks.list[2].sound = "HeroMechaTarBombCast"
tt.timed_attacks.list[2].min_cooldown = 5
tt.timed_attacks.list[3] = CC("custom_attack")
tt.timed_attacks.list[3].animation = "skill_3"
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].cast_time = fts(25)
tt.timed_attacks.list[3].damage_type = DAMAGE_PHYSICAL
tt.timed_attacks.list[3].damage_radius = 85
tt.timed_attacks.list[3].damage_max = {30, 60, 90}
tt.timed_attacks.list[3].damage_min = {30, 60, 90}
tt.timed_attacks.list[3].min_targets = 2
tt.timed_attacks.list[3].mod = "mod_hero_mecha_power_slam_stun"
tt.timed_attacks.list[3].vis_bans_trigger = bor(F_FLYING)
tt.timed_attacks.list[3].vis_bans_damage = bor(F_FLYING)
tt.timed_attacks.list[3].sound = "HeroMechaPowerSlamCast"
tt.timed_attacks.list[3].min_cooldown = 5
tt.timed_attacks.list[4] = CC("custom_attack")
tt.timed_attacks.list[4].animation = "skill_4"
tt.timed_attacks.list[4].bullet = "bullet_hero_mecha_mine"
tt.timed_attacks.list[4].bullet_start_offset = {v(0, 60)}
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].cast_time = fts(23.25)
tt.timed_attacks.list[4].min_range = 35
tt.timed_attacks.list[4].max_range = 80
tt.timed_attacks.list[4].min_dist_between_mines = 30
tt.timed_attacks.list[4].spawn_offset = v(51, 0)
tt.timed_attacks.list[4].sound_cast = "HeroMechaMineDropCast"
tt.timed_attacks.list[4].min_cooldown = 5
tt.timed_attacks.list[4].min_distance_from_border = 100
tt = RT("drone_hero_mecha", "decal_scripted")

AC(tt, "force_motion", "ranged", "tween")

tt.main_script.update = drone_hero_mecha_update
tt.flight_height = 60
tt.force_motion.max_a = 1200
tt.force_motion.max_v = 360
tt.force_motion.ramp_radius = 30
tt.force_motion.fr = 0.05
tt.force_motion.a_step = 20
tt.duration = {8, 10, 12}
tt.render.sprites[1].prefix = "hero_onagro_skill_1_drone"
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[1].scale = v(0.75, 0.75)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "hero_onagro_ultimate_layer1_idle"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].scale = vv(0.2)
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].max_range = 100
tt.ranged.attacks[1].min_range = 10
tt.ranged.attacks[1].damage_type = DAMAGE_SHOT
tt.ranged.attacks[1].damage_min_config = {4, 7, 10}
tt.ranged.attacks[1].damage_max_config = {5, 10, 15}
tt.ranged.attacks[1].hit_time = fts(2)
tt.ranged.attacks[1].hit_cycles = 3
tt.ranged.attacks[1].hit_delay = fts(2)
tt.ranged.attacks[1].hit_fx = "fx_bullet_drone_hero_mecha"
tt.ranged.attacks[1].search_cooldown = 0.1
tt.ranged.attacks[1].shoot_time = fts(8)
tt.ranged.attacks[1].shoot_range = 25
tt.ranged.attacks[1].sound = "HeroMechaGoblidroneAttack"
tt.ranged.attacks[1].sound_args = {
	delay = fts(14)
}
tt.ranged.attacks[1].sound_chance = 0.5
tt.ranged.attacks[1].basic_attack = true
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].loop = true
tt.tween.props[1].keys = {{0, v(0, tt.flight_height + 2)}, {0.4, v(0, tt.flight_height - 2)}, {0.8, v(0, tt.flight_height + 2)}}
tt.tween.props[1].interp = "sine"
tt = RT("zeppelin_hero_mecha", "decal_scripted")

AC(tt, "force_motion", "ranged", "tween")

tt.decal = "decal_hero_mecha_ultimate"
tt.main_script.update = zeppelin_hero_mecha_update
tt.force_motion.max_a = 900
tt.force_motion.max_v = 200
tt.force_motion.ramp_radius = 30
tt.force_motion.fr = 0.05
tt.force_motion.a_step = 20
tt.flight_height = 60
tt.flight_height_attack = 30

for i = 1, 5 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].prefix = "hero_onagro_ultimate_layer" .. i
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].group = "layers"
	tt.render.sprites[i].offset = v(0, tt.flight_height)
	tt.render.sprites[i].z = Z_FLYING_HEROES
end

tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].offset = v(0, 0)
tt.render.sprites[1].scale = v(0.5, 0.5)
tt.render.sprites[4].z = Z_BULLETS + 1
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].bullet = "bullet_zeppelin_hero_mecha"
tt.ranged.attacks[1].bullet_start_offset = {v(0, 120)}
tt.ranged.attacks[1].cooldown = 0.5
tt.ranged.attacks[1].max_range = 200
tt.ranged.attacks[1].min_range = 10
tt.ranged.attacks[1].damage_type = DAMAGE_TRUE
tt.ranged.attacks[1].damage_min_config = {40, 48, 56, 64}
tt.ranged.attacks[1].damage_max_config = {60, 72, 84, 96}
tt.ranged.attacks[1].shoot_time = fts(4)
tt.ranged.attacks[1].sound_args = {
	delay = fts(14)
}
tt.ranged.attacks[1].sound_chance = 0.5
tt.ranged.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.ranged.attacks[1].basic_attack = true
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, v(0, tt.flight_height)}, {2, v(0, tt.flight_height_attack)}}
tt.tween.props[1].interp = "linear"
tt.tween.props[1].sprite_id = 2
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 3
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 4
tt.tween.props[4] = table.deepclone(tt.tween.props[1])
tt.tween.props[4].sprite_id = 5
tt.tween.props[5] = table.deepclone(tt.tween.props[1])
tt.tween.props[5].name = "scale"
tt.tween.props[5].keys = {{0, v(0.5, 0.5)}, {2, v(1, 1)}}
tt.tween.props[5].sprite_id = 1
tt.speed_out_of_range = 200
tt.speed_in_range = 30
tt.attack_radius = 125
tt = RT("bullet_hero_mecha", "bullet")

AC(tt, "force_motion")

tt.bullet.flight_time = fts(31)
tt.bullet.spawn_fx_1 = "fx_bullet_hero_mecha_spawn_1"
tt.bullet.spawn_fx_2 = "fx_bullet_hero_mecha_spawn_2"
tt.bullet.hit_fx = "fx_bullet_hero_mecha_hit"
tt.bullet.particles_name = "ps_bullet_hero_mecha_trail"
tt.bullet.align_with_trajectory = true
tt.bullet.damage_type = DAMAGE_EXPLOSION
tt.bullet.xp_gain_factor = 2.15
tt.bullet.damage_radius = 50
tt.bullet.damage_flags = F_AREA
tt.sound_events.hit = "HeroMechaBasicAttackHit"
tt.render.sprites[1].name = "hero_onagro_attack_projectile_idle"
tt.render.sprites[1].anchor = v(0.35, 0.5)
tt.main_script.insert = bullet_hero_mecha_insert
tt.main_script.update = bullet_hero_mecha_update
tt.initial_impulse = 3000
tt.initial_impulse_duration = 0.3
tt.initial_impulse_angle = 0
tt.force_motion.a_step = 5
tt.force_motion.max_a = 1800
tt.force_motion.max_v = 450
tt.max_rotation_speed = 12
tt.min_speed = 2
tt = RT("bullet_hero_mecha_tar_bomb", "bomb")
tt.bullet.damage_decay_random = false
tt.bullet.flight_time = fts(25)
tt.bullet.hit_fx = "fx_bullet_hero_mecha_tar_bomb"
tt.bullet.align_with_trajectory = false
tt.bullet.ignore_hit_offset = true
tt.bullet.pop_chance = 0.5
tt.bullet.rotation_speed = nil
tt.bullet.hit_payload = "aura_bullet_hero_mecha_tar_bomb"
tt.sound_events.hit = "HeroMechaTarBombExplosion"
tt.render.sprites[1].animated = true
tt.render.sprites[1].name = "hero_onagro_skill_2_projectile"
tt = RT("aura_bullet_hero_mecha_tar_bomb", "aura")

AC(tt, "render", "tween")

tt.aura.mod = "mod_bullet_hero_mecha_tar_bomb_slow"
tt.aura.radius = 60
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.cycle_time = fts(5)
tt.render.sprites[1].name = "hero_onagro_skill_2_decal"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = false
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {tt.aura.duration - 0.5, 255}, {tt.aura.duration, 0}}
tt = RT("mod_bullet_hero_mecha_tar_bomb_slow", "mod_slow")
tt.slow.factor = 0.5
tt = RT("bullet_hero_mecha_mine", "bomb")
tt.bullet.damage_decay_random = false
tt.bullet.flight_time = fts(25)
tt.bullet.align_with_trajectory = false
tt.bullet.ignore_hit_offset = true
tt.bullet.rotation_speed = 7.75
tt.bullet.hit_payload = "aura_bullet_hero_mecha_mine"
tt.bullet.hit_decal = nil
tt.bullet.hit_fx = nil
tt.bullet.pop_chance = 0
tt.main_script.insert = bullet_hero_mecha_mine_insert
tt.main_script.update = bullet_hero_mecha_mine_update
tt.sound_events.insert = nil
tt.sound_events.hit = nil
tt.render.sprites[1].name = "hero_onagro_skill_4_mine_projectile"
tt = RT("aura_bullet_hero_mecha_mine", "aura")

AC(tt, "render")

tt.aura.radius = 75
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans_trigger = bor(F_FLYING)
tt.aura.vis_bans_damage = 0
tt.aura.cycle_time = fts(5)
tt.render.sprites[1].prefix = "hero_onagro_skill_4_mine"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = false
tt.main_script.insert = aura_bullet_hero_mecha_mine_insert
tt.main_script.update = aura_bullet_hero_mecha_mine_update
tt.explosion_fx = "fx_hero_mecha_mine_explosion"
tt.sound_explode = "HeroMechaMineDropExplosion"
tt.damage_type = DAMAGE_EXPLOSION
tt = RT("mod_hero_mecha_power_slam_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_BOSS, F_FLYING)
tt = RT("bullet_zeppelin_hero_mecha", "bomb")
tt.bullet.flight_time = fts(40)
tt.bullet.hit_fx = "fx_bullet_zeppelin_hero_mecha"
tt.bullet.align_with_trajectory = false
tt.bullet.ignore_hit_offset = true
tt.bullet.pop_chance = 0.5
tt.bullet.rotation_speed = 10
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_radius = 50
tt.sound_events.insert = "HeroMechaDeathFromAboveAttack"
tt.sound_events.hit = "HeroMechaDeathFromAboveExplosion"
tt.render.sprites[1].name = "hero_onagro_ultimate_projectile"
tt = RT("controller_hero_mecha_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.entity = "zeppelin_hero_mecha"
tt.main_script.update = hero_mecha_ultimate_update
tt.sound = "HeroMechaDeathFromAboveCast"
