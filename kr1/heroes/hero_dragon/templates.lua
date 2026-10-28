local bit = require("bit")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local km = require("lib.klua.macros")
local scripts = require("scripts")
local log = require("lib.klua.log"):new("hero_dragon")

require("lib.klua.table")
require("all.constants")

local band = bit.band
local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local ready_to_attack = U.ready_to_attack
local update_hp = HU.update_hp
local queue_damage = U.queue_damage

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)
	local b = E:get_template("fireball_dragon")

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	upgrade_skill(this, "blazingbreath", function(this, s)
		this.ranged.attacks[2].disabled = nil

		local b = E:get_template("breath_dragon")

		b.bullet.damage_min = s.damage[s.level]
		b.bullet.damage_max = s.damage[s.level]
	end)
	upgrade_skill(this, "feast", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.damage = s.damage[s.level]
		a.devour_chance = s.devour_chance[s.level]
	end)
	upgrade_skill(this, "fierymist", function(this, s)
		local a = this.ranged.attacks[3]

		a.disabled = nil

		local aura = E:get_template("aura_fierymist_dragon")

		aura.aura.duration = s.duration[s.level]

		local m = E:get_template("mod_slow_fierymist")

		m.slow.factor = s.slow_factor[s.level]
	end)
	upgrade_skill(this, "wildfirebarrage", function(this, s)
		local a = this.ranged.attacks[4]

		a.disabled = nil

		local b = E:get_template("wildfirebarrage_dragon")

		b.explosions = s.explosions[s.level]
	end)
	upgrade_skill(this, "reignoffire", function(this, s)
		local m = E:get_template("mod_dragon_reign")

		m.dps.damage_min = s.dps[s.level] * m.dps.damage_every / m.modifier.duration
		m.dps.damage_max = s.dps[s.level] * m.dps.damage_every / m.modifier.duration

		local b = E:get_template("fireball_dragon")

		b.bullet.mod = "mod_dragon_reign"

		local b = E:get_template("breath_dragon")

		b.bullet.mod = "mod_dragon_reign"

		local b = E:get_template("wildfirebarrage_dragon")

		b.bullet.mod = "mod_dragon_reign"
	end)
	update_hp(this)
end

