local bit = require("bit")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local scripts = require("scripts")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")

require("all.constants")
require("lib.klua.table")

local band = bit.band
local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage
local fts = U.fts

local THROTTLE_CD = 1

local function apply_delayed_cooldowns(store, attacks)
	for _, a in ipairs(attacks) do
		if a.throttle_cooldown_on_skill_use and a.cooldown and store.tick_ts - a.ts >= a.cooldown then
			a.ts = store.tick_ts - a.cooldown + THROTTLE_CD
		end
	end
end

local function aura_ignus_apply_damage_update(this, store)
	local a = this.aura

	a.ts = store.tick_ts

	local last_hit_ts = 0
	local cycles_count = 0

	while true do
		if a.cycles and cycles_count >= a.cycles then
			break
		elseif not a.cycles and store.tick_ts - a.ts >= a.duration then
			break
		end

		local source = store.entities[a.source_id]

		if a.track_source then
			if not source then
				simulation:queue_remove_entity(this)

				return
			end

			if not source.health.dead then
				this.pos.x, this.pos.y = source.pos.x, source.pos.y
			end
		end

		if not source.health.dead and store.tick_ts - last_hit_ts >= a.cycle_time then
			cycles_count = cycles_count + 1
			last_hit_ts = store.tick_ts

			local targets = U.find_enemies_in_range(store, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

			if targets then
				local factor = source.unit.damage_factor
				local buff = source.unit.damage_buff or 0

				for _, target in ipairs(targets) do
					local d = E.assign_damage(a.damage_type, math.ceil((math.random(a.damage_min, a.damage_max) + buff) * factor), this.id, target.id)

					d.xp_dest_id = a.xp_dest_id
					d.xp_gain_factor = a.xp_gain_factor
					queue_damage(store, d)

					if a.hit_fx then
						local fx = E:create_entity(a.hit_fx)

						fx.pos.x, fx.pos.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
						fx.render.sprites[1].ts = store.tick_ts

						simulation:queue_insert_entity(fx)
					end
				end
			end
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function bolt_ignus_skill_a_insert(this, store)
	local b = this.bullet

	if b.target_id then
		local target = store.entities[b.target_id]

		if not target or band(target.vis.bans, F_RANGED) ~= 0 then
			return false
		end
	end

	b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

	local s = this.render.sprites[1]

	s.ts = store.tick_ts
	s.runs = 0

	if not b.ignore_rotation then
		s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
	end

	return true
end

local function bolt_ignus_skill_a_update(this, store)
	local b = this.bullet
	local mspeed = b.min_speed
	local tl = store.tick_length
	local ps

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * tl do
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * tl, this.pos.y + b.speed.y * tl

		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
		coroutine.yield()
	end

	this.pos.x, this.pos.y = b.to.x, b.to.y

	if ps then
		ps.particle_system.emit = false
		ps.particle_system.source_lifetime = 0
	end

	local target = store.entities[b.target_id]

	if target and not target.health.dead then
		local source = store.entities[b.source_id]
		local value = (math.random(b.damage_min, b.damage_max) + source.unit.damage_buff) * source.unit.damage_factor
		local d = E.assign_damage(b.damage_type, math.ceil(value), this.id, target.id)

		d.xp_gain_factor = b.xp_gain_factor
		d.xp_dest_id = b.xp_dest_id
		queue_damage(store, d)

		local fx = E:create_entity(b.hit_fx)

		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].flip_x = this.pos.x > b.to.x

		simulation:queue_insert_entity(fx)
	end

	simulation:queue_remove_entity(this)
end

local function binomial(n, k)
	local result = 1

	for i = 1, k do
		result = result * (n - (k - i))
		result = result / i
	end

	return result
end

local function bernstein(i, n, t)
	return binomial(n, i) * (1 - t) ^ (n - i) * t ^ i
end

local function evaluate_bezier(control_points, t)
	local n = #control_points - 1
	local numerator_x = 0
	local numerator_y = 0
	local denominator = 0

	for i = 0, n do
		local p = control_points[i + 1]
		local wb = bernstein(i, n, t) * p.weight

		numerator_x = numerator_x + p.x * wb
		numerator_y = numerator_y + p.y * wb
		denominator = denominator + wb
	end

	return {
		x = numerator_x / denominator,
		y = numerator_y / denominator
	}
end

