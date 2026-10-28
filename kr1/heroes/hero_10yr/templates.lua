local bit = require("bit")
local E = require("entity_db")
local GR = require("grid_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local km = require("lib.klua.macros")
local log = require("lib.klua.log"):new("hero_10yr")

require("lib.klua.table")
require("all.constants")

local band = bit.band
local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage
local v = V.v
local vv = V.vv

local anchor_y = 0.20161290322580644
local anchor_x = 0.5
local image_y = 116

local function ady(v)
	return v - anchor_y * image_y
end

local function aura_10yr_particles_update(this, store)
	local source = store.entities[this.aura.source_id]

	if not source then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = source.pos

	local particles = {}
	local s = source.render.sprites[1]
	local h = source.health
	local flip = s.flip_x

	for i, o in ipairs(this.particle_offsets) do
		local ps = E:create_entity(this.particles_name)

		ps.particle_system.track_id = source.id
		ps.particle_system.track_offset = o
		ps.particle_system.ts_offset = fts(2 * i)

		simulation:queue_insert_entity(ps)
		table.insert(particles, ps)
	end

	for i, p in pairs(particles) do
		p.particle_system.emit = false
	end

	::label_212_0::

	while h.dead or not source.is_buffed or not table.contains(this.emit_states, s.name) do
		coroutine.yield()
	end

	for i, p in pairs(particles) do
		p.particle_system.emit = true
	end

	while table.contains(this.emit_states, s.name) and not h.dead and source.is_buffed do
		if s.flip_x ~= flip then
			flip = s.flip_x

			for i, p in pairs(particles) do
				p.particle_system.emit_offset = s.flip_x and this.flip_offset or nil
			end
		end

		coroutine.yield()
	end

	for _, p in pairs(particles) do
		p.particle_system.emit = false
	end

	goto label_212_0
end

local function aura_10yr_fireball_update(this, store)
	local start_y = store.visible_coords and store.visible_coords.top or REF_H
	local bdt
	local a = this.aura
	local owner = store.entities[a.source_id]

	if not owner then
		log.error("owner %s was not found. bailing out", a.source_od)
	else
		do
			local bdy = math.abs(owner.pos.y - start_y)
			local tpl = E:get_template(a.entity)

			bdt = bdy / tpl.bullet.max_speed
		end

		for i = 1, a.loops do
			-- local target = U.detect_foremost_enemy_in_range_filter_off(owner.pos, a.max_range, a.vis_flags, a.vis_bans)
			local target, _, pred_pos = U.find_foremost_enemy_with_max_coverage_in_range_filter_off(owner.pos, a.max_range, bdt, a.vis_flags, a.vis_bans, E:get_template(a.entity).bullet.damage_radius)
			local b = E:create_entity(a.entity)

			if target then
				-- local pred_pos = U.calculate_enemy_ffe_pos(target, bdt)
				local dh = start_y - pred_pos.y
				local dx = dh * 0.4

				b.pos.x, b.pos.y = pred_pos.x + dx, start_y
				b.bullet.to = v(pred_pos.x, pred_pos.y)
			else
				local tx = owner.pos.x + math.random(-20, 20)
				local ty = owner.pos.y + math.random(-20, 20)
				local dh = start_y - ty
				local dx = dh * 0.4

				b.pos.x, b.pos.y = tx + dx, start_y
				b.bullet.to = v(tx, ty)
			end

			b.bullet.from:copy(b.pos)

			simulation:queue_insert_entity(b)
			U.y_wait_unconditional(store, a.delay)
		end
	end

	simulation:queue_remove_entity(this)
end

local function aura_10yr_bomb_update(this, store)
	local a = this.aura

	local function do_attack(pos, last_attack)
		local fx = E:create_entity(a.fx)

		fx.pos.x, fx.pos.y = pos.x, pos.y

		if not last_attack then
			fx.render.sprites[2].scale = v(0.8, 0.8)
		end

		fx.render.sprites[2].ts = store.tick_ts
		fx.tween.ts = store.tick_ts

		simulation:queue_insert_entity(fx)

		local radius = last_attack and a.last_attack_damage_radius or a.damage_radius
		local targets = U.find_enemies_in_range_filter_off(pos, radius, a.vis_flags, a.vis_bans)

		if targets then
			for _, t in ipairs(targets) do
				local d = E.assign_damage(a.damage_type, math.random(a.damage_min, a.damage_max), this.id, t.id)

				queue_damage(store, d)

				if (last_attack or math.random() < a.stun_chance) and U.flags_pass(t.vis, this.stun) then
					local m = E:create_entity(this.stun.mod)

					m.modifier.source_id = this.id
					m.modifier.target_id = t.id

					simulation:queue_insert_entity(m)
				end
			end

			log.paranoid(">>>> aura_10yr_bomb POS:%s,%s  damaged:%s", pos.x, pos.y, table.concat(table.map(targets, function(k, v)
				return v.id
			end), ","))
		end
	end

	local pi, spi, ni, tni, target, origin
	local target_info = U.find_enemies_in_paths(store.enemies, this.pos, a.min_nodes, a.max_nodes, nil, a.vis_flags, a.vis_bans)

	if not target_info or #target_info < a.min_count then
	-- log.error("aura_10yr_bomb could not find valid enemies in the hero paths")
	else
		target = target_info[1].enemy
		origin = target_info[1].origin
		pi, spi, ni = unpack(origin)
		tni = target.nav_path.ni

		for i = 1, a.steps do
			local nni = ni + i * a.step_nodes * km.sign(tni - ni)
			local oni = ni + i * a.step_nodes * km.sign(tni - ni) * -1

			spi = i == a.steps and 1 or (spi == 2 or spi == 3) and 1 or math.random() < 0.5 and 2 or 3

			U.y_wait_unconditional(store, a.step_delay)

			local spos = P:node_pos(pi, spi, nni)

			do_attack(spos, i == a.steps)

			if i == 1 then
				local opos = P:node_pos(pi, spi, oni)

				do_attack(opos, false)
			end
		end
	end

	simulation:queue_remove_entity(this)
end

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "rain", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil

		local au = E:get_template(a.entity)

		au.aura.loops = s.loops[s.level]

		local bt = E:get_template(au.aura.entity)

		bt.bullet.damage_min = s.damage_min[s.level]
		bt.bullet.damage_max = s.damage_max[s.level]

		if s.level >= 2 then
			bt.scorch_earth = true
		end

		a = this.timed_attacks.list[4]
		a.disabled = nil
		au = E:get_template(a.entity)
		bt = E:get_template(au.aura.entity)
		bt.bullet.damage_min = s.damage_min[s.level] * s.loops[s.level]
		bt.bullet.damage_max = s.damage_max[s.level] * s.loops[s.level]

		if s.level >= 2 then
			bt.scorch_earth = true
		end
	end)
	upgrade_skill(this, "buffed", function(this, s)
		local a = this.timed_attacks.list[2]

		a.duration = s.duration[s.level]
		a.disabled = nil

		local a = this.timed_attacks.list[3]

		a.damage_min = s.bomb_damage_min[s.level]
		a.damage_max = s.bomb_damage_max[s.level]

		if s.level == 3 then
			a.sound = a.sound_long
		end

		local au = E:get_template(a.hit_aura)

		au.aura.steps = s.bomb_steps[s.level]
		au.aura.damage_min = s.bomb_step_damage_min[s.level]
		au.aura.damage_max = s.bomb_step_damage_max[s.level]

		local a = this.melee.attacks[3]

		a.damage_min = s.spin_damage_min[s.level]
		a.damage_max = s.spin_damage_max[s.level]
	end)

	update_hp(this)
