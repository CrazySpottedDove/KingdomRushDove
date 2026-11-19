local bit = require("bit")
local E = require("entity_db")
local P = require("path_db")
local scripts = require("scripts")
local S = require("sound_db")
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
local km = require("lib.klua.macros")

local function princess_fn_can_ulti(this, store, a, target)
	return target.health.hp >= a.target_min_hp and target.health.hp <= a.target_max_hp
end

local function princess_can_dodge(store, this, ranged_attack, attack, source)
	return this._t1_until > store.tick_ts or (math.random() <= this._dodge_chance)
end

local function princess_skill_c_has_targets(store, a, pi, ni)
	local ct = E:get_template(a.controller)
	local found = {}
	local count = 0

	for i = 0, ct.wave_count - 1 do
		local wni = ni - i * ct.nodes_between_waves

		if not P:is_node_valid(pi, wni, NF_NO_BACKWARDS) then
			break
		end

		local enemies = U.find_enemies_in_range(store, P:node_pos(pi, 1, wni), 0, ct.aura.radius, ct.aura.vis_flags, ct.aura.vis_bans)

		if enemies then
			for _, e in ipairs(enemies) do
				if not found[e.id] then
					found[e.id] = true
					count = count + 1

					if count >= a.min_targets then
						return true
					end
				end
			end
		end
	end

	return false
end