local function generate_bezier_curve(control_points, resolution)
	local curve = {}

	for i = 0, resolution do
		curve[#curve + 1] = evaluate_bezier(control_points, i / resolution)
	end

	return curve
end

local function bullet_ignus_skill_c_update(this, store)
	local b = this.bullet
	local dist_y = math.abs(b.from.y - b.to.y)
	local mspeed = dist_y / b.travel_time - b.acceleration * b.travel_time * 0.5
	local prefix = 0
	local already_hit = {}

	if this.blocked_id then
		already_hit[#already_hit + 1] = this.blocked_id
	end

	local source = store.entities[b.source_id]
	local hits = 0
	local original_pos = V.vclone(b.from)
	local original_flip = source.render.sprites[1].flip_x and -1 or 1

	original_pos.x = original_pos.x + this.return_offset.x * original_flip
	original_pos.y = original_pos.y + this.return_offset.y

	local function generate_return_points(start_x, start_y, end_x, end_y, arc_height, side)
		local dx = end_x - start_x
		local dy = end_y - start_y
		local len = math.sqrt(dx * dx + dy * dy)
		local dir_x = dx / len
		local dir_y = dy / len
		local perp_x = -dir_y * side
		local perp_y = dir_x * side
		local p1x = start_x + dx * 0.25 + perp_x * arc_height * 0.5
		local p1y = start_y + dy * 0.25 + perp_y * arc_height * 0.5
		local p2x = start_x + dx * 0.5 + perp_x * arc_height
		local p2y = start_y + dy * 0.5 + perp_y * arc_height
		local p3x = start_x + dx * 0.75 + perp_x * arc_height * 0.5
		local p3y = start_y + dy * 0.75 + perp_y * arc_height * 0.5

		return {{
			weight = 1,
			x = start_x,
			y = start_y
		}, {
			weight = 5,
			x = p1x,
			y = p1y
		}, {
			weight = 10,
			x = p2x,
			y = p2y
		}, {
			weight = 35,
			x = p3x,
			y = p3y
		}, {
			weight = 1,
			x = end_x,
			y = end_y
		}}
	end

	local particle = E:create_entity(b.particles_name)

	particle.particle_system.track_id = this.id

	simulation:queue_insert_entity(particle)

	::label_ignus_skill_c::

	particle.particle_system.emit = true

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		mspeed = mspeed + 1 / FPS * b.acceleration
		mspeed = math.max(b.min_speed, math.min(b.max_speed, mspeed))
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length

		coroutine.yield()
	end

	this.pos.x, this.pos.y = b.to.x, b.to.y
	prefix = prefix + 1

	if prefix > 3 then
		prefix = 1
	end

	particle.particle_system.emit = false

	local p = E:create_entity(b.payload)

	p.pos = V.vclone(this.pos)
	p.render.sprites[1].prefix = "skill0" .. prefix .. "Def"
	p.render.sprites[1].ts = store.tick_ts
	p.render.sprites[1].flip_x = source.render.sprites[1].flip_x
	p.source_id = b.source_id
	p.target_id = b.target_id
	p.damage_min = this.payload_damage_min
	p.damage_max = this.payload_damage_max
	p.damage_type = this.payload_damage_type

	simulation:queue_insert_entity(p)
	U.y_wait(store, fts(8))
	already_hit[#already_hit + 1] = b.target_id

	hits = hits + 1

	local t, _, pred_pos = U.find_foremost_enemy(store, this.pos, 0, this.bounce_range, fts(20), 0, this.bans, function(e)
		for _, id in pairs(already_hit) do
			if e.id == id then
				return false
			end
		end

		return true
	end)

	if t and hits < this.max_hits then
		b.target_id = t.id

		local flip = t.pos.x < this.pos.x and 1 or -1

		b.to = pred_pos
		b.to.x = pred_pos.x + flip * (t.unit.hit_offset.x + source.soldier.melee_slot_offset.x)
		b.to.y = pred_pos.y + t.unit.hit_offset.y + source.soldier.melee_slot_offset.y
		b.from = V.vclone(this.pos)

		goto label_ignus_skill_c
	end

	particle.particle_system.emit = true

	local points = generate_return_points(this.pos.x, this.pos.y, original_pos.x, original_pos.y, 50, original_flip)
	local curve = generate_bezier_curve(points, 6)
	local dr = E:create_entity(this.decal_return)

	dr.pos = V.vclone(this.pos)
	dr.render.sprites[1].flip_x = this.pos.x < original_pos.x
	dr.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(dr)

	for _, v in pairs(curve) do
		b.to = v

		while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
			mspeed = mspeed + 1 / FPS * b.acceleration
			mspeed = math.max(b.min_speed, math.min(b.max_speed, mspeed))
			b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
			this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length

			coroutine.yield()
		end
	end

	particle.particle_system.source_lifetime = 0
	this.pos.x = original_pos.x
	this.pos.y = original_pos.y
	source.end_skill_c = true

	simulation:queue_remove_entity(this)
end

local function decal_ignus_hit_skill_c_update(this, store)
	U.y_wait(store, this.hit_time)

	local source = store.entities[this.source_id]
	local value = (math.random(this.damage_min, this.damage_max) + source.unit.damage_buff) * source.unit.damage_factor
	local d = E.assign_damage(this.damage_type, math.ceil(value), this.source_id, this.target_id)

	queue_damage(store, d)

	local fx = E:create_entity(this.hit_fx)

	fx.render.sprites[1].ts = store.tick_ts
	fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x
	fx.pos.x, fx.pos.y = this.pos.x + this.hit_offset.x, this.pos.y + this.hit_offset.y

	simulation:queue_insert_entity(fx)
	S:queue(this.sound)
	U.y_animation_wait(this)
	simulation:queue_remove_entity(this)
end

local function hero_ignus_kr6_level_up(this, store, initial)
	if not initial then
		S:queue(this.sound_events.level_up)
	end

	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "skill_a", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil

		if s.level == 1 then
			a.ts = store.tick_ts - a.cooldown * (this.unit.cooldown_factor or 1)
		end
	end)
	upgrade_skill(this, "skill_b", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		if s.level == 1 then
			a.ts = store.tick_ts - a.cooldown * (this.unit.cooldown_factor or 1)
		end
	end)
	upgrade_skill(this, "skill_c", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil

		if s.level == 1 then
			a.ts = store.tick_ts - a.cooldown * (this.unit.cooldown_factor or 1)
			this.end_skill_c = false
		end
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		local a = this.timed_attacks.list[4]

		a.disabled = nil
		a.ts = store.tick_ts - a.cooldown * (this.unit.cooldown_factor or 1)
	end)
	upgrade_skill(this, "talent_1", function(this, s)
		this.hero.skills.talent_1.disabled = nil
	end)
	upgrade_skill(this, "talent_2", function(this, s)
		this.hero.skills.talent_2.disabled = nil
	end)
	update_hp(this)
end

local function hero_ignus_kr6_insert(this, store)
	this.hero.fn_level_up(this, store, true)
	this.melee.order = U.attack_order(this.melee.attacks)
	this.timed_attacks.list[4].disabled = true

	return true
end

local function hero_ignus_kr6_update(this, store)
	local h = this.health
	local skills = this.hero.skills
	local list = this.timed_attacks.list
	local sa, sb, sc, ultimate = list[1], list[2], list[3], list[4]
	local brk, sta
	local old_tombstone_time = this.hero.tombstone_show_time
	local old_tombstone_respawn_animation = this.hero.tombstone_respawn_animation

	this.health_bar.hidden = false
	this.end_skill_c = false

	if skills.talent_1.level > 0 and not this.hero.talent_1_aura then
		local aura = E:create_entity(skills.talent_1.aura)

		aura.pos = V.vclone(this.pos)
		aura.aura.source_id = this.id
		aura.aura.track_source = true

		simulation:queue_insert_entity(aura)

		this.hero.talent_1_aura = aura.id
	end

	local function talent_2_heal()
		local t2 = skills.talent_2

		if t2.level > 0 and not h.dead then
			local m = E:create_entity(t2.mod)

			m.hps.heal_min = h.hp_max * t2.heal_ptg
			m.hps.heal_max = h.hp_max * t2.heal_ptg
			m.modifier.target_id = this.id

			simulation:queue_insert_entity(m)
		end
	end

	while true do
		if h.dead then
			if band(h.last_damage_types, bor(DAMAGE_EAT)) ~= 0 then
				this.hero.tombstone_show_time = nil
				this.hero.tombstone_respawn_animation = nil
			end

			SU.y_hero_death_and_respawn(store, this)

			this.hero.tombstone_show_time = old_tombstone_time
			this.hero.tombstone_respawn_animation = old_tombstone_respawn_animation
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					break
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "lvlup", nil, store.tick_ts, 1)
			end

			if ready_to_use_skill(ultimate, store, this.unit.cooldown_factor) then
				local targets = U.find_enemies_in_range(store, this.pos, 0, ultimate.max_range, 0, 0)

				if not targets or #targets < ultimate.min_targets or not this.motion.arrived then
					SU.delay_attack(store, ultimate, fts(10))
				else
					local selected_e = store.entities[this.soldier.target_id] or targets[1]

					U.unblock_target(store, this)
					S:queue(ultimate.taunt)
					S:queue(ultimate.sound_cast)
					U.animation_start(this, ultimate.animations[1], nil, store.tick_ts, false, 1)

					if SU.y_hero_wait(store, this, ultimate.cast_time) then
						goto continue
					end

					U.animation_start(this, ultimate.animations[2], nil, store.tick_ts, true, 1)
					S:queue(ultimate.sound_loop)

					local start_ts = store.tick_ts
					local a = E:create_entity(ultimate.aura)
					local nearest = P:nearest_nodes(this.pos.x, this.pos.y, {selected_e.nav_path.pi})[1]
					local node_pos = P:node_pos(nearest[1], 1, nearest[3])

					a.pos = V.vclone(this.pos)
					a.aura.source_id = this.id
					a.aura.cycle_time = ultimate.cycle_time
					a.aura.duration = ultimate.duration
					a.aura.damage_min = ultimate.damage_min
					a.aura.damage_max = ultimate.damage_max
					a.aura.damage_type = ultimate.damage_type
					a.aura.radius = ultimate.damage_radius

					simulation:queue_insert_entity(a)

					U.bans_add(this.vis, F_ALL)
					this.health.ignore_damage = true

					U.set_destination(this, node_pos)
					U.speed_mul_self(this, ultimate.movement_speed)

					while store.tick_ts - start_ts < ultimate.duration do
						if not V.veq(this.pos, node_pos) then
							U.walk(this, store.tick_length)
						end

						coroutine.yield()
					end

					this.motion.arrived = true
					U.speed_div_self(this, ultimate.movement_speed)

					local d = E:create_entity(ultimate.ground_decal)

					d.pos = V.vclone(this.pos)
					d.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(d)
					S:stop(ultimate.sound_loop)
					S:queue(ultimate.sound_end)
					S:queue(this.sound_transformation_in, {
						delay = fts(13)
					})
					S:queue(this.sound_transformation_out, {
						delay = fts(39)
					})
					U.y_animation_play(this, ultimate.animations[3], nil, store.tick_ts, 1, 1)

					U.bans_remove(this.vis, F_ALL)
					this.health.ignore_damage = false

					SU.hero_gain_xp_from_skill(this, skills.ultimate)
					talent_2_heal()

					ultimate.ts = store.tick_ts

					apply_delayed_cooldowns(store, list)

					goto continue
				end
			end

			if ready_to_use_skill(sb, store, this.unit.cooldown_factor) then
				local target, targets = U.find_foremost_enemy(store, this.pos, 0, sb.max_range, fts(10), 0, 0)

				if not targets or #targets < sb.min_targets or not this.motion.arrived then
					SU.delay_attack(store, sb, fts(10))
				else
					S:queue(sb.sound)
					U.animation_start(this, sb.animation, nil, store.tick_ts, false, 1)

					if SU.y_hero_wait(store, this, sb.cast_time) then
						goto continue
					end

					local a = E:create_entity(sb.aura)
					local d = E:create_entity(sb.decal_ground)

					a.pos = V.vclone(this.pos)
					a.aura.source_id = this.id
					a.aura.damage_min = skills.skill_b.damage_min[skills.skill_b.level]
					a.aura.damage_max = skills.skill_b.damage_max[skills.skill_b.level]

					d.pos = V.vclone(this.pos)
					d.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(a)
					simulation:queue_insert_entity(d)
					S:queue(this.sound_transformation_in, {
						delay = fts(27)
					})
					SU.hero_gain_xp_from_skill(this, skills.skill_b)
					talent_2_heal()
					U.y_animation_wait(this)

					sb.ts = store.tick_ts

					apply_delayed_cooldowns(store, list)

					goto continue
				end
			end

			local blocked = this.soldier.target_id and store.entities[this.soldier.target_id]

			if ready_to_use_skill(sc, store, this.unit.cooldown_factor) and (not blocked or band(blocked.vis.flags, F_BOSS) == 0) then
				local t, _, pred_pos = U.find_foremost_enemy(store, this.pos, 0, sc.detection_range, fts(20), 0, sc.bans, function(e)
					return e.id ~= this.soldier.target_id
				end)

				if not t or not this.motion.arrived then
					SU.delay_attack(store, sc, fts(10))
				else
					U.animation_start(this, sc.animation_in, t.pos.x < this.pos.x, store.tick_ts, false, 1)

					if SU.y_hero_wait(store, this, sc.dissapear_time) then
						goto continue
					end

					S:queue(sc.sound)

					this.health_bar.hidden = true

					local mod

					if this.soldier.target_id ~= nil then
						mod = E:create_entity(sc.mod_stun)
						mod.modifier.source_id = this.id
						mod.modifier.target_id = this.soldier.target_id

						simulation:queue_insert_entity(mod)
					end

					U.bans_add(this.vis, F_ALL)
					this.health.ignore_damage = true

					if mod then
						local fx = E:create_entity(sc.fx_stun)
						local flip = this.render.sprites[1].flip_x and -1 or 1
						local pos_x = this.pos.x + this.melee.attacks[1].hit_offset.x * flip
						local pos_y = this.pos.y + this.melee.attacks[1].hit_offset.y

						fx.pos = vec_2(pos_x, pos_y)
						fx.render.sprites[1].ts = store.tick_ts
						fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x

						simulation:queue_insert_entity(fx)
					end

					t, _, pred_pos = U.find_foremost_enemy(store, this.pos, 0, sc.detection_range, fts(20), 0, sc.bans, function(e)
						return e.id ~= this.soldier.target_id
					end)

					if t then
						local b = E:create_entity(sc.bullet)
						local flip = t.pos.x < this.pos.x and 1 or -1

						b.bullet.target_id = t.id
						b.pos = V.vclone(this.pos)
						b.bullet.from = b.pos
						b.bullet.to = pred_pos
						b.bullet.to.x = pred_pos.x + flip * (t.unit.hit_offset.x + this.soldier.melee_slot_offset.x)
						b.bullet.to.y = pred_pos.y + t.unit.hit_offset.y + this.soldier.melee_slot_offset.y
						b.bullet.source_id = this.id
						b.payload_damage_min = skills.skill_c.damage_min[skills.skill_c.level]
						b.payload_damage_max = skills.skill_c.damage_max[skills.skill_c.level]
						b.payload_damage_type = skills.skill_c.damage_type

						if this.soldier.target_id ~= nil then
							b.blocked_id = this.soldier.target_id
						end

						simulation:queue_insert_entity(b)

						while not this.end_skill_c do
							coroutine.yield()
						end

						SU.hero_gain_xp_from_skill(this, skills.skill_c)
						talent_2_heal()
					else
						U.y_wait(store, fts(10))
					end

					this.end_skill_c = false
					this.health_bar.hidden = false

					U.bans_remove(this.vis, F_ALL)
					this.health.ignore_damage = false

					U.animation_start(this, sc.animation_out, nil, store.tick_ts, false, 1)
					S:queue(this.sound_transformation_in, {
						delay = fts(8)
					})
					S:queue(this.sound_transformation_out, {
						delay = fts(28)
					})
					U.y_wait(store, sc.invincible_time)

					if mod and store.entities[mod.id] then
						store.entities[mod.id].modifier.duration = 0
					end

					U.y_animation_wait(this)

					sc.ts = store.tick_ts

					apply_delayed_cooldowns(store, list)

					goto continue
				end
			end

			if ready_to_use_skill(sa, store, this.unit.cooldown_factor) then
				local target, _, pred_pos = U.find_foremost_enemy(store, this.pos, sa.min_range, sa.max_range, sa.prediction, sa.vis_flags, sa.vis_bans)

				if not target or not this.motion.arrived then
					SU.delay_attack(store, sa, fts(10))
				else
					this.render.sprites[1].flip_x = target.pos.x < this.pos.x
					U.animation_start(this, sa.animation, nil, store.tick_ts, false, 1)

					if SU.y_hero_wait(store, this, sa.cast_time) then
						goto continue
					end

					S:queue(sa.sound)

					local b = E:create_entity(sa.bullet)

					b.bullet.target_id = target.id
					b.bullet.source_id = this.id
					b.bullet.xp_dest_id = this.id
					b.bullet.damage_min = skills.skill_a.damage_min[skills.skill_a.level]
					b.bullet.damage_max = skills.skill_a.damage_max[skills.skill_a.level]
					b.bullet.damage_type = skills.skill_a.damage_type
					b.pos.x, b.pos.y = this.pos.x + sa.offset.x, this.pos.y + sa.offset.y
					b.bullet.from = V.vclone(b.pos)
					b.bullet.to = vec_2(pred_pos.x + target.unit.hit_offset.x, pred_pos.y + target.unit.hit_offset.y)

					simulation:queue_insert_entity(b)

					local fx = E:create_entity(sa.fx)

					fx.render.sprites[1].ts = store.tick_ts
					fx.render.sprites[1].r = V.angleTo(this.pos.x, this.pos.y, target.pos.x, target.pos.y)
					fx.pos = V.vclone(b.pos)

					simulation:queue_insert_entity(fx)
					SU.hero_gain_xp_from_skill(this, skills.skill_a)
					talent_2_heal()

					sa.ts = store.tick_ts

					apply_delayed_cooldowns(store, list)
					SU.y_hero_animation_wait(this)

					goto continue
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if not brk and sta == A_DONE then
				U.y_animation_play(this, "attack_out", nil, store.tick_ts, 1, 1)
			end

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			elseif SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::continue::

		coroutine.yield()
	end
end

local tt

tt = RT("hero_ignus_kr6", "hero")
AC(tt, "melee", "timed_attacks")
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {210, 225, 240, 255, 270, 285, 300, 315, 330, 345}
tt.hero.level_stats.melee_damage_min = {3, 3, 4, 4, 5, 5, 6, 7, 7, 8}
tt.hero.level_stats.melee_damage_max = {4, 5, 6, 7, 7, 8, 9, 10, 11, 11}
tt.hero.skills.skill_a = CC("hero_skill")
tt.hero.skills.skill_a.cooldown = 10
tt.hero.skills.skill_a.damage_min = {40, 64, 100}
tt.hero.skills.skill_a.damage_max = {60, 96, 150}
tt.hero.skills.skill_a.damage_type = DAMAGE_TRUE
tt.hero.skills.skill_a.xp_gain = {40, 80, 120}
tt.hero.skills.skill_a.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.skill_b = CC("hero_skill")
tt.hero.skills.skill_b.cooldown = 18
tt.hero.skills.skill_b.damage_min = {48, 64, 88}
tt.hero.skills.skill_b.damage_max = {90, 120, 165}
tt.hero.skills.skill_b.damage_type = DAMAGE_TRUE
tt.hero.skills.skill_b.min_targets = 3
tt.hero.skills.skill_b.xp_gain = {72, 144, 216}
tt.hero.skills.skill_b.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.skill_c = CC("hero_skill")
tt.hero.skills.skill_c.cooldown = 15
tt.hero.skills.skill_c.damage_min = {56, 80, 120}
tt.hero.skills.skill_c.damage_max = {84, 120, 180}
tt.hero.skills.skill_c.damage_type = DAMAGE_TRUE
tt.hero.skills.skill_c.max_hits = 3
tt.hero.skills.skill_c.xp_gain = {60, 120, 180}
tt.hero.skills.skill_c.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.level = 1
tt.hero.skills.ultimate.xp_gain = {120}
tt.hero.skills.ultimate.xp_level_steps = {
	[5] = 1
}
tt.hero.skills.talent_1 = CC("hero_skill")
tt.hero.skills.talent_1.aura = "aura_ignus_talent_1"
tt.hero.skills.talent_1.damage_min = 2
tt.hero.skills.talent_1.damage_max = 2
tt.hero.skills.talent_1.damage_type = DAMAGE_TRUE
tt.hero.skills.talent_1.cycle_time = 0.25
tt.hero.skills.talent_1.disabled = true
tt.hero.skills.talent_1.xp_level_steps = {
	[1] = 1
}
tt.hero.skills.talent_2 = CC("hero_skill")
tt.hero.skills.talent_2.heal_ptg = 0.15
tt.hero.skills.talent_2.mod = "mod_ignus_talent_2_heal"
tt.hero.skills.talent_2.disabled = true
tt.hero.skills.talent_2.xp_level_steps = {
	[1] = 1
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 45)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_ignus_kr6_level_up
tt.hero.respawn_animation = "respawn"
tt.hero.tombstone_show_time = fts(60)
tt.hero.tombstone_decal = "decal_ignus_tombstone"
tt.hero.tombstone_concurrent_with_death = true
tt.info.hero_portrait = "kr6_hero_portraits_0010"
tt.info.portrait = "kr6_info_portraits_heroes_0011"
tt.main_script.insert = hero_ignus_kr6_insert
tt.main_script.update = hero_ignus_kr6_update
tt.motion.max_speed = 70
tt.regen.cooldown = 1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].prefix = "ignusDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = DO_HEROES
tt.sound_events.change_rally_point = "HeroIgnusTaunt"
tt.sound_events.death = "HeroIgnusDeath"
tt.sound_events.respawn = "HeroIgnusTauntIntro"
tt.sound_events.hero_room_select = "HeroIgnusTauntSelect"
tt.sound_events.level_up = "HeroIgnusTauntLevelUp"
tt.sound_transformation_in = "HeroIgnusTransformationIn"
tt.sound_transformation_out = "HeroIgnusTransformationOut"
tt.soldier.melee_slot_offset = vec_2(5, 0)
tt.ui.click_rect = r(-22, -5, 40, 43)
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.marker_offset = vec_2(0, -1)
tt.unit.mod_offset = vec_2(0, 19.9)
tt.unit.pop_offset = vec_2(0, 15)
tt.unit.hide_after_death = true
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animations = {nil, "attack_loop"}
tt.melee.attacks[1].cooldown = 0
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].hit_times = {fts(14), fts(22), fts(29)}
tt.melee.attacks[1].hit_fx = "fx_ignus_hit_basic_attack"
tt.melee.attacks[1].hit_offset = vec_2(30, 15)
tt.melee.attacks[1].interrupt_on_dead_target = true
tt.melee.attacks[1].loops = 1
tt.melee.attacks[1].sound_hit = "HeroIgnusBasicAttackCast"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 1.4
tt.melee.cooldown = 0
tt.melee.range = 78
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "skill_01"
tt.timed_attacks.list[1].bullet = "bullet_ignus_skill_a"
tt.timed_attacks.list[1].cast_time = fts(33)
tt.timed_attacks.list[1].cooldown = 10
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].fx = "fx_ignus_sparks_skill_a"
tt.timed_attacks.list[1].max_range = 120
tt.timed_attacks.list[1].min_range = 50
tt.timed_attacks.list[1].offset = vec_2(0, 50)
tt.timed_attacks.list[1].prediction = fts(39)
tt.timed_attacks.list[1].sound = "HeroIgnusFireballCast"
tt.timed_attacks.list[1].throttle_cooldown_on_skill_use = true
tt.timed_attacks.list[1].vis_bans = 0
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animation = "skill_02"
tt.timed_attacks.list[2].aura = "aura_ignus_skill_b"
tt.timed_attacks.list[2].cast_time = fts(34)
tt.timed_attacks.list[2].cooldown = 18
tt.timed_attacks.list[2].decal_ground = "decal_ignus_ground_skill_b"
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].max_range = 90
tt.timed_attacks.list[2].min_targets = 3
tt.timed_attacks.list[2].sound = "HeroIgnusHeatwaveCast"
tt.timed_attacks.list[2].throttle_cooldown_on_skill_use = true
tt.timed_attacks.list[3] = CC("custom_attack")
tt.timed_attacks.list[3].animation_in = "skill_03_in"
tt.timed_attacks.list[3].animation_out = "skill_03_out"
tt.timed_attacks.list[3].bans = F_FLYING
tt.timed_attacks.list[3].bullet = "bullet_ignus_skill_c"
tt.timed_attacks.list[3].cooldown = 15
tt.timed_attacks.list[3].detection_range = 100
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].dissapear_time = fts(12)
tt.timed_attacks.list[3].fx_stun = "fx_ignus_hit"
tt.timed_attacks.list[3].invincible_time = fts(26)
tt.timed_attacks.list[3].mod_stun = "mod_ignus_skill_c_stun"
tt.timed_attacks.list[3].sound = "HeroIgnusFlameRushCast"
tt.timed_attacks.list[3].throttle_cooldown_on_skill_use = true
tt.timed_attacks.list[4] = CC("custom_attack")
tt.timed_attacks.list[4].animations = {"ulti_in", "ulti_loop", "ulti_out"}
tt.timed_attacks.list[4].aura = "aura_ignus_ultimate"
tt.timed_attacks.list[4].cast_time = fts(26)
tt.timed_attacks.list[4].cooldown = 30
tt.timed_attacks.list[4].damage_max = 30
tt.timed_attacks.list[4].damage_min = 20
tt.timed_attacks.list[4].damage_radius = 80
tt.timed_attacks.list[4].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].duration = 3
tt.timed_attacks.list[4].ground_decal = "decal_ignus_ground_ultimate"
tt.timed_attacks.list[4].max_range = 80
tt.timed_attacks.list[4].min_targets = 2
tt.timed_attacks.list[4].movement_speed = 0.21
tt.timed_attacks.list[4].cycle_time = 0.25
tt.timed_attacks.list[4].sound_cast = "HeroIgnusSupernovaLoopStart"
tt.timed_attacks.list[4].sound_end = "HeroIgnusSupernovaLoopEnd"
tt.timed_attacks.list[4].sound_loop = "HeroIgnusSupernovaLoop"
tt.timed_attacks.list[4].taunt = "HeroIgnusTauntUltimate"
tt.timed_attacks.list[4].throttle_cooldown_on_skill_use = true