local function hero_update(this, store)
	local h = this.health
	local a, skill, force_idle_ts

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false
	force_idle_ts = true

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)

			force_idle_ts = true
		end

		while this.nav_rally.new do
			SU.y_hero_new_rally(store, this)
		end

		if SU.hero_level_up(store, this) then
			U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
		end

		a = this.timed_attacks.list[1]
		skill = this.hero.skills.feast

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			local target = U.find_nearest_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

			if not target then
				a.ts = a.ts + 0.1
			else
				SU.hero_gain_xp_from_skill(this, skill)

				a.ts = store.tick_ts

				SU.stun_inc(target)
				S:queue(a.sound)
				U.animation_start_default(this, "feast", target.pos.x < this.pos.x, store.tick_ts)

				local steps = math.floor(fts(9) / store.tick_length)
				local step_x, step_y = V.mul(1 / steps, target.pos.x - this.pos.x, target.pos.y - this.pos.y - 1)

				for i = 1, steps do
					this.pos.x, this.pos.y = this.pos.x + step_x, this.pos.y + step_y

					coroutine.yield()
				end

				local fx = E:create_entity("fx_dragon_feast")

				fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
				fx.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(fx)

				local d = E.assign_damage(a.damage_type, (a.damage + this.unit.damage_buff) * this.unit.damage_factor, this.id, target.id)
				local actual_damage = U.predict_damage(target, d)

				if math.random() < a.devour_chance or actual_damage >= target.health.hp then
					if band(target.vis.bans, bor(F_INSTAKILL, F_EAT)) ~= 0 then
						d.value = d.value * 2
					else
						if target.unit.can_explode then
							d.damage_type = DAMAGE_EAT

							local fxn, default_fx

							if target.unit.explode_fx and target.unit.explode_fx ~= "fx_unit_explode" then
								fxn = target.unit.explode_fx
								default_fx = false
							else
								fxn = "fx_dragon_feast_explode"
								default_fx = true
							end

							local fx = E:create_entity(fxn)
							local fxs = fx.render.sprites[1]

							fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
							fxs.ts = store.tick_ts

							if default_fx then
								fxs.scale = fxs.size_scales[target.unit.size]
							else
								fxs.name = fxs.size_names[target.unit.size]
							end

							simulation:queue_insert_entity(fx)
						else
							d.damage_type = DAMAGE_INSTAKILL
						end
					end
				end

				queue_damage(store, d)
				SU.stun_dec(target)
				U.y_animation_wait_default(this)

				force_idle_ts = true

				goto label_383_1
			end
		end

		for _, i in ipairs(this.ranged.order) do
			local a = this.ranged.attacks[i]

			if a.disabled then
			-- block empty
			elseif a.sync_animation and not this.render.sprites[1].sync_flag then
			-- block empty
			elseif ready_to_attack(a, store, this.unit.cooldown_factor) then
				local origin = V.v(this.pos.x, this.pos.y + a.bullet_start_offset[1].y)
				local bullet_t = E:get_template(a.bullet)
				local bullet_speed = bullet_t.bullet.min_speed
				local flight_time = bullet_t.bullet.flight_time
				local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if target then
					local start_ts = store.tick_ts
					local b, emit_fx, emit_ps, node_offset

					if flight_time then
						node_offset = P:predict_enemy_node_advance(target, flight_time + a.shoot_time)
					else
						local dist = V.dist(origin.x, origin.y, target.pos.x, target.pos.y)

						node_offset = P:predict_enemy_node_advance(target, dist / bullet_speed)
					end

					local t_pos

					if a.name == "fierymist" or a.name == "blazingbreath" then
						t_pos = P:node_pos(target.nav_path.pi, 1, target.nav_path.ni + node_offset)
					else
						t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
					end

					local an, af, ai = U.animation_name_facing_point(this, a.animation, t_pos)

					U.animation_start_default(this, an, af, store.tick_ts)

					while store.tick_ts - start_ts < a.shoot_time do
						if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
							goto label_383_0
						end

						coroutine.yield()
					end

					S:queue(a.sound)

					b = E:create_entity(a.bullet)
					b.bullet.target_id = target.id
					b.bullet.source_id = this.id
					b.bullet.damage_factor = this.unit.damage_factor
					b.bullet.damage_min = b.bullet.damage_min + this.unit.damage_buff
					b.bullet.damage_max = b.bullet.damage_max + this.unit.damage_buff

					b.pos:copy(this.pos)

					b.pos.x = b.pos.x + (af and -1 or 1) * a.bullet_start_offset[ai].x
					b.pos.y = b.pos.y + a.bullet_start_offset[ai].y

					b.bullet.from:copy(b.pos)

					b.bullet.to = V.v(t_pos.x, t_pos.y)

					simulation:queue_insert_entity(b)

					if a.xp_from_skill then
						SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
					end

					a.ts = start_ts

					if a.emit_ps and b.bullet.flight_time then
						local dest = V.vclone(b.bullet.to)

						if a.name == "fierymist" or a.name == "blazingbreath" then
							dest.y = dest.y + 15
						end

						local ps = E:create_entity(a.emit_ps)
						local mspeed = V.dist(dest.x, dest.y, b.bullet.from.x, b.bullet.from.y) / b.bullet.flight_time

						ps.particle_system.emit_direction = V.angleTo(dest.x - b.bullet.from.x, dest.y - b.bullet.from.y)
						ps.particle_system.emit_speed = {mspeed, mspeed}
						ps.particle_system.flip_x = af
						ps.pos.x, ps.pos.y = b.bullet.from.x, b.bullet.from.y

						simulation:queue_insert_entity(ps)

						emit_ps = ps
					end

					if a.emit_fx then
						local fx = E:create_entity(a.emit_fx)

						fx.pos.x, fx.pos.y = b.bullet.from.x, b.bullet.from.y
						fx.render.sprites[1].ts = store.tick_ts
						fx.render.sprites[1].flip_x = af

						if af and fx.render.sprites[1].offset.x then
							fx.render.sprites[1].offset.x = -1 * fx.render.sprites[1].offset.x
						end

						simulation:queue_insert_entity(fx)

						emit_fx = fx
					end

					while not U.animation_finished_default(this) do
						if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
							goto label_383_0
						end

						coroutine.yield()
					end

					force_idle_ts = true

					::label_383_0::

					if emit_ps then
						emit_ps.particle_system.emit = false
						emit_ps.particle_system.source_lifetime = 0
					end

					if emit_fx then
						emit_fx.render.sprites[1].hidden = true
					end

					goto label_383_1
				end
			end
		end

		SU.soldier_idle(store, this, force_idle_ts)
		SU.soldier_regen(store, this)

		force_idle_ts = nil

		::label_383_1::

		coroutine.yield()
	end