local function princess_y_skill_b(store, this, on_skill_used)
	local a = this.timed_attacks.list[1]
	local sb = this.hero.skills.skill_b
	local enemies = U.find_enemies_in_range(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

	if not enemies or #enemies < a.min_targets then
		SU.delay_attack(store, a, fts(10))

		return false
	end

	local names = a.sprite_names
	local order = {}

	for i = 1, #names do
		local j = math.random(1, i)

		order[i] = order[j]
		order[j] = i
	end

	a.ts = store.tick_ts

	SU.hero_gain_xp_from_skill(this, sb)
	on_skill_used(a.ts)

	local start_ts = store.tick_ts
	local original_flip_x = this.render.sprites[1].flip_x
	local flip_x = enemies[1].pos.x > this.pos.x

	U.animation_start(this, a.animation, flip_x, store.tick_ts, false)

	for i, st in ipairs(a.shoot_times) do
		if SU.y_hero_wait(store, this, st - (store.tick_ts - start_ts)) then
			U.animation_start(this, "idle", original_flip_x, store.tick_ts, true)

			return true
		end

		enemies = U.find_enemies_in_range(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

		if enemies then
			local target = enemies[math.random(1, #enemies)]
			local miss = math.random() < a.miss_chance
			local knife = E:create_entity(miss and a.miss_bullet or a.bullet)

			knife.render.sprites[1].name = names[order[(i - 1) % #names + 1]]
			knife.bullet.source_id = this.id
			knife.bullet.damage_min = sb.damage_min[sb.level] + this.unit.damage_buff
			knife.bullet.damage_max = sb.damage_max[sb.level] + this.unit.damage_buff
			knife.bullet.damage_factor = this.unit.damage_factor
			knife.bullet.from = V.v(this.pos.x + (flip_x and -1 or 1) * a.bullet_start_offset.x, this.pos.y + a.bullet_start_offset.y)

			if miss then
				local angle = math.random() * 2 * math.pi
				local dist = U.frandom(-a.miss_radius, a.miss_radius)

				knife.missed = true
				knife.bullet.to = V.v(target.pos.x + math.cos(angle) * dist, target.pos.y + math.sin(angle) * dist * 0.7)
				knife._shadow_to = V.vclone(knife.bullet.to)
			else
				knife.bullet.target_id = target.id
				knife.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
				knife._shadow_lift = V.vclone(target.unit.hit_offset)
			end

			knife._shadow_from = V.v(knife.bullet.from.x, this.pos.y)
			knife.pos = V.vclone(knife.bullet.from)

			simulation:queue_insert_entity(knife)
			S:queue(a.sound_shoot)

			local sh = E:create_entity(a.shadow)

			sh.pos = V.vclone(knife._shadow_from)
			sh.bullet_id = knife.id
			knife._shadow_id = sh.id

			simulation:queue_insert_entity(sh)
		end
	end

	local interrupted = SU.y_hero_animation_wait(this)

	U.animation_start(this, "idle", original_flip_x, store.tick_ts, true)

	return interrupted
end

local function princess_y_skill_c(store, this, on_skill_used)
	local a = this.timed_attacks.list[2]
	local sc = this.hero.skills.skill_c
	local flip_x, pi, ni, punch_pos

	if not this.soldier.target_id or this.motion.arrived then
		local here = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_NO_BACKWARDS)[1]

		if here and here[4] <= a.max_path_distance then
			local hpi, hni = here[1], here[3]
			local back_ni = hni - a.facing_nodes

			if P:is_node_valid(hpi, back_ni, NF_NO_BACKWARDS) then
				flip_x = P:node_pos(hpi, 1, back_ni).x < P:node_pos(hpi, 1, hni).x

				local px = this.pos.x + (flip_x and -1 or 1) * a.punch_offset.x
				local py = this.pos.y + a.punch_offset.y
				local punch = P:nearest_nodes(px, py, {hpi}, nil, true, NF_NO_BACKWARDS)[1]

				if punch and punch[4] <= a.max_path_distance and princess_skill_c_has_targets(store, a, punch[1], punch[3]) then
					pi, ni = punch[1], punch[3]
					punch_pos = V.v(px, py)
				end
			end
		end
	end

	if not pi then
		SU.delay_attack(store, a, fts(10))

		return false
	end

	a.ts = store.tick_ts

	SU.hero_gain_xp_from_skill(this, sc)
	on_skill_used(a.ts)
	U.animation_start(this, a.animation, flip_x, store.tick_ts, false)
	S:queue(a.sound, a.sound_args)
	S:queue(a.sound_hit, a.sound_hit_args)

	if SU.y_hero_wait(store, this, a.hit_time) then
		return true
	end

	local c = E:create_entity(a.controller)

	c.pos = punch_pos
	c.aura.source_id = this.id
	c.aura.damage_min = sc.damage_min[sc.level] + this.unit.damage_buff
	c.aura.damage_max = sc.damage_max[sc.level] + this.unit.damage_buff
	c.aura.damage_factor = this.unit.damage_factor
	c.wave_count = sc.wave_count[sc.level]
	c.path_pi = pi
	c.path_ni = ni

	simulation:queue_insert_entity(c)

	return SU.y_hero_animation_wait(this)
end

local function princess_level_up(this, store, initial)
	if not initial then
		S:queue(this.sound_events.level_up)
	end

	local hl, ls = level_up_basic(this)

	this._dodge_chance = ls.dodge_chance[hl]

	local t2 = this.hero.skills.talent_2
	local counter_factor = t2.damage_factor

	this.dodge.counter_attack.damage_min = counter_factor * ls.melee_damage_min[hl] * #this.melee.attacks[1].hit_times
	this.dodge.counter_attack.damage_max = counter_factor * ls.melee_damage_max[hl] * #this.melee.attacks[1].hit_times

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "talent_1", function(hero, skill)
		skill.disabled = nil
	end)

	upgrade_skill(this, "talent_2", function(hero, skill)
		skill.disabled = nil
	end)

	upgrade_skill(this, "skill_a", function(hero, skill)
		local a = this.melee.attacks[3]

		a.disabled = nil
		a.damage_min = skill.damage_min[skill.level]
		a.damage_max = skill.damage_max[skill.level]
	end)

	upgrade_skill(this, "skill_b", function(hero, skill)
		this.timed_attacks.list[1].disabled = nil
	end)

	upgrade_skill(this, "skill_c", function(hero, skill)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.cooldown = skill.cooldown[skill.level]
	end)

	upgrade_skill(this, "ultimate", function(hero, skill)
		this.melee.attacks[4].disabled = nil
	end)

	update_hp(this)
end

local function hero_princess_insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = {4, 3, 2, 1}

	return true
end

local function hero_princess_update(this, store)
	local h = this.health
	local brk, sta
	local old_tombstone_time = this.hero.tombstone_show_time
	local old_tombstone_respawn_animation = this.hero.tombstone_respawn_animation

	this.health_bar.hidden = false

	local t1 = not this.hero.skills.talent_1.disabled and this.hero.skills.talent_1 or nil

	this._t1_until = -1e+99

	local dodge_animation = this.dodge.animation

	local function on_skill_used(start_ts)
		if t1 then
			this._t1_until = math.max(this._t1_until, start_ts + t1.duration)
		end
	end

	local function silent_dodges_start()
		if not t1 then
			return
		end

		this.dodge.silent = true
		this.dodge.animation = nil
		this.dodge.time_before_hit = 0
	end

	local function silent_dodges_end()
		if not t1 then
			return
		end

		this.dodge.silent = nil
		this.dodge.animation = dodge_animation
		this.dodge.time_before_hit = nil
		this.dodge.active = false
	end

	local ult = this.melee.attacks[4]
	local skill_a = this.melee.attacks[3]

	ult.ts = store.tick_ts - ult.cooldown

	local ult_start_cd = not ult.disabled and store.wave_group_number == 0

	while true do
		if ult_start_cd and store.wave_group_number > 0 then
			ult_start_cd = false
			ult.ts = store.tick_ts
		end

		if h.dead then
			if band(h.last_damage_types, DAMAGE_EAT) ~= 0 then
				this.hero.tombstone_show_time = nil
				this.hero.tombstone_respawn_animation = nil
			end

			SU.y_hero_death_and_respawn(store, this)

			this.hero.tombstone_show_time = old_tombstone_time
			this.hero.tombstone_respawn_animation = old_tombstone_respawn_animation
			this.dodge.active = false
		end

		if this.unit.is_stunned then
			this.dodge.active = false

			SU.soldier_idle(store, this)
		else
			if this.dodge.active then
				this.dodge.ts = store.tick_ts

				local target = this.soldier.target_id and store.entities[this.soldier.target_id]

				if target and not target.health.dead then
					this._attacking = true

					SU.y_soldier_do_loopable_melee_attack(store, this, target, this.dodge.counter_attack)

					this._attacking = false
				else
					U.animation_start(this, this.dodge.animation, nil, store.tick_ts, false)
					S:queue(this.dodge.counter_attack.sound, this.dodge.counter_attack.sound_args)
					SU.y_hero_animation_wait(this)
				end

				this.dodge.active = false

				goto continue
			end

			if this.nav_rally.new then
				local rr = this.rally_run
				local walk_angles = this.render.sprites[1].angles.walk
				local running = V.dist(this.pos.x, this.pos.y, this.nav_rally.pos.x, this.nav_rally.pos.y) > rr.min_distance

				if running then
					U.unblock_target(store, this)

					U.bans_add(this.vis, F_ALL)

					U.y_animation_play(this, rr.animations[1], this.nav_rally.pos.x < this.pos.x, store.tick_ts)

					U.bans_remove(this.vis, F_ALL)
					U.speed_mul_self(this, rr.speed_factor)
					walk_angles[1] = rr.animations[2]
				end

				local dead = false

				while this.nav_rally.new do
					if SU.y_hero_new_rally(store, this) then
						dead = true

						break
					end
				end

				if running then
					U.speed_div_self(this, rr.speed_factor)
					walk_angles[1] = "walk"

					if not dead then
						U.bans_add(this.vis, F_ALL)

						U.y_animation_play(this, rr.animations[3], nil, store.tick_ts)

						U.bans_remove(this.vis, F_ALL)
					end
				end

				if dead then
					goto continue
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "lvlup", nil, store.tick_ts, 1)
			end

			if not this.soldier.target_id and ready_to_use_skill(this.timed_attacks.list[1], store, this.unit.cooldown_factor) then
				this._attacking = true

				local interrupted = princess_y_skill_b(store, this, on_skill_used)

				this._attacking = false

				if interrupted then
					goto continue
				end
			end

			if ready_to_use_skill(this.timed_attacks.list[2], store, this.unit.cooldown_factor) then
				this._attacking = true

				silent_dodges_start()

				local interrupted = princess_y_skill_c(store, this, on_skill_used)

				silent_dodges_end()

				this._attacking = false

				if interrupted then
					goto continue
				end
			end

			this._attacking = true

			silent_dodges_start()

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			silent_dodges_end()

			this._attacking = false

			if brk or sta ~= A_NO_TARGET then
			elseif SU.soldier_go_back_step(store, this) then
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::continue::

		coroutine.yield()
	end
end

local function ulti_lock_update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	local source = store.entities[m.source_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	local function target_gone()
		return store.entities[target.id] ~= target or target.health.dead
	end

	this.pos = target.pos

	U.animation_start(this, "loop", nil, store.tick_ts, true)

	local aura_spawned = false
	local cast_played = false

	while store.tick_ts - m.ts < m.duration do
		if target_gone() or not source or source.health.dead or source.unit.is_stunned then
			simulation:queue_remove_entity(this)

			return
		end

		if not cast_played and store.tick_ts - m.ts >= this.sound_cast_delay then
			cast_played = true

			S:queue(this.sound_cast)
		end

		if not aura_spawned and store.tick_ts - m.ts >= this.aura_delay then
			aura_spawned = true

			local au = E:create_entity(this.aura)

			au.pos = V.vclone(source.pos)
			au.aura.source_id = source.id
			au.aura.target_id = target.id
			au.aura.damage_min = au.aura.damage_min + source.unit.damage_buff
			au.aura.damage_max = au.aura.damage_max + source.unit.damage_buff
			au.aura.damage_factor = source.unit.damage_factor

			simulation:queue_insert_entity(au)
		end

		coroutine.yield()
	end

	if target_gone() or target.health.ignore_damage or U.has_modifier_types(store, target, MOD_TYPE_TELEPORT) then
		simulation:queue_remove_entity(this)

		return
	end

	S:queue(this.sound_hit, {
		delay = this.sound_hit_delay - (store.tick_ts - m.ts)
	})

	for _, s in ipairs(this.render.sprites) do
		s.hidden = true
	end

	U.bans_add(target.vis, F_ALL)

	target.ui.can_click = false
	target.ui.can_select = false
	target.health_bar.hidden = true
	target.unit.show_blood_pool = false
	target.unit.hide_during_death = true

	if target.sound_events then
		target.sound_events.death = nil
	end

	local dir = target.pos.x >= source.pos.x and 1 or -1
	local dx = 0
	local base_offsets = {}

	for i, s in ipairs(target.render.sprites) do
		base_offsets[i] = V.vclone(s.offset)
		s.z = Z_BULLETS
	end

	local center = target.unit.hit_offset.y
	local ps = E:create_entity(this.trail)

	ps.particle_system.track_id = target.id
	ps.particle_system.track_offset = V.v(0, target.unit.hit_offset.y)

	simulation:queue_insert_entity(ps)

	local start_ts = store.tick_ts
	local h = 0

	while store.tick_ts - start_ts < this.throw_flight_time / 2 and not target_gone() do
		coroutine.yield()

		local u = km.clamp(0, 0.5, (store.tick_ts - start_ts) / this.throw_flight_time)

		h = 4 * this.throw_height * u * (1 - u)
		dx = dir * this.throw_distance * u

		local r = -dir * this.spin_speed * (store.tick_ts - start_ts)

		for i, s in ipairs(target.render.sprites) do
			s.r = r
			s.offset.x = base_offsets[i].x + dx + center * math.sin(r)
			s.offset.y = base_offsets[i].y + h + center * (1 - math.cos(r))
		end

		ps.particle_system.track_offset.x = dx
		ps.particle_system.track_offset.y = target.unit.hit_offset.y + h
	end

	local fx = E:create_entity(this.explosion_fx)

	fx.pos = V.v(target.pos.x + dx, target.pos.y + target.unit.hit_offset.y + h)
	fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(fx)
	S:queue(this.sound_explosion)

	ps.particle_system.emit = false
	ps.particle_system.source_lifetime = 0

	U.sprites_hide(target, nil, nil, true)

	local d = E:create_entity("damage")

	d.damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_FX_NOT_EXPLODE, DAMAGE_NO_SPAWNS, DAMAGE_IGNORE_SHIELD)
	d.source_id = m.source_id
	d.target_id = target.id

	queue_damage(store, d)
	simulation:queue_remove_entity(this)
end

local function skill_c_controller_update(this, store)
	local a = this.aura
	local pi, ni = this.path_pi, this.path_ni

	if pi and ni then
		local hit_ids = {}

		for i = 0, this.wave_count - 1 do
			local wni = ni - i * this.nodes_between_waves

			if not P:is_node_valid(pi, wni, NF_NO_BACKWARDS) then
				break
			end

			local pos = P:node_pos(pi, 1, wni)
			local flip_x = P:node_pos(pi, 1, math.max(wni - 1, 1)).x < pos.x
			local vpos

			if i == 0 then
				vpos = V.vclone(this.pos)
			else
				local j = this.wave_pos_jitter

				vpos = V.v(pos.x + U.frandom(-j.x, j.x), pos.y + U.frandom(-j.y, j.y))
			end

			local fx = E:create_entity(this.fx_blast)

			fx.pos = vpos
			fx.render.sprites[1].flip_x = flip_x
			fx.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(fx)

			local d = E:create_entity(this.decal)

			d.pos = V.vclone(vpos)
			d.render.sprites[1].flip_x = flip_x
			d.render.sprites[1].ts = store.tick_ts
			d.tween.ts = store.tick_ts

			simulation:queue_insert_entity(d)

			local enemies = U.find_enemies_in_range(store, pos, 0, a.radius, a.vis_flags, a.vis_bans)

			if enemies then
				for _, e in ipairs(enemies) do
					if not hit_ids[e.id] then
						hit_ids[e.id] = true

						local dmg = E:create_entity("damage")

						dmg.damage_type = a.damage_type
						dmg.value = math.random(a.damage_min, a.damage_max) * a.damage_factor
						dmg.source_id = a.source_id
						dmg.target_id = e.id

						queue_damage(store, dmg)

						local hfx = E:create_entity(this.fx_hit)

						hfx.pos = V.v(e.pos.x + e.unit.hit_offset.x, e.pos.y + e.unit.hit_offset.y)
						hfx.render.sprites[1].ts = store.tick_ts

						simulation:queue_insert_entity(hfx)
					end
				end
			end

			U.y_wait(store, this.wave_delay)
		end
	end

	simulation:queue_remove_entity(this)
end

local function skill_b_shadow_update(this, store)
	local s = this.render.sprites[1]
	local base_scale = s.scale.x

	while true do
		local e = store.entities[this.bullet_id]

		if not e then
			break
		end

		local b = e.bullet
		local t = km.clamp(0, 1, (store.tick_ts - b.ts) / b.flight_time)
		local to_x = e._shadow_to and e._shadow_to.x or b.to.x - e._shadow_lift.x
		local to_y = e._shadow_to and e._shadow_to.y or b.to.y - e._shadow_lift.y

		this.pos.x = e._shadow_from.x + (to_x - e._shadow_from.x) * t
		this.pos.y = e._shadow_from.y + (to_y - e._shadow_from.y) * t

		local height = e.pos.y - this.pos.y

		s.scale = V.vv(base_scale * (height > 0 and km.clamp(0.6, 1, 40 / height) or 1))
		s.hidden = e.render.sprites[1].hidden

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function skill_b_miss_insert(this, store)
	local b = this.bullet

	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts

	local sh = E:create_entity(this.shadow)

	sh.pos = V.vclone(this._shadow_from)
	sh.bullet_id = this.id
	this._shadow_id = sh.id

	simulation:queue_insert_entity(sh)

	return true
end

local function skill_b_miss_update(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local ps = E:create_entity(b.particles_name)

	ps.particle_system.track_id = this.id

	simulation:queue_insert_entity(ps)

	local dir = b.to.x > b.from.x and 1 or -1

	for bounce = 0, 1 do
		while store.tick_ts - b.ts + store.tick_length < b.flight_time do
			coroutine.yield()

			this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)
			s.r = s.r + b.rotation_speed * store.tick_length
		end

		this.pos.x, this.pos.y = b.to.x, b.to.y

		if bounce == 0 then
			ps.particle_system.emit = false
			b.from = V.vclone(b.to)
			b.to = V.v(b.to.x + dir * this.bounce_distance, b.to.y)
			b.flight_time = this.bounce_flight_time
			b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
			b.ts = store.tick_ts
			this._shadow_from = V.vclone(b.from)
			this._shadow_to = V.vclone(b.to)
		end
	end

	local d = E:create_entity(this.rest_decal)

	d.pos = V.vclone(this.pos)
	d.render.sprites[2].name = s.name
	d.render.sprites[2].r = s.r
	d.render.sprites[2].flip_x = s.flip_x
	d.tween.ts = store.tick_ts

	simulation:queue_insert_entity(d)

	local sh = store.entities[this._shadow_id]

	if sh then
		sh.render.sprites[1].hidden = true

		simulation:queue_remove_entity(sh)
	end

	simulation:queue_remove_entity(this)
end

local tt

tt = RT("hero_princess", "hero")
AC(tt, "melee", "timed_attacks", "dodge")
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {200, 211, 222, 233, 244, 256, 267, 278, 289, 300}
tt.hero.level_stats.melee_damage_min = {5, 6, 7, 8, 9, 10, 13, 14, 15, 16}
tt.hero.level_stats.melee_damage_max = {7, 8, 9, 10, 13, 14, 15, 16, 17, 18}
tt.hero.level_stats.dodge_chance = {0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9}
tt.hero.skills.skill_a = CC("hero_skill")
tt.hero.skills.skill_a.damage_min = {17, 32, 48}
tt.hero.skills.skill_a.damage_max = {24, 45, 70}
tt.hero.skills.skill_a.damage_type = DAMAGE_MAGICAL
tt.hero.skills.skill_a.cooldown = 10
tt.hero.skills.skill_a.xp_gain = {80, 160, 240}
tt.hero.skills.skill_a.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.skill_b = CC("hero_skill")
tt.hero.skills.skill_b.damage_min = {22, 46, 69}
tt.hero.skills.skill_b.damage_max = {36, 66, 100}
tt.hero.skills.skill_b.damage_type = DAMAGE_PHYSICAL
tt.hero.skills.skill_b.cooldown = 10
tt.hero.skills.skill_b.range = 200
tt.hero.skills.skill_b.min_targets = 2
tt.hero.skills.skill_b.xp_gain = {90, 180, 270}
tt.hero.skills.skill_b.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.skill_c = CC("hero_skill")
tt.hero.skills.skill_c.damage_min = {54, 65, 89}
tt.hero.skills.skill_c.damage_max = {82, 99, 128}
tt.hero.skills.skill_c.damage_type = DAMAGE_EXPLOSION
tt.hero.skills.skill_c.cooldown = {16, 14, 12}
tt.hero.skills.skill_c.wave_count = {4, 5, 6}
tt.hero.skills.skill_c.xp_gain = {90, 180, 270}
tt.hero.skills.skill_c.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.level = 1
tt.hero.skills.ultimate.cooldown = 25
tt.hero.skills.ultimate.damage_min = 9
tt.hero.skills.ultimate.damage_max = 13
tt.hero.skills.ultimate.target_min_hp = 100
tt.hero.skills.ultimate.target_max_hp = 2000
tt.hero.skills.ultimate.xp_gain = {250}
tt.hero.skills.ultimate.xp_level_steps = {
	[5] = 1
}
tt.hero.skills.talent_1 = CC("hero_skill")
tt.hero.skills.talent_1.duration = 2.5
tt.hero.skills.talent_1.disabled = true
tt.hero.skills.talent_1.xp_level_steps = {
	[1] = 1
}
tt.hero.skills.talent_2 = CC("hero_skill")
tt.hero.skills.talent_2.damage_factor = 2
tt.hero.skills.talent_2.disabled = true
tt.hero.skills.talent_2.xp_level_steps = {
	[1] = 1
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 44)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.ui.click_rect = r(-19, -5, 38, 43)
tt.hero.fn_level_up = princess_level_up
tt.hero.respawn_animation = "revive"
tt.hero.tombstone_decal = "decal_princess_tombstone"
tt.hero.tombstone_show_time = fts(78)
tt.hero.tombstone_concurrent_with_death = true
tt.hero.tombstone_remove_before_respawn = true
tt.unit.hide_after_death = true
tt.info.i18n_key = "HERO_PRINCESS"
tt.info.hero_portrait = "kr6_hero_portraits_0014"
tt.info.portrait = "kr6_info_portraits_heroes_0020"
tt.main_script.insert = hero_princess_insert
tt.main_script.update = hero_princess_update
tt.motion.max_speed = 70
tt.regen.cooldown = 1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].prefix = "hero_princessDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = DO_HEROES
tt.render.sprites[1].scale = V.vv(1.1)
tt.sound_events.change_rally_point = "HeroDaliaTaunt"
tt.sound_events.death = "HeroDaliaTauntDeath"
tt.sound_events.respawn = "HeroDaliaTauntIntro"
tt.sound_events.hero_room_select = "HeroDaliaTauntSelect"
tt.sound_events.level_up = "HeroDaliaTauntLevelUp"
tt.soldier.melee_slot_offset = vec_2(0, 0)
tt.unit.hit_offset = vec_2(0, 13.2)
tt.unit.marker_offset = vec_2(0, -1)
tt.unit.mod_offset = vec_2(0, 21.89)
tt.unit.pop_offset = vec_2(0, 16.5)
tt.dodge.chance = 1
tt.dodge.animation = "dodge"
tt.dodge.show_pop = true
tt.dodge.can_dodge = princess_can_dodge
tt.dodge.counter_attack = CC("melee_attack")
tt.dodge.counter_attack.animations = {nil, "dodge"}
tt.dodge.counter_attack.loops = 1
tt.dodge.counter_attack.hit_times = {fts(21), fts(22)}
tt.dodge.counter_attack.damage_type = DAMAGE_PHYSICAL
tt.dodge.counter_attack.vis_bans = bor(F_CLIFF)
tt.dodge.counter_attack.vis_flags = F_BLOCK
tt.dodge.counter_attack.xp_gain_factor = 1.75
tt.dodge.counter_attack.hit_fx = "fx_princess_hit_critical"
tt.dodge.counter_attack.hit_offset = vec_2(33, 16.5)
tt.dodge.counter_attack.ignore_rally_change = true
tt.dodge.counter_attack.sound = "HeroDaliaDodgeStrikeCast"
tt.dodge.counter_attack.sound_args = {
	delay = fts(1)
}
tt.dodge.ranged = true
tt.rally_run = {}
tt.rally_run.animations = {"run_in", "run", "run_out"}
tt.rally_run.min_distance = 100
tt.rally_run.speed_factor = 1.5
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animations = {nil, "attack_a"}
tt.melee.attacks[1].loops = 1
tt.melee.attacks[1].hit_times = {fts(14), fts(17), fts(21), fts(24), fts(27), fts(31), fts(34)}
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].cooldown = 3.5
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound_hit = "HeroDaliaBasicAttackCast"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 1.6
tt.melee.attacks[1].interrupt_on_dead_target = true
tt.melee.attacks[1].interrupt_loop_on_dead_target = true
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animations = {nil, "attack_b"}
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[3] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[3].animations = {nil, "skill_1"}
tt.melee.attacks[3].hit_times = {fts(21), fts(23), fts(25)}
tt.melee.attacks[3].damage_type = DAMAGE_MAGICAL
tt.melee.attacks[3].cooldown = 10
tt.melee.attacks[3].sound = "HeroDaliaRegalFistCast"
tt.melee.attacks[3].sound_args = {
	delay = fts(5)
}
tt.melee.attacks[3].sound_hit = nil
tt.melee.attacks[3].shared_cooldown = nil
tt.melee.attacks[3].xp_gain_factor = nil
tt.melee.attacks[3].xp_from_skill = "skill_a"
tt.melee.attacks[3].interrupt_on_dead_target = nil
tt.melee.attacks[3].interrupt_loop_on_dead_target = nil
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].side_effect = function(this, store, damage, target)
	this._t1_until = store.tick_ts + this.hero.skills.talent_1.duration