tt = RT("mod_ignus_skill_c_stun", "mod_stun")
tt.modifier.duration = 1e+99
tt.modifier.vis_bans = bor(F_BOSS)
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.resets_same = true

tt = RT("mod_ignus_talent_2_heal", "modifier")
AC(tt, "hps")
tt.hps.heal_every = 1
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update
tt.modifier.duration = 0.5
tt.modifier.vis_bans = 0

tt = RT("aura_ignus_skill_b", "aura")
tt.aura.cycles = 1
tt.aura.cycle_time = 0
tt.aura.damage_max = 90
tt.aura.damage_min = 48
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.duration = 1e+99
tt.aura.radius = 100
tt.aura.vis_bans = bor(F_FRIEND, F_HERO)
tt.aura.vis_flags = bor(F_AREA)
tt.main_script.update = aura_ignus_apply_damage_update

tt = RT("aura_ignus_ultimate", "aura")
tt.aura.cycle_time = 0.25
tt.aura.damage_max = 30
tt.aura.damage_min = 20
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.duration = 3
tt.aura.radius = 80
tt.aura.vis_bans = bor(F_FRIEND, F_HERO)
tt.aura.vis_flags = bor(F_AREA)
tt.main_script.update = aura_ignus_apply_damage_update

tt = RT("aura_ignus_talent_1", "aura")
tt.aura.cycle_time = 0.25
tt.aura.damage_max = 2
tt.aura.damage_min = 2
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.duration = 1e+99
tt.aura.hit_fx = "fx_ignus_talent_1_hit"
tt.aura.radius = 50
tt.aura.vis_bans = bor(F_FRIEND, F_HERO, F_FLYING)
tt.aura.vis_flags = bor(F_AREA)
tt.main_script.update = aura_ignus_apply_damage_update