end

local function breath_dragon_update(this, store)
	local b = this.bullet
	local tl = store.tick_length
	local mspeed = V.dist(b.to.x, b.to.y, b.from.x, b.from.y) / b.flight_time

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * tl do
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * tl, this.pos.y + b.speed.y * tl

		coroutine.yield()
	end

	this.pos.x, this.pos.y = b.to.x, b.to.y
	this.render.sprites[1].hidden = false

	local start_ts = store.tick_ts
	local fx = E:create_entity("fx_breath_dragon_fire")

	fx.pos.x, fx.pos.y = b.to.x, b.to.y
	fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(fx)

	local fx = E:create_entity("fx_breath_dragon_fire_decal")

	fx.pos.x, fx.pos.y = b.to.x, b.to.y
	fx.render.sprites[1].ts = store.tick_ts + fts(11)

	simulation:queue_insert_entity(fx)

	local targets = U.find_enemies_in_range_filter_off(this.pos, b.damage_radius, b.damage_flags, b.damage_bans)
	local every = fts(2)
	local steps = math.floor(this.duration / every)
	local damage_per_step = math.random(b.damage_min, b.damage_max) / steps * b.damage_factor
	local last_ts = 0

	while store.tick_ts - start_ts < this.duration do
		if targets and every < store.tick_ts - last_ts then
			last_ts = store.tick_ts

			for _, e in ipairs(targets) do
				if e.health and not e.health.dead then
					local d = E.assign_damage(b.damage_type, damage_per_step, this.id, e.id)

					d.xp_gain_factor = b.xp_gain_factor
					d.xp_dest_id = b.source_id

					queue_damage(store, d)

					if b.mod then
						local mod = E:create_entity(b.mod)

						mod.modifier.target_id = e.id

						simulation:queue_insert_entity(mod)
					end
				end
			end
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function fierymist_dragon_update(this, store)
	local b = this.bullet
	local tl = store.tick_length
	local node
	local mspeed = V.dist(b.to.x, b.to.y, b.from.x, b.from.y) / b.flight_time
	local dist2 = mspeed * mspeed * tl * tl
	local nodes = P:nearest_nodes(b.to.x, b.to.y, nil, nil, true)

	if #nodes > 0 then
		node = {
			pi = nodes[1][1],
			spi = nodes[1][2],
			ni = nodes[1][3]
		}
	end

	if not node then
		log.debug("cannot deploy fierymist_dragon: no destination node")
		simulation:queue_remove_entity(this)

		return
	end

	node.spi = 1

	while V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) > dist2 do
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * tl, this.pos.y + b.speed.y * tl

		coroutine.yield()
	end

	local aura = E:create_entity(b.hit_payload)

	aura.pos = P:node_pos(node.pi, node.spi, node.ni)

	simulation:queue_insert_entity(aura)

	local spi = 1

	for i = 1, 14 do
		local ni = node.ni - 6 + i

		if P:is_node_valid(node.pi, ni) then
			local fx = E:create_entity("fx_aura_fierymist_dragon")

			fx.pos = P:node_pos(node.pi, spi, ni)
			fx.pos.x, fx.pos.y = fx.pos.x + math.random(0, 8), fx.pos.y + math.random(0, 8)

			local scale = U.frandom(0.9, 1.1)

			fx.render.sprites[1].scale = V.v(scale, scale)
			fx.render.sprites[1].time_offset = fts(i * 2)
			fx.duration = aura.aura.duration
			fx.tween.ts = store.tick_ts

			simulation:queue_insert_entity(fx)
		end

		spi = km.zmod(spi + 2, 3)
	end

	simulation:queue_remove_entity(this)
end

local function wildfirebarrage_dragon_insert(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]

	if not target then
		log.debug("target removed before inserting wildfirebarrage")

		return false
	end

	local node_offset = P:predict_enemy_node_advance(target, b.flight_time)

	b.to = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)

	return true
