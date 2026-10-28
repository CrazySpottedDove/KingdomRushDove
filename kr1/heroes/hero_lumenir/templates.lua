local E = require("entity_db")
local GR = require("grid_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local UP = require("kr1.upgrades")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local bit = require("bit")
local km = require("lib.klua.macros")
local log = require("lib.klua.log"):new("hero_scripts")
local apply_ultimate = HU.apply_ultimate
local band = bit.band
local bor = bit.bor
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local tt

local function hero_lumenir_ultimate_update(this, store)
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_POWER_3)

	if #nodes < 1 then
		log.error("hero_lumenir_ultimate: could not find valid node")
		simulation:queue_remove_entity(this)

		return
	end

	local node = {
		spi = 1,
		pi = nodes[1][1],
		ni = nodes[1][3]
	}

	P:node_pos(node.pi, node.spi, node.ni)

	local count = this.count
	local target, targets = U.find_nearest_enemy(store, this.pos, 0, this.range, this.vis_flags, this.vis_bans)
	local idx = 1

	if targets and count > #targets then
		count = #targets
	end

	while count > 0 and targets do
		local e = E:create_entity(this.entity)

		target = targets[idx]
		idx = idx + 1

		if band(target.vis.bans, F_STUN) == 0 and band(target.vis.flags, F_BOSS) == 0 then
			local m = E:create_entity("mod_lumenir_ulti_stun")

			m.modifier.target_id = target.id
			m.modifier.source_id = this.id

			simulation:queue_insert_entity(m)
		end

		if band(target.vis.flags, F_BLOCK) ~= 0 then
			U.block_enemy(store, e, target)
		else
			e.unblocked_target_id = target.id
		end

		local lpos, lflip = U.melee_slot_position(e, target, 1)

		e.pos.x, e.pos.y = lpos.x, lpos.y
		e.render.sprites[1].flip_x = lflip
		e.nav_rally.center = V.vclone(e.pos)
		e.nav_rally.pos = V.vclone(e.pos)

		simulation:queue_insert_entity(e)

		count = count - 1

		U.y_wait_unconditional(store, this.spawn_delay)
	end

	count = this.count

	if targets then
		count = count - #targets
	end

	local available_paths = {}

	for k, v in pairs(P.paths) do
		table.insert(available_paths, k)
	end

	if store.level.ignore_walk_backwards_paths then
		available_paths = table.filter(available_paths, function(k, v)
			return not table.contains(store.level.ignore_walk_backwards_paths, v)
		end)
	end

	local nearest = P:nearest_nodes(this.pos.x, this.pos.y, available_paths)

	if nearest and #nearest > 0 then
		local path_pi, _, path_ni = unpack(nearest[1])
		local spi = {1, 3, 2}

		while count > 0 do
			local ni_random = math.random(-5, 5)
			local spi_random = spi[count % 3 + 1]
			local pos_spawn = P:node_pos(path_pi, spi_random, path_ni + ni_random)
			local e = E:create_entity(this.entity)

			e.pos.x, e.pos.y = pos_spawn.x, pos_spawn.y
			e.render.sprites[1].flip_x = math.random() > 0.5
			e.nav_rally.center = V.vclone(e.pos)
			e.nav_rally.pos = V.vclone(e.pos)

			simulation:queue_insert_entity(e)
			U.y_wait_unconditional(store, this.spawn_delay)

			count = count - 1
		end
	end

	simulation:queue_remove_entity(this)
end