end

local function hero_update(this, store)
	local h = this.health
	local ra = this.timed_attacks.list[1]
	local ba = this.timed_attacks.list[2]
	local bma = this.timed_attacks.list[3]
	local giant_ra = this.timed_attacks.list[4]
	local a, skill, brk, sta

	local function go_buffed()
		this.sound_events.change_rally_point = this.sound_events.change_rally_point_buffed

		for i = 1, 2 do
			this.melee.attacks[i].disabled = true
		end

		this.melee.attacks[3].disabled = false
		this.health.immune_to = ba.immune_to

		for _, v in pairs(ba.sounds_buffed) do
			S:queue(v)
		end

		U.y_animation_play(this, "normal_to_buffed", nil, store.tick_ts, 1)

		this.render.sprites[1].prefix = "hero_10yr_buffed"
		ba.ts = store.tick_ts
		this.teleport.disabled = true
		this.is_buffed = true
		-- this.health_bar.offset = this.health_bar.offset_buffed
		U.change_health_bar_offset_run_time(this.health_bar, this.health_bar.offset_buffed.y)

		U.update_max_speed(this, this.motion.max_speed_buffed)

		this.melee.range = this.melee.range_buffed
	end

	local function go_normal()
		this.sound_events.change_rally_point = this.sound_events.change_rally_point_normal

		for i = 1, 2 do
			this.melee.attacks[i].disabled = false
		end

		this.melee.attacks[3].disabled = true
		this.is_buffed = false

		for _, v in pairs(ba.sounds_normal) do
			S:queue(v)
		end

		U.y_animation_play(this, "to_normal", nil, store.tick_ts, 1)

		this.health.immune_to = DAMAGE_NONE
		this.render.sprites[1].prefix = "hero_10yr"
		this.teleport.disabled = nil
		-- this.health_bar.offset = this.health_bar.offset_normal
		U.change_health_bar_offset_run_time(this.health_bar, this.health_bar.offset_normal.y)

		U.update_max_speed(this, this.motion.max_speed_normal)

		this.melee.range = this.melee.range_normal
		ba.ts = store.tick_ts
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false
	local aura = E:create_entity(this.particles_aura)

	aura.aura.source_id = this.id

	simulation:queue_insert_entity(aura)

	while true do
		if h.dead then
			if this.is_buffed then
				go_normal()
			end

			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if this.is_buffed and V.dist2(this.pos.x, this.pos.y, this.nav_rally.pos.x, this.nav_rally.pos.y) > 40000 then
					local compensation = (ba.duration - (store.tick_ts - ba.ts)) / ba.duration * ba.cooldown

					go_normal()

					ba.ts = ba.ts - compensation
				end

				if SU.y_hero_new_rally(store, this) then
					goto label_90_1
				end
			end

			if SU.hero_level_up(store, this) and not this.is_buffed then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = ra
			skill = this.hero.skills.rain

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local start_ts, au
				local fired_aura = false
				local targets = U.find_enemies_between_range_filter_off(this.pos, a.min_range, a.trigger_range, a.vis_flags, a.vis_bans)

				if not targets then
					a.ts = a.ts + 0.2
				else
					if this.is_buffed then
						local compensation = (ba.duration - (store.tick_ts - ba.ts)) / ba.duration * ba.cooldown

						go_normal()

						ba.ts = ba.ts - compensation
					end

					S:queue(a.sound_start)
					U.animation_start_default(this, a.animations[1], nil, store.tick_ts, false)

					while not U.animation_finished_default(this) do
						if SU.hero_interrupted(this) then
							goto label_90_0
						end

						coroutine.yield()
					end

					start_ts = store.tick_ts

					U.animation_start_default(this, a.animations[2], nil, store.tick_ts, false)

					while not U.animation_finished_default(this) do
						if SU.hero_interrupted(this) then
							goto label_90_0
						end

						coroutine.yield()
					end

					au = E:create_entity(a.entity)
					au.aura.source_id = this.id

					simulation:queue_insert_entity(au)

					fired_aura = true

					::label_90_0::

					if fired_aura then
						a.ts = start_ts

						SU.hero_gain_xp_from_skill(this, skill)
					end

					S:queue(a.sound_end)
					U.y_animation_play(this, a.animations[3], nil, store.tick_ts, 1)
				end
			end

			a = giant_ra
			skill = this.hero.skills.rain

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local start_ts, au
				local fired_aura = false
				local targets = U.find_enemies_between_range_filter_off(this.pos, a.min_range, a.trigger_range, a.vis_flags, a.vis_bans)

				if not targets then
					a.ts = a.ts + 0.2
				else
					if this.is_buffed then
						local compensation = (ba.duration - (store.tick_ts - ba.ts)) / ba.duration * ba.cooldown

						go_normal()

						ba.ts = ba.ts - compensation
					end

					S:queue(a.sound_start)
					U.animation_start_default(this, a.animations[1], nil, store.tick_ts, false)

					while not U.animation_finished_default(this) do
						if SU.hero_interrupted(this) then
							goto label_90_0
						end

						coroutine.yield()
					end

					start_ts = store.tick_ts

					U.animation_start_default(this, a.animations[2], nil, store.tick_ts, false)

					while not U.animation_finished_default(this) do
						if SU.hero_interrupted(this) then
							goto label_90_0
						end

						coroutine.yield()
					end

					au = E:create_entity(a.entity)
					au.aura.source_id = this.id

					simulation:queue_insert_entity(au)

					fired_aura = true

					::label_90_0::

					if fired_aura then
						a.ts = start_ts

						SU.hero_gain_xp_from_skill(this, skill)
					end

					S:queue(a.sound_end)
					U.y_animation_play(this, a.animations[3], nil, store.tick_ts, 1)
				end
			end

			a = ba
			skill = this.hero.skills.buffed

			if not this.is_buffed and not a.disabled and store.tick_ts - a.ts >= a.cooldown then
				local targets = U.find_enemies_in_range_filter_off(this.pos, a.range, a.vis_flags, a.vis_bans)

				if targets and #targets >= a.min_count then
					SU.hero_gain_xp_from_skill(this, skill)
					go_buffed()
				end
			elseif this.is_buffed and store.tick_ts - a.ts >= a.duration then
				go_normal()
			end

			a = bma

			if this.is_buffed and store.tick_ts - a.ts >= a.cooldown then
				local target_info = U.find_enemies_in_paths(store.enemies, this.pos, a.min_nodes, a.max_nodes, nil, a.vis_flags, a.vis_bans)

				if not target_info or #target_info < a.min_count then
					a.ts = a.ts + 0.2
				else
					local target = target_info[1].enemy

					if not SU.y_soldier_do_single_area_attack(store, this, target, a) then
						goto label_90_1
					end
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			elseif SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_90_1::

		coroutine.yield()
	end