end

local function wildfirebarrage_dragon_update(this, store)
	local b = this.bullet
	local ps = E:create_entity(b.particles_name)

	ps.particle_system.track_id = this.id

	simulation:queue_insert_entity(ps)

	while store.tick_ts - b.ts < b.flight_time do
		b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)
		this.render.sprites[1].r = V.angleTo(this.pos.x - b.last_pos.x, this.pos.y - b.last_pos.y)

		coroutine.yield()
	end

	this.render.sprites[1].hidden = true
	ps.particle_system.emit = false

	local delays = {
		0,
		0.1,
		0,
		0.1,
		0,
		0.1,
		0,
		0.1,
		0,
		0,
		0,
		0.2,
		0,
		0,
		0,
		0
	}
	local node_offsets = {
		0,
		2,
		4,
		-4,
		0,
		0,
		6,
		-6,
		8,
		8,
		-8,
		-8,
		10,
		-10,
		12,
		-12
	}
	local node_subpaths = {
		1,
		1,
		1,
		1,
		2,
		3,
		1,
		1,
		2,
		3,
		2,
		3,
		1,
		1,
		2,
		3
	}
	local node
	local nodes = P:nearest_nodes(b.to.x, b.to.y, nil, nil, true)

	if #nodes < 1 then
	-- block empty
	else
		node = {
			pi = nodes[1][1],
			spi = nodes[1][2],
			ni = nodes[1][3]
		}

		for i = 1, this.explosions do
			local fx, decal, targets
			local n = {
				pi = node.pi,
				spi = node_subpaths[i],
				ni = node.ni + node_offsets[i]
			}
			local pos = P:node_pos(n.pi, n.spi, n.ni)

			if not P:is_node_valid(n.pi, n.ni) then
			-- block empty
			else
				fx = E:create_entity("fx_wildfirebarrage_explosion_" .. ((i == 1 or i == 5 or i == 6) and "2" or "1"))
				fx.pos = pos
				fx.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(fx)

				decal = E:create_entity("decal_wildfirebarrage_explosion")

				decal.pos:copy(pos)

				decal.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(decal)

				targets = U.find_enemies_in_range_filter_off(pos, b.damage_radius, b.damage_flags, b.damage_bans)

				if targets then
					for _, target in ipairs(targets) do
						local d = SU.create_bullet_damage(b, target.id, this.id)

						d.xp_dest_id = b.source_id

						queue_damage(store, d)

						if b.mod then
							local mod = E:create_entity(b.mod)

							mod.modifier.target_id = target.id
							mod.modifier.damage_factor = b.damage_factor

							simulation:queue_insert_entity(mod)
						end
					end
				end
			end

			if delays[i] > 0 then
				U.y_wait_unconditional(store, delays[i])
			end
		end
	end

	simulation:queue_remove_entity(this)
end

local function mod_dragon_reign_remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return true
	end

	local spread_targets = U.find_enemies_in_range_filter_on(target.pos, this.spread_radius, F_MOD, 0, function(e)
		return e.id ~= this.modifier.target_id
	end)

	if spread_targets then
		for _, t in ipairs(spread_targets) do
			local m = E:create_entity(this.template_name)

			m.modifier.target_id = t.id
			m.modifier.source_id = this.modifier.source_id
			m.modifier.level = this.modifier.level
			m.modifier.damage_factor = this.modifier.damage_factor

			simulation:queue_insert_entity(m)
		end
	end

	return true
end

local tt

tt = RT("hero_dragon", "hero")

AC(tt, "ranged", "timed_attacks")