tt = RT("fx_ignus_hit_basic_attack", "fx")
tt.render.sprites[1].name = "in"
tt.render.sprites[1].prefix = "ignus_multi_hit"
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("fx_ignus_hit", "fx")
tt.render.sprites[1].name = "in"
tt.render.sprites[1].prefix = "ignus_multi_hit"
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("fx_ignus_sparks_skill_a", "fx")
tt.render.sprites[1].name = "in"
tt.render.sprites[1].prefix = "ignus_multi_hit2"
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("fx_bullet_ignus_skill_a_hit", "fx")
tt.render.sprites[1].name = "in"
tt.render.sprites[1].prefix = "ignus_multi_explosion"
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("fx_ignus_talent_1_hit", "fx")
tt.render.sprites[1].name = "in"
tt.render.sprites[1].prefix = "ignus_multi_trail1"
tt.render.sprites[1].sort_y_offset = -19.5
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("decal_ignus_ground_skill_b", "decal_timed")
tt.render.sprites[1].name = "in"
tt.render.sprites[1].prefix = "ignus_multi_decal"
tt.timed.runs = 1

tt = RT("decal_ignus_fire_skill_c", "decal_timed")
tt.render.sprites[1].name = "in"
tt.render.sprites[1].prefix = "ignus_multi_fire_mask"
tt.timed.runs = 1