local function hero_lumenir_level_up(this, store, initial)
	local hl, ls = level_up_basic(this)
	local b = E:get_template(this.ranged.attacks[1].bullet)

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	local b = E:get_template("bolt_lumenir_mini_death")

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	upgrade_skill(this, "shield", function(this, s)
		local a = this.ranged.attacks[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local m = E:get_template(a.mod)

		m.spiked_armor = s.spiked_armor[s.level]
		m.armor = s.armor[s.level]
		m.modifier.duration = s.duration[s.level]
	end)
	upgrade_skill(this, "celestial_judgement", function(this, s)
		local a = this.ranged.attacks[3]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
	end)
	upgrade_skill(this, "mini_dragon", function(this, s)
		local a = this.ranged.attacks[4]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.duration = s.duration[s.level]

		local b = E:get_template("bolt_lumenir_mini")

		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "fire_balls", function(this, s)
		local a = this.ranged.attacks[5]

		a.cooldown = s.cooldown[s.level]
		a.disabled = nil
		a.count = s.flames_count[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		local u = this.ultimate

		u.disabled = nil

		local uc = E:get_template(s.controller_name)

		uc.cooldown = s.cooldown[s.level]
		uc.count = s.count[s.level]

		local soldier = E:get_template(uc.entity)

		soldier.melee.attacks[1].damage_max = s.damage_max[s.level]
		soldier.melee.attacks[1].damage_min = s.damage_min[s.level]
		soldier.max_attack_count = s.max_attack_count
	end)
	update_hp(this)
end

local function hero_lumenir_update(this, store)
	local h = this.health
	local a
	local basic_ranged = this.ranged.attacks[1]
	local shield_attack = this.ranged.attacks[2]
	local celestial_judgement_attack = this.ranged.attacks[3]
	local mini_dragon_attack = this.ranged.attacks[4]
	local fire_balls_attack = this.ranged.attacks[5]

	UP:get_upgrade("heroes_lethal_focus")

	local function find_hero()
		for _, e in pairs(store.soldiers) do
			if e.hero and e.template_name ~= "hero_lumenir" then
				return e
			end
		end

		return nil
	end

	local function create_mini_dragon(follow, entity_t, duration, remove_hero_death)
		local d = E:create_entity(entity_t)

		d.pos = V.vclone(follow.pos)
		d.ranged.attacks[1].xp_dest_id = this.id
		d.owner = this
		d.hero_id = follow.id
		d.duration = duration
		d.remove_hero_death = remove_hero_death

		simulation:queue_insert_entity(d)

		return d
	end

	this.tween.disabled = false
	this.tween.ts = store.tick_ts
	this.health_bar.hidden = false

	U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

	while true do
		if h.dead then
			S:queue(mini_dragon_attack.sound)

			local time_adjustement = 1
			local d1 = create_mini_dragon(this, this.mini_dragon, this.health.dead_lifetime - time_adjustement, false)

			d1.offset.x = 40
			d1.offset.y = 10
			d1.delay_creation = 0.2

			local d2 = create_mini_dragon(this, this.mini_dragon, this.health.dead_lifetime - time_adjustement, false)

			d2.offset.x = -40
			d2.offset.y = -10
			d2.delay_creation = 0.3
			this.tween.disabled = false
			this.tween.ts = store.tick_ts
			this.tween.reverse = true

			SU.y_hero_death_and_respawn(store, this)

			this.tween.disabled = false
			this.tween.ts = store.tick_ts
			this.tween.reverse = false

			U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
		end

		while this.nav_rally.new do
			SU.y_hero_new_rally(store, this)
		end

		if SU.hero_level_up(store, this) then
			U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
		end

		a = this.ultimate

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			local target = U.detect_foremost_enemy_in_range_filter_off(this.pos, basic_ranged.max_range, F_RANGED, F_NONE)

			if target and U.has_valid_rally_node_nearby(target.pos) then
				apply_ultimate(this, store, target.pos, "levelup")
			else
				a.ts = a.ts + 1
			end
		end

		a = shield_attack

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			if store.wave_group_number > 0 then
				local soldiers = U.find_soldiers_in_range(store.soldiers, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

				if not soldiers or #soldiers <= a.min_count then
					a.ts = a.ts + fts(10)
				else
					local middle = 0
					local damaged = false

					for _, s in ipairs(soldiers) do
						middle = middle + s.pos.x

						if s.health and s.health.hp < s.health.hp_max then
							damaged = true
						end
					end

					if not damaged then
					-- block empty
					else
						middle = middle / #soldiers

						S:queue(a.sound)
						U.animation_start_default(this, a.animation, middle - this.pos.x < 0, store.tick_ts)
						U.y_wait_unconditional(store, a.shoot_time)

						for _, s in ipairs(soldiers) do
							local m = E:create_entity(a.mod)

							m.modifier.target_id = s.id
							m.modifier.source_id = this.id

							simulation:queue_insert_entity(m)
						end

						U.y_animation_wait_default(this)

						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
					end
				end
			end
		end

		a = celestial_judgement_attack

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			local target = U.find_biggest_enemy_in_range_filter_off(this.pos, a.range, a.vis_flags, a.vis_bans)

			if target then
				local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

				S:queue(a.sound)

				a.ts = store.tick_ts

				U.animation_start_default(this, an, af, store.tick_ts)
				U.y_wait_unconditional(store, a.shoot_time)

				local m = E:create_entity(a.mod)

				m.modifier.damage_factor = this.unit.damage_factor
				m.modifier.target_id = target.id
				m.modifier.source_id = this.id
				m.modifier.level = this.hero.skills.celestial_judgement.level

				simulation:queue_insert_entity(m)
				U.y_animation_wait_default(this)
				SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
			else
				a.ts = a.ts + fts(10)
			end

			goto label_411_1
		end

		a = mini_dragon_attack

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			if store.wave_group_number > 0 then
				local hero = find_hero()

				if hero and hero.health and not hero.health.dead then
					S:queue(a.sound)
					create_mini_dragon(hero, a.entity, a.duration, true)

					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
				end
			end
		end

		a = fire_balls_attack

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			local targets_info = U.find_enemies_in_paths(store.enemies, this.pos, a.range_nodes_min, a.range_nodes_max, nil, a.vis_flags, a.vis_bans)

			if not targets_info or #targets_info < a.min_targets then
				a.ts = a.ts + 0.4

				goto label_411_2
			end

			local target

			for _, ti in ipairs(targets_info) do
				if GR:cell_is(ti.enemy.pos.x, ti.enemy.pos.y, TERRAIN_LAND) then
					target = ti.enemy

					break
				end
			end

			if not target then
				a.ts = a.ts + 0.4

				goto label_411_2
			end

			local pi, _, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
			local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {pi}, nil, nil, NF_RALLY)

			if #nodes < 1 then
				a.ts = a.ts + 0.4

				goto label_411_2
			end

			local s_pi, s_spi, s_ni = unpack(nodes[1])
			local dir = ni < s_ni and -1 or 1
			local offset = math.random(a.range_nodes_min, a.range_nodes_min + 5)

			s_ni = km.clamp(1, #P:path(s_pi), s_ni + (dir > 0 and offset or -offset))

			local flip = P:node_pos(s_pi, s_spi, s_ni, true).x < this.pos.x

			S:queue(a.sound)
			U.animation_start_default(this, a.animation, flip, store.tick_ts)
			U.y_wait_unconditional(store, a.spawn_time)

			local delay = 0
			local pattern = {1, 2, 3, 2, 3, 1, 2}

			for i = 1, a.count do
				delay = delay + math.random(0.5, 0.66)

				local e = E:create_entity(a.entity)

				e.pos.x, e.pos.y = this.pos.x + (flip and -1 or 1) * a.spawn_offset.x, this.pos.y + a.spawn_offset.y
				e.nav_path.pi = s_pi
				e.nav_path.spi = pattern[i % #pattern + 1]
				e.nav_path.ni = s_ni
				e.nav_path.dir = dir
				e.delay = delay
				e.aura.source_id = this.id
				e.aura.damage_factor = this.unit.damage_factor
				e.level = this.hero.skills.fire_balls.level

				simulation:queue_insert_entity(e)
			end

			U.y_animation_wait_default(this)

			a.ts = store.tick_ts

			SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])

			goto label_411_2
		end

		a = basic_ranged

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			-- local pos_offset = v(this.pos.x + a.ignore_offset.x, this.pos.y + a.ignore_offset.y)
			local targets = U.find_enemies_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

			if targets then
				local target = targets[1]
				local start_ts = store.tick_ts
				local start_fx, b
				local node_offset = P:predict_enemy_node_advance(target, nil)
				local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
				local an, af, ai = U.animation_name_facing_point(this, a.animation, t_pos)

				U.animation_start_default(this, an, af, store.tick_ts)
				S:queue(a.start_sound, a.start_sound_args)

				while store.tick_ts - start_ts < a.shoot_time do
					if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
						goto label_411_0
					end

					coroutine.yield()
				end

				S:queue(a.sound)

				b = E:create_entity(a.bullet)
				b.bullet.target_id = target.id
				b.bullet.source_id = this.id
				b.bullet.xp_dest_id = this.id

				b.pos:copy(this.pos)

				b.pos.x = b.pos.x + (af and -1 or 1) * a.bullet_start_offset[ai].x
				b.pos.y = b.pos.y + a.bullet_start_offset[ai].y

				b.bullet.from:copy(b.pos)

				b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
				b.bullet.shot_index = 1
				b.initial_impulse = 10
				b.bullet.damage_factor = this.unit.damage_factor

				-- if upg_lf and a.basic_attack then
				--     if not this._lethal_focus_deck then
				--         this._lethal_focus_deck = SU.deck_new(upg_lf.trigger_cards, upg_lf.total_cards)
				--     end
				--     local triggered_lethal_focus = SU.deck_draw(this._lethal_focus_deck)
				--     if triggered_lethal_focus then
				--         b.bullet.damage_factor = b.bullet.damage_factor * upg_lf.damage_factor_area
				--         b.bullet.pop = {
				--             "pop_crit"
				--         }
				--         b.bullet.pop_chance = 1
				--         b.bullet.pop_conds = DR_DAMAGE
				--     end
				-- end
				simulation:queue_insert_entity(b)

				if a.xp_from_skill then
					SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
				end

				a.ts = start_ts

				while not U.animation_finished_default(this) do
					if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
						goto label_411_0
					end

					coroutine.yield()
				end

				a.ts = start_ts

				U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

				::label_411_0::

				if start_fx then
					start_fx.render.sprites[1].hidden = true
				end

				goto label_411_2
			end
		end

		::label_411_1::

		SU.soldier_idle(store, this)
		SU.soldier_regen(store, this)

		::label_411_2::

		coroutine.yield()
	end
end

local function mod_hero_lumenir_shield_insert(this, store)
	local m = this.modifier

	this.modifier.ts = store.tick_ts

	local target = store.entities[m.target_id]

	if not target or not target.pos then
		return false
	end

	local s = this.render.sprites[1]
	local sd = this.render.sprites[2]

	s.ts = store.tick_ts

	if s.size_names then
		s.name = s.size_names[target.unit.size]
		sd.name = sd.name .. "_" .. sd.size_names[target.unit.size]
	end

	if this.custom_offsets then
		s.offset = V.vclone(this.custom_offsets[target.template_name] or this.custom_offsets.default)
		s.offset.x = s.offset.x * (s.flip_x and -1 or 1)

		if target.unit and target.unit.mod_offset and this.modifier.use_mod_offset then
			s.offset.x = s.offset.x + target.unit.mod_offset.x
			s.offset.y = s.offset.y + target.unit.mod_offset.y
		end
	end

	if target.health then
		SU.spiked_armor_inc(target, this.spiked_armor)
		SU.armor_inc(target, this.armor)
	end

	return true
end

local function mod_hero_lumenir_shield_update(this, store)
	local m = this.modifier

	this.modifier.ts = store.tick_ts

	local target = store.entities[m.target_id]

	if not target or not target.pos then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or m.duration >= 0 and store.tick_ts - m.ts > m.duration or m.last_node and target.nav_path.ni > m.last_node then
			this.tween.reverse = true
			this.tween.remove = true
			this.tween.ts = store.tick_ts

			U.y_wait_unconditional(store, 0.25)
			simulation:queue_remove_entity(this)

			return
		end

		local s = this.render.sprites[1]

		if m.use_mod_offset and target.unit.mod_offset then
			s.offset.x, s.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end

		coroutine.yield()
	end
end

local function mod_hero_lumenir_shield_remove(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target and target.health then
		SU.spiked_armor_dec(target, this.spiked_armor)
		SU.armor_dec(target, this.armor)
	end

	return true
end

local function aura_fire_balls_hero_lumenir_insert(this, store)
	local next_pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)

	if not next_pos then
		return false
	end

	return true
end

local function aura_fire_balls_hero_lumenir_update(this, store)
	local y_off = 20
	local a = this.aura
	local m = this.motion
	local nav = this.nav_path
	local dt = store.tick_length
	local start_ts = store.tick_ts
	local hit_ts = 0

	a.duration = a.duration + U.frandom(-a.duration_var, 0)
	m.max_speed = m.max_speed + math.random(0, m.max_speed_var)

	local step = m.max_speed * dt
	local next_pos = P:node_pos(nav.pi, nav.spi, nav.ni)

	next_pos.y = next_pos.y + y_off

	U.set_destination(this, next_pos)

	local v_heading = V.v(0, 0)

	v_heading.x, v_heading.y = V.normalize(next_pos.x - this.pos.x, next_pos.y - this.pos.y)

	local th_dist = 25
	local turn_speed = math.pi * 1.5
	local speed_offset = 0
	local ps = E:create_entity("ps_bolt_lumenir_wave")

	ps.particle_system.track_id = this.id

	simulation:queue_insert_entity(ps)

	while true do
		if this.tween.disabled and store.tick_ts - start_ts > a.duration then
			this.tween.disabled = nil
			this.tween.ts = store.tick_ts
		end

		if th_dist > V.len(m.dest.x - this.pos.x, m.dest.y - this.pos.y) then
			nav.ni = nav.ni + math.random(6, 11) * nav.dir

			local p_len = #P:path(nav.pi)

			if nav.ni <= 1 or p_len <= nav.ni then
				a.duration = 0
			end

			nav.ni = km.clamp(1, p_len, nav.ni)
			nav.spi = km.zmod(nav.spi + math.random(1, 2), 3)
			next_pos = P:node_pos(nav.pi, nav.spi, nav.ni)
			next_pos.y = next_pos.y + y_off

			U.set_destination(this, next_pos)
		end

		local dx, dy = V.sub(m.dest.x, m.dest.y, this.pos.x, this.pos.y)
		local sa = km.short_angle(V.angleTo(dx, dy), V.angleTo(v_heading.x, v_heading.y))
		local angle_step = math.min(turn_speed * dt, math.abs(sa)) * km.sign(sa) * -1

		v_heading.x, v_heading.y = V.rotate(angle_step, v_heading.x, v_heading.y)

		local sx, sy = V.mul(step, v_heading.x, v_heading.y)

		if this.delay and speed_offset < this.delay then
			sx = sx * speed_offset / this.delay
			sy = sy * speed_offset / this.delay
			speed_offset = speed_offset + dt
		end

		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, sx, sy)
		m.speed.x, m.speed.y = sx / dt, sy / dt
		this.render.sprites[1].r = V.angleTo(v_heading.x, v_heading.y)

		if store.tick_ts - hit_ts > a.damage_cycle then
			hit_ts = store.tick_ts

			local targets = U.find_enemies_in_range_filter_off(this.pos, a.damage_radius, a.damage_flags, a.damage_bans)

			if not targets then
			-- block empty
			else
				for _, e in ipairs(targets) do
					local d = E.assign_damage(a.damage_type, math.random(this.flame_damage_min[this.level], this.flame_damage_max[this.level]) * a.damage_factor, this.id, e.id)

					queue_damage(store, d)
				end
			end
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function mod_hero_lumenir_sword_hit_update(this, store)
	local m = this.modifier

	this.modifier.ts = store.tick_ts

	local target = store.entities[m.target_id]
	local time_hit = this.time_hit
	local decal_spawn_time = this.decal_spawn_time
	local damaged = false
	local decal_spawned = false

	if not target or not target.pos then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos

	S:queue(this.sound)

	while true do
		target = store.entities[m.target_id]

		if m.duration >= 0 and store.tick_ts - m.ts > m.duration or m.last_node and target.nav_path.ni > m.last_node then
			simulation:queue_remove_entity(this)

			return
		end

		if not damaged and time_hit < store.tick_ts - m.ts then
			damaged = true

			if target and not target.health.dead then
				local d = E.assign_damage(this.damage_type, this.damage[m.level] * m.damage_factor, this.id, target.id)

				queue_damage(store, d)
			end

			local targets = U.find_enemies_in_range_filter_off(this.pos, this.stun_range, this.stun_vis_flags, this.stun_bans)

			if targets then
				for _, target in ipairs(targets) do
					local s = E:create_entity(this.mod_stun)

					s.modifier.target_id = target.id
					s.modifier.source_id = m.source_id
					s.modifier.duration = this.stun_duration[m.level]

					simulation:queue_insert_entity(s)
				end
			end
		end

		if not decal_spawned and decal_spawn_time < store.tick_ts - m.ts then
			decal_spawned = true

			local decal = E:create_entity(this.hit_decal)

			decal.pos:copy(this.pos)

			decal.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(decal)
		end

		coroutine.yield()
	end
end

local function soldier_lumenir_ultimate_insert(this, store)
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

local function soldier_lumenir_ultimate_update(this, store)
	local target_id = this.soldier.target_id or this.unblocked_target_id
	local target = store.entities[target_id]
	local attack_count = 0

	this.render.sprites[1].ts = store.tick_ts
	this.render.sprites[1].runs = 0

	U.animation_start(this, "idle", nil, store.tick_ts, false, 2)
	U.y_wait_unconditional(store, 0.4)

	this.render.sprites[1].hidden = false

	U.animation_start(this, "idle", nil, store.tick_ts, false, 1)

	if target then
		local enemies = U.find_enemies_in_range_filter_off(target.pos, this.stun_range, this.stun_flags, this.stun_bans)

		if enemies then
			for k, e in ipairs(enemies) do
				local m = E:create_entity("mod_lumenir_ulti_stun")

				m.modifier.duration = this.stun_duration
				m.modifier.target_id = e.id
				m.modifier.source_id = this.id

				simulation:queue_insert_entity(m)
			end
		end
	end

	if not target then
		U.y_wait_unconditional(store, U.frandom(this.min_wait, this.max_wait))
	else
		while target and not target.health.dead and not this.health.dead and (not this.max_attack_count or attack_count < this.max_attack_count) do
			local attack = SU.soldier_pick_melee_attack(store, this, target)

			if attack then
				for _, hit_time in pairs(attack.hit_times) do
					local start_ts = store.tick_ts
					local an, af = U.animation_name_facing_point(this, attack.animation, target.pos)

					U.animation_start(this, an, af, store.tick_ts, false, 1)
					S:queue(attack.sound)
					U.y_wait_unconditional(store, hit_time)
					S:queue(attack.sound_hit)

					attack.ts = start_ts

					for _, aa in ipairs(this.melee.attacks) do
						if aa ~= attack and aa.shared_cooldown then
							aa.ts = attack.ts
						end
					end

					if attack.damage_type ~= DAMAGE_NONE then
						local d = E.assign_damage(attack.damage_type, math.ceil(U.frandom(attack.damage_min, attack.damage_max)), this.id, target.id)

						queue_damage(store, d)
					end
				end

				U.y_animation_wait_default(this)

				attack_count = attack_count + 1
			end

			coroutine.yield()

			target = store.entities[target_id]
		end
	end

	S:queue(this.sound_events.death, {
		delay = fts(11)
	})
	U.y_animation_play(this, "out", nil, store.tick_ts, 1, 1)
	simulation:queue_remove_entity(this)
end

local function mini_dragon_hero_lumenir_update(this, store)
	local sd = this.render.sprites[1]
	local ss = this.render.sprites[2]
	local a = this.ranged.attacks[1]
	local fm = this.force_motion
	local hero = store.entities[this.hero_id]
	local dist
	local dest = V.v(this.pos.x, this.pos.y)

	if this.delay_creation then
		ss.hidden = true

		U.y_wait_unconditional(store, this.delay_creation)

		ss.hidden = false
	end

	local flight_height = this.flight_height

	flight_height = this.custom_height and this.custom_height[hero.template_name] or flight_height
	this.tween.props[1].keys = {{0, v(0, flight_height + 2)}, {0.4, v(0, flight_height - 2)}, {0.8, v(0, flight_height + 2)}}
	this.render.sprites[1].offset.y = flight_height
	fm.a_step = fm.a_step + math.random(-3, 3)
	this.tween.disabled = false
	this.tween.ts = store.tick_ts

	U.y_animation_play(this, "spawn", true, store.tick_ts)
	U.animation_start_default(this, "walk", nil, store.tick_ts, true)

	this.start_ts = store.tick_ts

	while store.tick_ts - this.start_ts <= this.duration do
		if this.remove_hero_death then
			if hero.health.dead then
				break
			end
		elseif not hero.health.dead then
			break
		end

		if hero then
			this._chasing_target_id = hero.id
		else
			this._chasing_target_id = nil
		end

		if hero then
			repeat
				dest.x, dest.y = hero.pos.x + this.offset.x, hero.pos.y + this.offset.y
				sd.flip_x = dest.x < this.pos.x

				U.force_motion_step(this, store.tick_length, dest)
				coroutine.yield()

				dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)
			until dist < 5

			if a.sync_animation and not this.render.sprites[1].sync_flag then
			-- block empty
			else
				local targets = U.find_enemies_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

				if targets and #targets > 0 then
					local start_ts = store.tick_ts
					local start_fx, b
					local target = targets[1]
					local node_offset = P:predict_enemy_node_advance(target, 1)
					local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
					local an, af = U.animation_name_facing_point(this, a.animation, t_pos)

					U.animation_start_default(this, an, af, store.tick_ts)
					S:queue(a.start_sound, a.start_sound_args)

					while store.tick_ts - start_ts < a.shoot_time do
						coroutine.yield()
					end

					S:queue(a.sound)

					b = E:create_entity(a.bullet)
					b.bullet.target_id = target.id
					b.bullet.source_id = this.id
					b.bullet.xp_dest_id = this.id

					b.pos:copy(this.pos)

					b.pos.x = b.pos.x + (af and -1 or 1) * a.bullet_start_offset.x
					b.pos.y = b.pos.y + a.bullet_start_offset.y + flight_height

					b.bullet.from:copy(b.pos)

					b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
					b.bullet.shot_index = 1
					b.initial_impulse = 10

					simulation:queue_insert_entity(b)

					a.ts = start_ts

					while not U.animation_finished_default(this) do
						coroutine.yield()
					end

					a.ts = start_ts

					U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

					if start_fx then
						start_fx.render.sprites[1].hidden = true
					end
				end

				U.animation_start_default(this, "walk", nil, store.tick_ts, true)
			end
		end
	end

	U.y_ease_keys(store, {sd, sd.offset, ss}, {"alpha", "y", "alpha"}, {255, this.flight_height, 255}, {0, 85, 0}, 0.4, {"linear", "linear", "linear"})
	simulation:queue_remove_entity(this)