tt.hero.level_stats.hp_max = {420, 440, 460, 480, 500, 520, 540, 560, 580, 600}
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.ranged_damage_min = {17, 19, 22, 24, 26, 29, 31, 34, 36, 39}
tt.hero.level_stats.ranged_damage_max = {25, 29, 32, 36, 40, 43, 47, 50, 54, 58}
tt.hero.skills.blazingbreath = CC("hero_skill")
tt.hero.skills.blazingbreath.damage = {30, 60, 90}
tt.hero.skills.blazingbreath.xp_gain = {50, 100, 150}
tt.hero.skills.blazingbreath.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.feast = CC("hero_skill")
tt.hero.skills.feast.devour_chance = {0.25, 0.35, 0.45}
tt.hero.skills.feast.damage = {140, 200, 260}
tt.hero.skills.feast.xp_gain = {50, 100, 150}
tt.hero.skills.feast.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.fierymist = CC("hero_skill")
tt.hero.skills.fierymist.slow_factor = {0.7, 0.6, 0.5}
tt.hero.skills.fierymist.duration = {4, 5, 6}
tt.hero.skills.fierymist.xp_gain = {50, 100, 150}
tt.hero.skills.fierymist.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.wildfirebarrage = CC("hero_skill")
tt.hero.skills.wildfirebarrage.explosions = {8, 12, 16}
tt.hero.skills.wildfirebarrage.xp_gain = {50, 100, 150}
tt.hero.skills.wildfirebarrage.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.reignoffire = CC("hero_skill")
tt.hero.skills.reignoffire.dps = {5, 9, 13}
tt.hero.skills.reignoffire.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.health.armor = nil
tt.health.dead_lifetime = 15
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 189.85)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.health_bar.draw_order = -1
tt.health_bar.sort_y_offset = -200
tt.hero.fn_level_up = hero_level_up
tt.idle_flip.cooldown = 10
tt.info.hero_portrait = "kr2_hero_portraits_0010"
tt.info.portrait = "kr2_info_portraits_heroes_0010"
tt.main_script.update = hero_update
tt.motion.max_speed = 90
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.nav_grid.valid_terrains = TERRAIN_ALL_MASK
tt.nav_grid.valid_terrains_dest = TERRAIN_ALL_MASK
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].prefix = "hero_dragon"
tt.render.sprites[1].angles.walk = {"idle"}
tt.render.sprites[1].sort_y_offset = -200
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_dragon_0181"
tt.render.sprites[2].anchor.y = 0.065
tt.render.sprites[2].alpha = 60
tt.sound_events.change_rally_point = "HeroDragonTaunt"
tt.sound_events.death = "HeroDragonDeath"
tt.sound_events.respawn = "HeroDragonBorn"
tt.sound_events.insert = "HeroDragonTauntIntro"
tt.sound_events.hero_room_select = "HeroDragonTauntSelect"
tt.ui.click_rect = r(-30, 115, 60, 40)
tt.unit.hit_offset = vec_2(0, 135)
tt.unit.hide_after_death = true
tt.unit.marker_offset = vec_2(0, -0.15)
tt.unit.mod_offset = vec_2(0, 134.85)
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_POISON, F_BURN)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "fireball_dragon"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(55, 105)}
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].max_range = 140
tt.ranged.attacks[1].shoot_time = fts(11)
tt.ranged.attacks[1].sync_animation = true
tt.ranged.attacks[1].ignore_hit_offset = true
tt.ranged.attacks[1].animation = "range_attack"
tt.ranged.attacks[1].emit_fx = "fx_fireball_throw"
tt.ranged.attacks[1].estimated_flight_time = 1
tt.ranged.attacks[1].sound = "HeroDragonAttackThrow"
tt.ranged.attacks[2] = CC("bullet_attack")
tt.ranged.attacks[2].name = "blazingbreath"
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].bullet = "breath_dragon"
tt.ranged.attacks[2].bullet_start_offset = {vec_2(43, 95)}
tt.ranged.attacks[2].cooldown = 9
tt.ranged.attacks[2].max_range = 180
tt.ranged.attacks[2].shoot_time = fts(13)
tt.ranged.attacks[2].sync_animation = true
tt.ranged.attacks[2].xp_from_skill = "blazingbreath"
tt.ranged.attacks[2].animation = "breath"
tt.ranged.attacks[2].sound = "HeroDragonFlame"
tt.ranged.attacks[2].emit_fx = "fx_breath_dragon_mouth_glow"
tt.ranged.attacks[2].emit_ps = "ps_breath_dragon"
tt.ranged.attacks[2].vis_bans = F_FLYING
tt.ranged.attacks[2].nodes_limit = 10
tt.ranged.attacks[3] = CC("bullet_attack")
tt.ranged.attacks[3].name = "fierymist"
tt.ranged.attacks[3].disabled = true
tt.ranged.attacks[3].bullet = "fierymist_dragon"
tt.ranged.attacks[3].bullet_start_offset = {vec_2(43, 95)}
tt.ranged.attacks[3].cooldown = 13
tt.ranged.attacks[3].max_range = 160
tt.ranged.attacks[3].shoot_time = fts(13)
tt.ranged.attacks[3].sync_animation = true
tt.ranged.attacks[3].xp_from_skill = "fierymist"
tt.ranged.attacks[3].animation = "mist"
tt.ranged.attacks[3].emit_fx = "fx_breath_dragon_mouth_glow"
tt.ranged.attacks[3].emit_ps = "ps_fierymist_dragon"
tt.ranged.attacks[3].vis_bans = F_FLYING
tt.ranged.attacks[3].sound = "HeroDragonSmoke"
tt.ranged.attacks[3].nodes_limit = 10
tt.ranged.attacks[4] = CC("bullet_attack")
tt.ranged.attacks[4].name = "wildfirebarrage"
tt.ranged.attacks[4].disabled = true
tt.ranged.attacks[4].bullet = "wildfirebarrage_dragon"
tt.ranged.attacks[4].bullet_start_offset = {vec_2(30, 183.85)}
tt.ranged.attacks[4].cooldown = 17
tt.ranged.attacks[4].max_range = 375
tt.ranged.attacks[4].shoot_time = fts(7.8)
tt.ranged.attacks[4].sync_animation = true
tt.ranged.attacks[4].xp_from_skill = "wildfirebarrage"
tt.ranged.attacks[4].animation = "wildfirebarrage"
tt.ranged.attacks[4].emit_fx = "fx_emit_wildfirebarrage"
tt.ranged.attacks[4].vis_bans = F_FLYING
tt.ranged.attacks[4].sound = "HeroDragonNapalm"
tt.ranged.attacks[4].nodes_limit = 10
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].cooldown = 30
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].max_range = 60
tt.timed_attacks.list[1].damage_type = DAMAGE_PHYSICAL
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_BOSS, F_WATER, F_CLIFF)
tt.timed_attacks.list[1].sound = "HeroDragonTauntSelect"
tt = RT("fireball_dragon", "bullet")
tt.render.sprites[1].name = "hero_dragon_attack_proy"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.x = 0.69
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.xp_gain_factor = 2.5
tt.bullet.min_speed = 390
tt.bullet.max_speed = 390
tt.bullet.hit_fx = "fx_fireball_dragon_hit"
tt.bullet.hit_fx_air = "fx_fireball_explosion_air"
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_radius = 40
tt.bullet.particles_name = "ps_fireball_dragon"
tt.main_script.update = scripts.fireball_dragon.update
tt.sound_events.hit = "HeroDragonAttackHit"
tt = RT("fx_fireball_dragon_hit", "fx")
tt.render.sprites[1].name = "fx_fireball_dragon_hit"
tt.render.sprites[1].anchor.y = 0.24
tt = RT("fx_fireball_explosion_air", "fx_explosion_air")
tt.render.sprites[1].scale = vec_2(0.7, 0.7)
tt = RT("fx_fireball_throw", "fx")
tt.render.sprites[1].name = "fx_dragon_range_attack"
tt.render.sprites[1].z = Z_BULLETS + 1
tt = RT("ps_fireball_dragon")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_dragon_fireThrow_particle2"
tt.particle_system.particle_lifetime = {fts(10), fts(16)}
tt.particle_system.scale_var = {0.78, 1.43}
tt.particle_system.scales_x = {1, 1.25}
tt.particle_system.scales_y = {1, 1.25}
tt.particle_system.emission_rate = 40
tt.particle_system.emit_spread = math.pi
tt.particle_system.alphas = {255, 0}
tt = RT("mod_dragon_reign", "modifier")