tt = RT("decal_ignus_hit_skill_c", "decal_scripted")
tt.damage_max = 84
tt.damage_min = 56
tt.damage_type = DAMAGE_TRUE
tt.hit_fx = "fx_ignus_hit"
tt.hit_offset = vec_2(20, 5)
tt.hit_time = fts(3)
tt.main_script.update = decal_ignus_hit_skill_c_update
tt.render.sprites[1].exo = true
tt.render.sprites[1].name = "in"
tt.render.sprites[1].prefix = "skill01Def"
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].z = Z_OBJECTS
tt.sound = "HeroIgnusFlameRushBounceHit"

tt = RT("decal_ignus_ground_ultimate", "decal_timed")
tt.render.sprites[1].name = "in"
tt.render.sprites[1].prefix = "ignus_multi_decal_fire"
tt.timed.runs = 1

tt = RT("decal_ignus_tombstone", "decal_tween")
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].name = "death_loop"
tt.render.sprites[1].prefix = "ignusDef"
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 0}, {fts(1), 0}}

tt = RT("bullet_ignus_skill_a", "bolt")
tt.bullet.align_with_trajectory = true
tt.bullet.damage_max = 60
tt.bullet.damage_min = 40
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.g = nil
tt.bullet.hit_fx = "fx_bullet_ignus_skill_a_hit"
tt.bullet.hit_fx_match_flip = true
tt.bullet.ignore_hit_offset = false
tt.bullet.max_speed = 600
tt.bullet.min_speed = 600
tt.bullet.particles_name = "ps_ignus_skill_a_trail"
tt.bullet.pop_chance = 0
tt.bullet.use_unit_damage_factor = true
tt.main_script.insert = bolt_ignus_skill_a_insert
tt.main_script.update = bolt_ignus_skill_a_update
tt.render.sprites[1].name = "in"
tt.render.sprites[1].prefix = "ignus_multi_projectil"
tt.render.sprites[1].z = Z_BULLETS
tt.sound_events.insert = nil
tt.sound_events.remove = "HeroIgnusFireballImpact"