end

local function hero_get_info(this)
	local a = this.is_buffed and this.melee.attacks[3] or this.melee.attacks[1]
	local min, max = a.damage_min + this.unit.damage_buff, a.damage_max + this.unit.damage_buff

	min, max = min * this.unit.damage_factor, max * this.unit.damage_factor

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		damage_type = a.damage_type,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		respawn = this.health.dead_lifetime
	}
end

local function power_fireball_10yr_update(this, store)
	local b = this.bullet
	local mspeed = 10 * FPS
	local particle = E:create_entity("ps_power_fireball")

	particle.particle_system.track_id = this.id

	simulation:queue_insert_entity(particle)

	local shadow = E:create_entity("decal_fireball_shadow")

	shadow.pos.x, shadow.pos.y = b.to.x, b.to.y
	shadow.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(shadow)

	local shadow_tracks = b.from.x ~= b.to.x

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		if shadow_tracks then
			shadow.pos.x = this.pos.x
		end

		coroutine.yield()
	end

	this.pos.x, this.pos.y = b.to.x, b.to.y
	particle.particle_system.source_lifetime = 0

	local enemies = table.filter(store.enemies, function(k, v)
		return not v.health.dead and band(v.vis.flags, b.damage_bans) == 0 and band(v.vis.bans, b.damage_flags) == 0 and U.is_inside_ellipse(v.pos, b.to, b.damage_radius)
	end)
	local damage_value = math.ceil(b.damage_factor * math.random(b.damage_min, b.damage_max))

	for _, enemy in ipairs(enemies) do
		local d = E.assign_damage(b.damage_type, damage_value, this.id, enemy.id)

		queue_damage(store, d)
	end

	S:queue(this.sound_events.hit)

	local cell_type = GR:cell_type(b.to.x, b.to.y)

	if band(cell_type, TERRAIN_WATER) ~= 0 then
		local fx = E:create_entity("fx_explosion_water")

		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(fx)

		if this.scorch_earth then
			local scorched = E:create_entity("power_scorched_water")

			scorched.pos.x, scorched.pos.y = b.to.x, b.to.y

			for i = 1, #scorched.render.sprites do
				scorched.render.sprites[i].ts = store.tick_ts
			end

			simulation:queue_insert_entity(scorched)
		end
	else
		if b.hit_decal then
			local decal = E:create_entity(b.hit_decal)

			decal.pos:copy(b.to)
			decal.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(decal)
		end

		if b.hit_fx then
			local fx = E:create_entity(b.hit_fx)

			fx.pos.x, fx.pos.y = b.to.x, b.to.y
			fx.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(fx)
		end

		if this.scorch_earth then
			local scorched = E:create_entity("power_scorched_earth")

			scorched.pos.x, scorched.pos.y = b.to.x, b.to.y

			for i = 1, #scorched.render.sprites do
				scorched.render.sprites[i].ts = store.tick_ts
			end

			simulation:queue_insert_entity(scorched)
		end
	end

	simulation:queue_remove_entity(shadow)
	simulation:queue_remove_entity(this)