end
tt.melee.attacks[4] = CC("melee_attack")
tt.melee.attacks[4].animation = "ulti"
tt.melee.attacks[4].hit_time = 0
tt.melee.attacks[4].damage_min = 0
tt.melee.attacks[4].damage_max = 0
tt.melee.attacks[4].damage_type = bor(DAMAGE_NONE, DAMAGE_NO_DODGE)
tt.melee.attacks[4].cooldown = 25
tt.melee.attacks[4].mod = "mod_princess_ulti_lock"
tt.melee.attacks[4].sound = "HeroDaliaTauntUltimate"
tt.melee.attacks[4].ignore_rally_change = true
tt.melee.attacks[4].vis_flags = bor(F_BLOCK, F_STUN, F_INSTAKILL)
tt.melee.attacks[4].vis_bans = bor(F_CLIFF, F_BOSS, F_MINIBOSS)
tt.melee.attacks[4].target_min_hp = 100
tt.melee.attacks[4].target_max_hp = 1500
tt.melee.attacks[4].fn_can = princess_fn_can_ulti
tt.melee.attacks[4].side_effect = tt.melee.attacks[3].side_effect
tt.melee.attacks[4].xp_from_skill = "ultimate"
tt.melee.attacks[4].disabled = true
tt.melee.cooldown = 3.5
tt.melee.range = 60
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].animation = "skill_2"
tt.timed_attacks.list[1].cooldown = 10
tt.timed_attacks.list[1].range = 200
tt.timed_attacks.list[1].min_targets = 2
tt.timed_attacks.list[1].shoot_times = {fts(12), fts(22), fts(32), fts(42), fts(52)}
tt.timed_attacks.list[1].bullet = "bullet_princess_skill_b"
tt.timed_attacks.list[1].miss_bullet = "bullet_princess_skill_b_miss"
tt.timed_attacks.list[1].shadow = "decal_princess_skill_b_shadow"
tt.timed_attacks.list[1].miss_chance = 0
tt.timed_attacks.list[1].miss_radius = 20
tt.timed_attacks.list[1].bullet_start_offset = vec_2(5.5, 31.9)
tt.timed_attacks.list[1].sound_shoot = "HeroDaliaCrammedPurseCast"
tt.timed_attacks.list[1].sprite_names = {"hero_princess_vfx_proyectil_bolso_1", "hero_princess_vfx_proyectil_bolso_2", "hero_princess_vfx_proyectil_bolso_3", "hero_princess_vfx_proyectil_bolso_4", "hero_princess_vfx_proyectil_bolso_5"}
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].vis_bans = 0
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].animation = "skill_3"
tt.timed_attacks.list[2].hit_time = fts(41)
tt.timed_attacks.list[2].sound = "HeroDaliaDiamondDropCast"
tt.timed_attacks.list[2].sound_args = {
	delay = fts(23)
}
tt.timed_attacks.list[2].sound_hit = "HeroDaliaDiamondDropHit"
tt.timed_attacks.list[2].sound_hit_args = {
	delay = fts(39)
}
tt.timed_attacks.list[2].cooldown = 16
tt.timed_attacks.list[2].min_targets = 3
tt.timed_attacks.list[2].controller = "controller_princess_skill_c"
tt.timed_attacks.list[2].punch_offset = vec_2(27.5, 0)
tt.timed_attacks.list[2].max_path_distance = 50
tt.timed_attacks.list[2].facing_nodes = 3