tt = RT("bullet_ignus_skill_c", "bullet")
tt.bans = F_FLYING
tt.bounce_range = 120
tt.bullet.acceleration = 500
tt.bullet.damage_max = 0
tt.bullet.damage_min = 0
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.ignore_hit_offset = true
tt.bullet.max_speed = 1e+99
tt.bullet.min_speed = 0
tt.bullet.particles_name = "ps_ignus_skill_c_trail"
tt.bullet.payload = "decal_ignus_hit_skill_c"
tt.bullet.travel_time = fts(2)
tt.decal_return = "decal_ignus_fire_skill_c"
tt.main_script.update = bullet_ignus_skill_c_update
tt.max_hits = 3
tt.return_offset = vec_2(35, 40)

tt = RT("ps_ignus_skill_a_trail")
AC(tt, "pos", "particle_system")
tt.particle_system.emission_rate = 30
tt.particle_system.name = "ignus_multi_trail2_in"
tt.particle_system.particle_lifetime = {fts(6), fts(6)}
tt.particle_system.track_direction = true
tt.particle_system.track_rotation = true

tt = RT("ps_ignus_skill_c_trail")
AC(tt, "pos", "particle_system")
tt.particle_system.emit_area_spread = vec_2(4.5, 4.5)
tt.particle_system.emission_rate = 60
tt.particle_system.name = "ignus_multi_trail1_in"
tt.particle_system.particle_lifetime = {fts(18), fts(18)}
tt.particle_system.scale_var = {1, 1.5}
tt.particle_system.spin = {-5, 5}

tt = RT("ps_ignus_flywalk_trail")
AC(tt, "pos", "particle_system")
tt.particle_system.emit_area_spread = vec_2(4.5, 4.5)
tt.particle_system.emission_rate = 80
tt.particle_system.name = "ignus_multi_trail_fast_move_in"
tt.particle_system.particle_lifetime = {fts(14), fts(14)}
tt.particle_system.scale_var = {1, 1.5}
tt.particle_system.spin = {-5, 5}
tt.particle_system.z = Z_OBJECTS