end

local function power_giant_fireball_10yr_update(this, store)
	local b = this.bullet
	local mspeed = 5 * FPS
	local particle = E:create_entity("ps_power_fireball")

	particle.particle_system.track_id = this.id
	particle.particle_system.scale_var[1] = particle.particle_system.scale_var[1] * 2
	particle.particle_system.scale_var[2] = particle.particle_system.scale_var[2] * 2

	simulation:queue_insert_entity(particle)

	local shadow = E:create_entity("decal_fireball_shadow")

	shadow.pos.x, shadow.pos.y = b.to.x, b.to.y
	shadow.render.sprites[1].ts = store.tick_ts
	shadow.render.sprites[1].scale = V.vv(2)

	simulation:queue_insert_entity(shadow)

	local shadow_tracks = b.from.x ~= b.to.x

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		if shadow_tracks then
			shadow.pos.x = this.pos.x
		end

		coroutine.yield()
	end

	this.pos.x, this.pos.y = b.to.x, b.to.y
	particle.particle_system.source_lifetime = 0

	local enemies = table.filter(store.enemies, function(k, v)
		return not v.health.dead and band(v.vis.flags, b.damage_bans) == 0 and band(v.vis.bans, b.damage_flags) == 0 and U.is_inside_ellipse(v.pos, b.to, b.damage_radius)
	end)
	local damage_value = math.ceil(b.damage_factor * math.random(b.damage_min, b.damage_max))

	for _, enemy in ipairs(enemies) do
		local d = E.assign_damage(b.damage_type, damage_value, this.id, enemy.id)

		queue_damage(store, d)
	end

	S:queue(this.sound_events.hit)

	local cell_type = GR:cell_type(b.to.x, b.to.y)

	if band(cell_type, TERRAIN_WATER) ~= 0 then
		local fx = E:create_entity("fx_explosion_water")

		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].scale = V.vv(2)
		simulation:queue_insert_entity(fx)

		if this.scorch_earth then
			local scorched = E:create_entity("power_scorched_water")

			scorched.pos.x, scorched.pos.y = b.to.x, b.to.y
			scorched.render.sprites[1].scale = V.vv(2)
			scorched.aura.radius = scorched.aura.radius * 2

			for i = 1, #scorched.render.sprites do
				scorched.render.sprites[i].ts = store.tick_ts
			end

			simulation:queue_insert_entity(scorched)
		end
	else
		if b.hit_decal then
			local decal = E:create_entity(b.hit_decal)

			decal.pos:copy(b.to)
			decal.render.sprites[1].ts = store.tick_ts
			decal.render.sprites[1].scale = V.vv(2)

			simulation:queue_insert_entity(decal)
		end

		if b.hit_fx then
			local fx = E:create_entity(b.hit_fx)

			fx.pos.x, fx.pos.y = b.to.x, b.to.y
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].scale = V.vv(2)

			simulation:queue_insert_entity(fx)
		end

		if this.scorch_earth then
			local scorched = E:create_entity("power_scorched_earth")

			scorched.pos.x, scorched.pos.y = b.to.x, b.to.y

			for i = 1, #scorched.render.sprites do
				scorched.render.sprites[i].ts = store.tick_ts
			end

			scorched.render.sprites[1].scale = V.vv(2)
			scorched.aura.radius = scorched.aura.radius * 2

			simulation:queue_insert_entity(scorched)
		end
	end

	simulation:queue_remove_entity(shadow)
	simulation:queue_remove_entity(this)