end

tt = RT("ps_bolt_lumenir_mini")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_lumenir_light_companion_attack_projectile_trail_particle_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(12), fts(12)}
tt.particle_system.emission_rate = 15
tt.particle_system.emit_rotation_spread = math.pi / 2
tt = RT("decal_hero_lumenir_sword", "decal_tween")
tt.render.sprites[1].name = "hero_lumenir_celestial_judgement_fx_decal"
tt.render.sprites[1].animated = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {2, 255}, {2.5, 0}}
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = false
tt = RT("hero_lumenir", "hero")

AC(tt, "ranged", "tween")

tt.hero.level_stats.armor = {0, 0.04, 0.08, 0.12, 0.16, 0.2, 0.24, 0.28, 0.32, 0.36}
tt.hero.level_stats.hp_max = {357, 390, 422, 455, 487, 520, 552, 585, 617, 650}
tt.hero.level_stats.melee_damage_max = {1, 2, 4, 4, 5, 6, 7, 8, 9, 10}
tt.hero.level_stats.melee_damage_min = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
tt.hero.level_stats.ranged_damage_min = {18, 22, 26, 28, 32, 36, 40, 44, 46, 49}
tt.hero.level_stats.ranged_damage_max = {33, 40, 46, 54, 61, 67, 74, 80, 88, 96}
tt.hero.level_stats.mini_dragon_death_ranged_damage_min = {10, 10, 10, 10, 20, 20, 20, 31, 31, 31}
tt.hero.level_stats.mini_dragon_death_ranged_damage_max = {15, 15, 15, 15, 31, 31, 31, 46, 46, 46}
tt.hero.skills.shield = CC("hero_skill")
tt.hero.skills.shield.spiked_armor = {0.2, 0.4, 0.6}
tt.hero.skills.shield.armor = {0.1, 0.2, 0.3}
tt.hero.skills.shield.duration = {8, 8, 8}
tt.hero.skills.shield.cooldown = {20, 20, 20}
tt.hero.skills.shield.xp_gain = {160, 320, 480}
tt.hero.skills.shield.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.celestial_judgement = CC("hero_skill")
tt.hero.skills.celestial_judgement.cooldown = {32, 32, 32}
tt.hero.skills.celestial_judgement.xp_gain = {280, 560, 840}
tt.hero.skills.celestial_judgement.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.mini_dragon = CC("hero_skill")
tt.hero.skills.mini_dragon.cooldown = {30, 30, 30}
tt.hero.skills.mini_dragon.duration = {10, 12, 15}
tt.hero.skills.mini_dragon.damage_min = {13, 20, 24}
tt.hero.skills.mini_dragon.damage_max = {18, 31, 37}
tt.hero.skills.mini_dragon.xp_gain = {240, 480, 720}
tt.hero.skills.mini_dragon.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.fire_balls = CC("hero_skill")
tt.hero.skills.fire_balls.cooldown = {20, 20, 20}
tt.hero.skills.fire_balls.flames_count = {5, 6, 7}
tt.hero.skills.fire_balls.xp_gain = {160, 320, 480}
tt.hero.skills.fire_balls.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_lumenir_ultimate"
tt.hero.skills.ultimate.count = {3, 3, 3, 3}
tt.hero.skills.ultimate.max_attack_count = 2
tt.hero.skills.ultimate.damage_max = {19, 29, 48, 77}
tt.hero.skills.ultimate.damage_min = {13, 19, 32, 51}
tt.hero.skills.ultimate.cooldown = {30, 30, 30, 30}
tt.hero.skills.ultimate.xp_gain_factor = 22
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.health.dead_lifetime = 15
tt.health_bar.draw_order = -1
tt.health_bar.offset = v(0, 170)
tt.health_bar.sort_y_offset = -171
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.health_bar.z = Z_FLYING_HEROES
tt.hero.fn_level_up = hero_lumenir_level_up
tt.idle_flip.cooldown = 10
tt.info.hero_portrait = "kr5_hero_portraits_0011"
tt.info.portrait = "kr5_info_portraits_heroes_0011"
tt.main_script.update = hero_lumenir_update
tt.motion.max_speed = 120
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.all_except_flying_nowalk = bor(TERRAIN_NONE, TERRAIN_LAND, TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_SHALLOW, TERRAIN_FAERIE, TERRAIN_ICE)
tt.nav_grid.valid_terrains = tt.all_except_flying_nowalk
tt.nav_grid.valid_terrains_dest = tt.all_except_flying_nowalk
tt.drag_line_origin_offset = v(0, 100)
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].prefix = "hero_lumenir_hero"
tt.render.sprites[1].name = "respawn"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_lumenir_hero_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.sound_events.change_rally_point = "HeroLumenirTaunt"
tt.sound_events.death = "HeroLumenirDeath"
tt.sound_events.respawn = "HeroLumenirTauntIntro"
tt.sound_events.hero_room_select = "HeroLumenirTauntSelect"
tt.ui.click_rect = r(-37, 68, 90, 85)
tt.unit.hit_offset = v(0, 110)
tt.unit.hide_after_death = true
tt.unit.mod_offset = v(0, 134)
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_POISON)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.mini_dragon = "mini_dragon_death_hero_lumenir"
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "bolt_lumenir"
tt.ranged.attacks[1].bullet_start_offset = {v(44, 80)}
tt.ranged.attacks[1].cooldown = 1.8
tt.ranged.attacks[1].bullet_count = 3
tt.ranged.attacks[1].max_range = 240
tt.ranged.attacks[1].shoot_time = fts(14)
tt.ranged.attacks[1].sync_animation = true
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].start_fx = "fx_lumenir_start_attack"
tt.ranged.attacks[1].sound = "HeroLumenirBasicAttack"
tt.ranged.attacks[1].ignore_offset = v(0, 110)
tt.ranged.attacks[1].radius = 100
tt.ranged.attacks[1].basic_attack = true
tt.ranged.attacks[2] = CC("aura_attack")
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].mod = "mod_hero_lumenir_shield"
tt.ranged.attacks[2].cooldown = 25
tt.ranged.attacks[2].animation = "hero_lumenir_hero_blessing_of_retribution"
tt.ranged.attacks[2].shoot_time = fts(12)
tt.ranged.attacks[2].min_count = 2
tt.ranged.attacks[2].sync_animation = true
tt.ranged.attacks[2].animation = "blessing_of_retribution"
tt.ranged.attacks[2].start_fx = "fx_lumenir_start_lance"
tt.ranged.attacks[2].sound = "HeroLumenirBlessingOfRetributionCast"
tt.ranged.attacks[2].start_sound_args = {
	delay = fts(12)
}
tt.ranged.attacks[2].xp_from_skill = "shield"
tt.ranged.attacks[2].vis_flags = bor(F_RANGED, F_ENEMY, F_MOD)
tt.ranged.attacks[2].vis_bans = F_HERO
tt.ranged.attacks[2].range = 300
tt.ranged.attacks[3] = CC("aura_attack")
tt.ranged.attacks[3].disabled = true
tt.ranged.attacks[3].mod = "mod_hero_lumenir_sword_hit"
tt.ranged.attacks[3].min_nodes = 20
tt.ranged.attacks[3].shoot_time = fts(24)
tt.ranged.attacks[3].sync_animation = true
tt.ranged.attacks[3].animation = "celestial_judgement"
tt.ranged.attacks[3].sound = "HeroLumenirCelestialJudgementCast"
tt.ranged.attacks[3].start_sound_args = {
	delay = fts(12)
}
tt.ranged.attacks[3].estimated_flight_time = 1
tt.ranged.attacks[3].vis_flags = bor(F_RANGED)
tt.ranged.attacks[3].vis_bans = bor(F_FLYING, F_CLIFF)
tt.ranged.attacks[3].range = 300
tt.ranged.attacks[3].xp_from_skill = "celestial_judgement"
tt.ranged.attacks[4] = CC("aura_attack")
tt.ranged.attacks[4].disabled = true
tt.ranged.attacks[4].spawn_pos_offset = v(0, 0)
tt.ranged.attacks[4].shoot_time = fts(4)
tt.ranged.attacks[4].sync_animation = true
tt.ranged.attacks[4].entity = "mini_dragon_hero_lumenir"
tt.ranged.attacks[4].animation = "blessing_of_retribution"
tt.ranged.attacks[4].start_fx = "fx_lumenir_start_enervation"
tt.ranged.attacks[4].sound = "HeroLumenirLightCompanionCast"
tt.ranged.attacks[4].estimated_flight_time = 0
tt.ranged.attacks[4].vis_flags = bor(F_RANGED)
tt.ranged.attacks[4].vis_bans = bor(F_BOSS)
tt.ranged.attacks[4].xp_from_skill = "mini_dragon"
tt.ranged.attacks[5] = CC("spawn_attack")
tt.ranged.attacks[5].animation = "radiant_wave"
tt.ranged.attacks[5].cooldown = 20
tt.ranged.attacks[5].disabled = true
tt.ranged.attacks[5].entity = "aura_fire_balls_hero_lumenir"
tt.ranged.attacks[5].spawn_offset = v(43, 81)
tt.ranged.attacks[5].spawn_time = fts(12)
tt.ranged.attacks[5].vis_flags = bor(F_RANGED)
tt.ranged.attacks[5].vis_bans = bor(F_FLYING)
tt.ranged.attacks[5].range_nodes_max = 50
tt.ranged.attacks[5].range_nodes_min = 10
tt.ranged.attacks[5].sound = "HeroLumenirRadiantWaveCast"
tt.ranged.attacks[5].xp_from_skill = "fire_balls"
tt.ranged.attacks[5].min_targets = 3
tt.ultimate = {
	ts = 0,
	cooldown = 22.5,
	vis_ban = F_FLYING,
	disabled = true
}
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt = RT("mini_dragon_hero_lumenir", "decal_scripted")