tt = RT("decal_princess_tombstone", "decal")
tt.render.sprites[1].prefix = "hero_princessDef"
tt.render.sprites[1].name = "death_idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].scale = V.vv(1.1)

tt = RT("mod_princess_ulti_lock", "mod_stun")
tt.main_script.update = ulti_lock_update
tt.modifier.duration = fts(86)
tt.modifier.vis_flags = bor(F_MOD, F_STUN, F_INSTAKILL)
tt.modifier.vis_bans = bor(F_BOSS, F_MINIBOSS)
tt.aura = "aura_princess_ulti"
tt.aura_delay = fts(41)
tt.throw_distance = 320
tt.throw_height = 180
tt.throw_flight_time = fts(40)
tt.spin_speed = 4 * math.pi
tt.trail = "ps_princess_ulti_trail"
tt.explosion_fx = "fx_princess_ulti_explosion"
tt.sound_cast = "HeroDaliaCrowningSlashesCast"
tt.sound_cast_delay = fts(39)
tt.sound_hit = "HeroDaliaCrowningSlashesHit"
tt.sound_hit_delay = fts(88)
tt.sound_explosion = "HeroDaliaCrowningSlashesExplosion"

tt = RT("aura_princess_ulti", "aura")
tt.main_script.update = scripts.aura_apply_damage.update
tt.aura.track_source = true
tt.aura.cycle_time = fts(3)
tt.aura.cycles = 8
tt.aura.radius = 70
tt.aura.damage_min = 9
tt.aura.damage_max = 13
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)