end

-- 红龙

local tt

tt = RT("ps_hero_10yr_idle", "particle_system")
tt.particle_system.name = "ps_hero_10yr_particle_fire"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {0.5, 0.5}
tt.particle_system.alphas = {255, 255}
tt.particle_system.emit_direction = d2r(90)
tt.particle_system.emit_speed = {30, 30}
tt.particle_system.emission_rate = 2.5
tt.particle_system.z = Z_OBJECTS

tt = RT("aura_10yr_idle", "aura")
tt.particles_name = "ps_hero_10yr_idle"
tt.emit_states = {"idle", "running"}
tt.main_script.update = aura_10yr_particles_update
tt.particle_offsets = {vec_2(-25.714285714285715, 25.714285714285715), vec_2(-15.714285714285715, 37.142857142857146), vec_2(0, 45.714285714285715), vec_2(8.571428571428571, 42.85714285714286), vec_2(14.285714285714286, 32.85714285714286), vec_2(21.42857142857143, 21.42857142857143)}
tt.flip_offset = vec_2(3, 0)

tt = RT("hero_10yr", "hero")
AC(tt, "melee", "timed_attacks", "teleport")
tt.hero.level_stats.armor = {0.23, 0.26, 0.29, 0.32, 0.35, 0.38, 0.41, 0.44, 0.47, 0.5}
tt.hero.level_stats.hp_max = {380, 400, 420, 440, 460, 480, 500, 520, 540, 560}
tt.hero.level_stats.melee_damage_max = {22, 25, 28, 31, 34, 37, 40, 43, 46, 49}
tt.hero.level_stats.melee_damage_min = {14, 16, 18, 20, 22, 24, 26, 28, 30, 32}
tt.hero.skills.rain = CC("hero_skill")
tt.hero.skills.rain.loops = {3, 4, 5}
tt.hero.skills.rain.damage_min = {30, 35, 40}
tt.hero.skills.rain.damage_max = {60, 65, 70}
tt.hero.skills.rain.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.rain.xp_gain = {100, 200, 300}
tt.hero.skills.buffed = CC("hero_skill")
tt.hero.skills.buffed.bomb_steps = {3, 4, 6}
tt.hero.skills.buffed.bomb_step_damage_min = {10, 15, 20}
tt.hero.skills.buffed.bomb_step_damage_max = {20, 30, 40}
tt.hero.skills.buffed.bomb_damage_min = {50, 60, 70}
tt.hero.skills.buffed.bomb_damage_max = {70, 80, 90}
tt.hero.skills.buffed.spin_damage_min = {18, 23, 27}
tt.hero.skills.buffed.spin_damage_max = {36, 45, 54}
tt.hero.skills.buffed.duration = {6, 9, 12}
tt.hero.skills.buffed.xp_level_steps = {
	[10] = 3,
	[4] = 1,
	[7] = 2
}
tt.hero.skills.buffed.xp_gain = {100, 150, 200}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, ady(60))
tt.health_bar.offset_buffed = vec_2(0, ady(74))
tt.health_bar.offset_normal = tt.health_bar.offset
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.hero_portrait = "hero_portraits_0013"
tt.info.fn = hero_get_info
tt.info.portrait = "info_portraits_heroes_0013"
tt.main_script.update = hero_update
tt.motion.max_speed_normal = 1.6 * FPS
tt.motion.max_speed_buffed = 2.5 * FPS
tt.motion.max_speed = tt.motion.max_speed_normal
tt.particles_aura = "aura_10yr_idle"
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "hero_10yr"
tt.soldier.melee_slot_offset = vec_2(15, -1)
tt.sound_events.change_rally_point = "TenShiTaunt"
tt.sound_events.change_rally_point_normal = "TenShiTaunt"
tt.sound_events.change_rally_point_buffed = "TenShiTauntBuffed"
tt.sound_events.death = "TenShiDeathSfx"
tt.sound_events.death_args = {
	delay = fts(5)
}
tt.sound_events.hero_room_select = "TenShiTauntSelect"
tt.sound_events.insert = "TenShiTauntIntro"
tt.sound_events.respawn = "TenShiRespawn"
tt.teleport.min_distance = 55
tt.teleport.sound = "TenShiTeleportSfx"
tt.unit.mod_offset = vec_2(0, 20)
tt.unit.hit_offset = vec_2(0, 20)
tt.melee.range_normal = 55
tt.melee.range_buffed = 85
tt.melee.range = tt.melee.range_normal
tt.melee.attacks[1].cooldown = 1.35
tt.melee.attacks[1].hit_time = fts(19)
tt.melee.attacks[1].sound = "TenShiAttack1"
tt.melee.attacks[1].hit_offset = vec_2(20, 0)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].xp_gain_factor = 2.5
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[2].hit_time = fts(28)
tt.melee.attacks[2].hit_offset = vec_2(20, 2)
tt.melee.attacks[2].sound = "TenShiAttack2"
tt.melee.attacks[3] = CC("area_attack")
tt.melee.attacks[3].animations = {"spin_start", "spin_loop", "spin_end"}
tt.melee.attacks[3].cooldown = 2
tt.melee.attacks[3].loops = 2
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].damage_min = nil
tt.melee.attacks[3].damage_max = nil
tt.melee.attacks[3].damage_radius = 50
tt.melee.attacks[3].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[3].hit_times = {fts(2), fts(6)}
tt.melee.attacks[3].sound = "TenShiBuffedSpinAttack"
tt.melee.attacks[3].vis_flags = F_BLOCK
tt.melee.attacks[3].xp_from_skill = "buffed"
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animations = {"power_rain_start", "power_rain_loop", "power_rain_end"}
tt.timed_attacks.list[1].cooldown = 23
tt.timed_attacks.list[1].entity = "aura_10yr_fireball"
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].sound_start = "TenShiRainOfFireStart"
tt.timed_attacks.list[1].sound_end = "TenShiRainOfFireEnd"
tt.timed_attacks.list[1].min_count = 1
tt.timed_attacks.list[1].trigger_range = 100
tt.timed_attacks.list[1].max_range = 150
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].vis_bans = bor(F_FRIEND)
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].cooldown = 10
tt.timed_attacks.list[2].min_count = 3
tt.timed_attacks.list[2].range = 100
tt.timed_attacks.list[2].disabled = true
-- tt.timed_attacks.list[2].transform_health_factor = 0.6
tt.timed_attacks.list[2].immune_to = DAMAGE_BASE_TYPES
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[2].sounds_buffed = {"TenShiTransformToBuffed", "TenShiTransformToBuffedSfx"}
tt.timed_attacks.list[2].sounds_normal = {"TenShiTransformToNormalSfx"}
tt.timed_attacks.list[3] = CC("area_attack")
tt.timed_attacks.list[3].cooldown = 9
tt.timed_attacks.list[3].animation = "bomb"
tt.timed_attacks.list[3].count = 10
tt.timed_attacks.list[3].damage_max = nil
tt.timed_attacks.list[3].damage_min = nil
tt.timed_attacks.list[3].damage_radius = 40
tt.timed_attacks.list[3].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[3].hit_decal = "decal_ground_hit"
tt.timed_attacks.list[3].hit_fx = "fx_ground_hit"
tt.timed_attacks.list[3].hit_offset = vec_2(0, 0)
tt.timed_attacks.list[3].hit_time = fts(28)
tt.timed_attacks.list[3].hit_aura = "aura_10yr_bomb"
tt.timed_attacks.list[3].min_count = 1
tt.timed_attacks.list[3].min_range = 80
tt.timed_attacks.list[3].max_range = 150
tt.timed_attacks.list[3].min_nodes = 5
tt.timed_attacks.list[3].max_nodes = 20
tt.timed_attacks.list[3].pop = {"pop_kapow", "pop_whaam"}
tt.timed_attacks.list[3].pop_chance = 0.3
tt.timed_attacks.list[3].pop_conds = DR_KILL
tt.timed_attacks.list[3].sound_short = "TenShiBuffedBombAttack"
tt.timed_attacks.list[3].sound_long = "TenShiBuffedBombAttackLong"
tt.timed_attacks.list[3].sound = tt.timed_attacks.list[3].sound_short
tt.timed_attacks.list[3].xp_from_skill = "buffed"
tt.timed_attacks.list[4] = table.deepclone(tt.timed_attacks.list[1])
tt.timed_attacks.list[4].cooldown = 46
tt.timed_attacks.list[4].entity = "aura_10yr_giant_fireball"