AC(tt, "force_motion", "ranged", "tween", "idle_flip")

tt.main_script.update = mini_dragon_hero_lumenir_update
tt.flight_height = 60
tt.custom_height = {
	hero_vesper = 60,
	hero_dragon_gem = 40,
	hero_lumenir = 100,
	hero_dragon_bone = 40
}
tt.force_motion.max_a = 1200
tt.force_motion.max_v = 360
tt.force_motion.ramp_radius = 30
tt.force_motion.fr = 0.05
tt.force_motion.a_step = 20
tt.offset = v(0, 0)
tt.render.sprites[1].prefix = "hero_lumenir_light_companion"
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[1].scale = v(0.75, 0.75)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].alpha = 100
tt.render.sprites[2].name = "hero_lumenir_light_companion_shadow"
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].max_range = 120
tt.ranged.attacks[1].hit_time = fts(2)
tt.ranged.attacks[1].hit_cycles = 3
tt.ranged.attacks[1].bullet = "bolt_lumenir_mini"
tt.ranged.attacks[1].hit_delay = fts(2)
tt.ranged.attacks[1].search_cooldown = 0.1
tt.ranged.attacks[1].shoot_time = fts(11)
tt.ranged.attacks[1].shoot_range = 25
tt.ranged.attacks[1].xp_gain_factor = nil
tt.ranged.attacks[1].basic_attack = true
tt.ranged.attacks[1].bullet_start_offset = v(16, -16)
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].loop = true
tt.tween.props[1].interp = "sine"
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {{1, 0}, {1.5, 255}}
tt = RT("mini_dragon_death_hero_lumenir", "mini_dragon_hero_lumenir")
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].bullet = "bolt_lumenir_mini_death"
tt = RT("hero_lumenir_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.main_script.update = hero_lumenir_ultimate_update
tt.cooldown = 30
tt.range = 200
tt.spawn_delay = 0.5
tt.count = 6
tt.vis_flags = bor(F_RANGED)
tt.vis_bans = bor(F_FLYING)
tt.entity = "soldier_lumenir_ultimate"
tt = RT("soldier_lumenir_ultimate", "soldier")

AC(tt, "melee")

tt.health.hp_max = 50
tt.health.ignore_damage = true
tt.health_bar.hidden = true
tt.min_wait = 0.1
tt.max_wait = 0.4
tt.main_script.insert = soldier_lumenir_ultimate_insert
tt.main_script.update = soldier_lumenir_ultimate_update
tt.motion.max_speed = 90
tt.max_attack_count = 2
tt.stun_range = 40
tt.stun_bans = bor(F_RANGED)
tt.stun_flags = bor(F_FLYING, F_BOSS)
tt.stun_duration = 1
tt.sound_events.death = "HeroLumenirCallOfTriumphOut"
tt.regen.cooldown = 1
tt.regen.health = 0
tt.render.sprites[1].prefix = "hero_lumenir_call_of_triumph"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].loop = false
tt.render.sprites[2].prefix = "hero_lumenir_call_of_triumph_spawn_fx"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].sort_y_offset = -3
tt.soldier.melee_slot_offset = v(5, 0)
tt.sound_events.insert = "HeroLumenirCallOfTriumphCast"
tt.ui.can_click = false
tt.ui.can_select = false
tt.unit.mod_offset = v(0, 15)
tt.vis.bans = bor(F_ALL)
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_times = {fts(7), fts(15), fts(24)}
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].sound_hit = "MeleeSword"
tt.melee.cooldown = fts(15)
tt.melee.range = 60
tt = RT("bolt_lumenir_mini", "bolt_lumenir")
tt.force_motion.max_v = 300
tt.bullet.hit_fx = "fx_bolt_lumenir_hit_mini"
tt.bullet.particles_name = "ps_bolt_lumenir_mini"
tt.render.sprites[1].name = "hero_lumenir_light_companion_attack_projectile_idle"
tt.sound_events.insert = "HeroLumenirLightCompanionBasicAttack"
tt = RT("bolt_lumenir_mini_death", "bolt_lumenir_mini")
tt = RT("aura_fire_balls_hero_lumenir", "aura")