tt = RT("controller_princess_skill_c", "aura")
tt.main_script.update = skill_c_controller_update
tt.aura.damage_type = DAMAGE_EXPLOSION
tt.aura.radius = 40
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.wave_count = 4
tt.nodes_between_waves = 6
tt.wave_delay = fts(2)
tt.wave_pos_jitter = vec_2(8, 6)
tt.fx_blast = "fx_princess_skill_c_blast"
tt.fx_hit = "fx_princess_skill_c_hit"
tt.decal = "decal_princess_skill_c"
tt.path_pi = nil
tt.path_ni = nil

tt = RT("bullet_princess_skill_b", "arrow")
tt.render.sprites[1].name = "hero_princess_vfx_proyectil_bolso_1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = V.vv(1.1)
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.flight_time = fts(22)
tt.bullet.particles_name = "ps_princess_skill_b_trail"
tt.bullet.hit_fx = "fx_princess_skill_b_hit"
tt.bullet.hit_blood_fx = nil
tt.bullet.miss_decal = nil
tt.bullet.pop = nil
tt.bullet.hide_radius = nil
tt.bullet.rotation_speed = 10
tt.sound_events.insert = nil

tt = RT("bullet_princess_skill_b_miss", "bullet_princess_skill_b")
tt.main_script.insert = skill_b_miss_insert
tt.main_script.update = skill_b_miss_update
tt.bullet.flight_time = fts(8)
tt.bullet.g = -1000
tt.bounce_distance = 25
tt.bounce_flight_time = fts(10)
tt.drop_flight_time = fts(8)
tt.rest_decal = "decal_princess_skill_b_bag"
tt.shadow = "decal_princess_skill_b_shadow"