tt = RT("aura_10yr_fireball", "aura")
tt.main_script.update = aura_10yr_fireball_update
tt.aura.entity = "fireball_10yr"
tt.aura.delay = fts(15)
tt.aura.max_range = E:get_template("hero_10yr").timed_attacks.list[1].max_range
tt.aura.vis_flags = E:get_template("hero_10yr").timed_attacks.list[1].vis_flags
tt.aura.vis_bans = E:get_template("hero_10yr").timed_attacks.list[1].vis_bans

tt = RT("aura_10yr_giant_fireball", "aura_10yr_fireball")
tt.aura.entity = "giant_fireball_10yr"
tt.aura.loops = 1
tt.aura.delay = fts(20)

tt = RT("fireball_10yr", "bullet")
tt.bullet.min_speed = 24 * FPS
tt.bullet.max_speed = 24 * FPS
tt.bullet.acceleration_factor = 0.05
tt.bullet.hit_fx = "fx_fireball_explosion"
tt.bullet.hit_decal = "decal_bomb_crater"
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_radius = 60
tt.bullet.damage_min = 30
tt.bullet.damage_max = 60
tt.bullet.damage_flags = F_AREA
tt.render.sprites[1].name = "fireball_proyectile"
tt.main_script.update = power_fireball_10yr_update
tt.scorch_earth = false
tt.sound_events.insert = "FireballRelease"
tt.sound_events.hit = "FireballHit"