AC(tt, "dps", "render")

tt.modifier.duration = 3
tt.modifier.max_duplicates = 3
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = fts(15)
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.main_script.remove = mod_dragon_reign_remove
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 2
tt.spread_radius = 60
tt = RT("breath_dragon", "bullet")
tt.render.sprites[1].name = "hero_dragon_flameBurnDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].hidden = true
tt.bullet.flight_time = fts(10)
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_radius = 65
tt.bullet.damage_flags = F_AREA
tt.main_script.update = breath_dragon_update
tt.duration = fts(20)
tt = RT("fx_breath_dragon_fire", "fx")
tt.render.sprites[1].name = "dragon_breath_fire"
tt.render.sprites[1].anchor.y = 0.3472222222222222
tt = RT("fx_breath_dragon_fire_decal", "fx")
tt.render.sprites[1].name = "dragon_breath_fire_decal"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].anchor.y = 0.3424657534246575
tt = RT("fx_breath_dragon_mouth_glow", "decal_timed")
tt.render.sprites[1].name = "hero_dragon_flameBurnGlow_cut"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.timed.duration = fts(20)
tt = RT("ps_breath_dragon")

AC(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "dragon_breath_particle"
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.source_lifetime = fts(20)
tt = RT("fx_dragon_feast", "fx")
tt.render.sprites[1].name = "fx_dragon_feast"
tt.render.sprites[1].anchor.y = 0.065
tt = RT("fx_dragon_feast_explode", "fx")
tt.render.sprites[1].name = "fx_dragon_feast_explode"
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].size_scales = {vec_1(0.8), vec_1(1), vec_1(1.2)}
tt = RT("fierymist_dragon", "bullet")
tt.render = nil
tt.bullet.flight_time = fts(10)
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.hit_payload = "aura_fierymist_dragon"
tt.main_script.update = fierymist_dragon_update
tt = RT("ps_fierymist_dragon")