tt = RT("decal_princess_skill_b_shadow", "decal_scripted")
tt.render.sprites[1].name = "hero_princess_vfx_proyectil_bolso_sombra"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = V.vv(1.1)
tt.main_script.update = skill_b_shadow_update

tt = RT("decal_princess_skill_b_bag", "decal_tween")
tt.render.sprites[1].name = "hero_princess_vfx_proyectil_bolso_sombra"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = V.vv(1.1)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "hero_princess_vfx_proyectil_bolso_1"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = tt.render.sprites[1].z
tt.render.sprites[2].scale = V.vv(1.1)
tt.tween.props[1].keys = {{0, 255}, {fts(60), 255}, {fts(75), 0}}

tt = RT("decal_princess_skill_c", "decal_tween")
tt.render.sprites[1].name = "hero_princess_vfx_skill_3_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = V.vv(1.1)
tt.tween.props[1].keys = {{0, 255}, {fts(45), 255}, {fts(75), 0}}

tt = RT("fx_princess_hit_critical", "fx")
tt.render.sprites[1].prefix = "hero_princess_vfx_hit_critical"
tt.render.sprites[1].name = "action"
tt.render.sprites[1].scale = V.vv(1.1)

tt = RT("fx_princess_skill_b_hit", "fx")
tt.render.sprites[1].prefix = "hero_princess_vfx_proyectil_bolso_hit"
tt.render.sprites[1].name = "action"
tt.render.sprites[1].scale = V.vv(1.1)