tt = RT("giant_fireball_10yr", "fireball_10yr")
tt.bullet.min_speed = 8 * FPS
tt.bullet.max_speed = 8 * FPS
tt.bullet.damage_radius = 120
tt.bullet.damage_min = 60
tt.bullet.damage_max = 120
tt.main_script.update = power_giant_fireball_10yr_update
tt.render.sprites[1].scale = vv(2)

tt = RT("aura_10yr_bomb", "aura")
tt.aura.fx = "decal_10yr_spike"
tt.aura.damage_radius = 40
tt.aura.last_attack_damage_radius = 60
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.vis_flags = bor(F_RANGED)
tt.aura.step_delay = fts(2)
tt.aura.step_nodes = 5
tt.aura.steps = 3
tt.main_script.update = aura_10yr_bomb_update
tt.stun = {
	vis_flags = bor(F_RANGED, F_STUN),
	vis_bans = bor(F_FLYING, F_BOSS),
	mod = "mod_10yr_stun"
}
tt.aura.damage_min = 10
tt.aura.damage_max = 20
tt.aura.stun_chance = 0.25
tt.aura.min_nodes = 0
tt.aura.max_nodes = 25
tt.aura.min_count = 1

tt = RT("mod_10yr_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_FLYING, F_BOSS)
tt.modifier.duration = 3

tt = RT("decal_10yr_spike", "decal_bomb_crater")
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_10yr_bomb_spike"
tt.render.sprites[2].hide_after_runs = 1
tt.render.sprites[2].anchor.y = 0.24

--         二代
--     --