AC(tt, "render", "nav_path", "motion", "tween")

tt.aura.duration = 8
tt.aura.duration_var = 0.5
tt.flame_damage_min = {1, 2, 4}
tt.flame_damage_max = {3, 6, 8}
tt.aura.damage_radius = 55
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.damage_cycle = 0.25
tt.aura.damage_flags = F_AREA
tt.aura.damage_bans = 0
tt.motion.max_speed = 3.5 * FPS
tt.motion.max_speed_var = 0.25 * FPS
tt.main_script.insert = aura_fire_balls_hero_lumenir_insert
tt.main_script.update = aura_fire_balls_hero_lumenir_update
tt.render.sprites[1].name = "hero_lumenir_radiant_wave_projectile_idle"
tt.render.sprites[1].sort_y_offset = -21
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {tt.aura.duration_var, 0}}
tt = RT("mod_hero_lumenir_sword_hit", "modifier")

AC(tt, "render")

tt.modifier.duration = fts(39)
tt.render.sprites[1].name = "hero_lumenir_celestial_judgement_fx_idle"
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].loop = false
tt.mod_stun = "mod_hero_lumenir_stun"
tt.hit_decal = "decal_hero_lumenir_sword"
tt.decal_spawn_time = fts(25)
tt.time_hit = fts(22)
tt.damage = {240, 480, 720}
tt.stun_duration = {2, 2, 2}
tt.damage_type = DAMAGE_TRUE
tt.stun_range = 40
tt.stun_vis_flags = F_RANGED
tt.stun_bans = bor(F_FLYING)
tt.main_script.update = mod_hero_lumenir_sword_hit_update
tt.sound = "HeroLumenirCelestialJudgementImpact"
tt = RT("mod_hero_lumenir_stun", "mod_stun")
tt.modifier.duration = fts(23)
tt = RT("mod_hero_lumenir_shield", "modifier")

AC(tt, "render", "tween")

tt.main_script.insert = mod_hero_lumenir_shield_insert
tt.main_script.update = mod_hero_lumenir_shield_update
tt.main_script.remove = mod_hero_lumenir_shield_remove
tt.render.sprites[1].prefix = "hero_lumenir_blessing_of_retribution_shield"
tt.render.sprites[1].size_names = {"small", "mid", "big"}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "hero_lumenir_blessing_of_retribution_shield_decal"
tt.render.sprites[2].size_names = {"small", "mid", "big"}
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}}
tt = RT("mod_lumenir_ulti_stun", "mod_stun")
tt.modifier.duration = 5
tt.modifier.allows_duplicates = true
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