tt = RT("fx_princess_ulti_explosion", "fx")
tt.render.sprites[1].prefix = "hero_princess_vfx_ulti_explosion"
tt.render.sprites[1].name = "action"
tt.render.sprites[1].scale = V.vv(1.1)

tt = RT("fx_princess_skill_c_blast", "fx")
tt.render.sprites[1].prefix = "hero_princess_vfx_skill_3_blast"
tt.render.sprites[1].name = "action"
tt.render.sprites[1].scale = V.vv(1.1)

tt = RT("fx_princess_skill_c_hit", "fx")
tt.render.sprites[1].prefix = "hero_princess_vfx_skill_3_hit"
tt.render.sprites[1].name = "action"
tt.render.sprites[1].scale = V.vv(1.1)

tt = RT("ps_princess_ulti_trail", "particle_system")
tt.particle_system.name = "hero_princess_vfx_ulti_trail_enemies"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 15
tt.particle_system.emit_area_spread = vec_2(8.8, 8.8)
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.scale_var = {0.825, 1.1}

tt = RT("ps_princess_skill_b_trail", "particle_system")
tt.particle_system.name = "hero_princess_vfx_proyectil_bolso_trail"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.particle_lifetime = {fts(16), fts(16)}
tt.particle_system.emission_rate = 35
tt.particle_system.track_rotation = true
tt.particle_system.emit_area_spread = vec_2(4.4, 4.4)
tt.particle_system.scales_x = {1.21}
tt.particle_system.scales_y = {1.21}