AC(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "dragon_fierymist_particle"
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.source_lifetime = fts(20)
tt = RT("aura_fierymist_dragon", "aura")
tt.aura.mod = "mod_slow_fierymist"
tt.aura.cycle_time = fts(5)
tt.aura.duration = nil
tt.aura.radius = 70
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.damage_min = 2
tt.aura.damage_max = 2
tt.aura.vis_flags = F_MOD
tt.aura.vis_bans = F_FRIEND
tt.main_script.update = scripts.aura_fiery_mist_ashbite.update
tt = RT("mod_slow_fierymist", "mod_slow")
tt.modifier.duration = fts(5)
tt.slow.factor = nil
tt = RT("fx_aura_fierymist_dragon", "decal_tween")
tt.render.sprites[1].name = "fx_fierymist_dragon"
tt.render.sprites[1].anchor.y = 0.15
tt.tween.props[1].keys = {{0, 0}, {fts(6), 255}, {"this.duration-0.3", 255}, {"this.duration", 0}}
tt = RT("wildfirebarrage_dragon", "bullet")
tt.render.sprites[1].name = "dragon_wildfirebarrage_projectile"
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.min_speed = 390
tt.bullet.max_speed = 390
tt.bullet.flight_time = fts(35)
tt.bullet.hit_fx = "fx_fireball_dragon_hit"
tt.bullet.damage_max = 30
tt.bullet.damage_min = 30
tt.bullet.damage_radius = 40
tt.bullet.particles_name = "ps_wildbarrage_dragon"
tt.bullet.damage_flags = F_AREA
tt.main_script.insert = wildfirebarrage_dragon_insert
tt.main_script.update = wildfirebarrage_dragon_update
tt.sound_events.hit = "HeroDragonAttackHit"
tt = RT("fx_emit_wildfirebarrage", "fx")
tt.render.sprites[1].name = "fx_dragon_wildfirebarrage"
tt.render.sprites[1].z = Z_BULLETS + 1
tt.render.sprites[1].offset = vec_2(-28, -48)
tt = RT("ps_wildbarrage_dragon")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "dragon_wildfirebarrage_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {0.58, 0.58}
tt.particle_system.scale_var = {0.55, 0.9}
tt.particle_system.scales_x = {1, 1.55}
tt.particle_system.scales_y = {1, 1.55}
tt.particle_system.emission_rate = 60
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.alphas = {255, 0}
tt = RT("fx_wildfirebarrage_explosion_1", "fx")
tt.render.sprites[1].name = "dragon_wildfirebarrage_explosion_1"
tt.render.sprites[1].anchor.y = 0.24
tt = RT("fx_wildfirebarrage_explosion_2", "fx")
tt.render.sprites[1].name = "dragon_wildfirebarrage_explosion_2"
tt.render.sprites[1].anchor.y = 0.16
tt = RT("decal_wildfirebarrage_explosion", "decal_timed")
tt.render.sprites[1].name = "dragon_wildfirebarrage_decal"
tt.render.sprites[1].anchor.y = 0.3
tt.render.sprites[1].z = Z_DECALS
