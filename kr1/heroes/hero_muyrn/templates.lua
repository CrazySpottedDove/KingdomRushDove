local scripts = require("scripts")
local E = require("entity_db")
local GR = require("grid_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local UP = require("kr1.upgrades")
local V = require("lib.klua.vector")
local bit = require("bit")
local HU = require("hero_utils")
local km = require("lib.klua.macros")
local band = bit.band
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local vv = V.vv
local tt

local function hero_muyrn_sentinel_wisps_entity_insert(this, store)
	this.ranged.attacks[1].cooldown = this.ranged.attacks[1].cooldown * (0.9 + math.random(1, 2) / 10)
	this.hero_max_distance = this.hero_max_distance * (0.7 + math.random(1, 3) / 10)
	this.force_motion.max_a = this.force_motion.max_a * (0.1 + math.random(1, 9) / 10)
	this.force_motion.a_step = this.force_motion.a_step * (1 + 0.9 * this.wisp_order)
	this.force_motion.max_a = this.force_motion.max_a * (1 + 10 * this.wisp_order)

	return true
end

local function hero_muyrn_sentinel_wisps_entity_update(this, store)
	local sb_sid = 1
	local sb = this.render.sprites[sb_sid]
	local fm = this.force_motion
	local hero = store.entities[this.owner_id]
	local dest = V.v(this.pos.x, this.pos.y)
	local offset_x = this.pos.x - hero.pos.x
	local offset_y = this.pos.y - hero.pos.y
	local a = this.ranged.attacks[1]

	this.render.sprites[1].hidden = true
	this.render.sprites[2].hidden = true

	U.y_wait_unconditional(store, this.wisp_order * fts(6))

	this.render.sprites[1].hidden = false
	this.render.sprites[2].hidden = false

	local spawn_ts = store.tick_ts

	this.tween.disabled = false
	this.tween.ts = store.tick_ts

	local starting_offset = V.v(offset_x, offset_y)
	local positions = {{{0, starting_offset}, {0.2, V.v(offset_x, offset_y + 20)}, {0.5, V.v(offset_x + 5, offset_y - 10)}, {0.7, V.v(offset_x - 5, offset_y)}, {0.8, V.v(offset_x, offset_y + 5)}, {1, starting_offset}}, {{0, starting_offset}, {0.2, V.v(offset_x, offset_y - 20)}, {0.5, V.v(offset_x - 5, offset_y - 10)}, {0.7, V.v(offset_x + 5, offset_y)}, {0.8, V.v(offset_x, offset_y + 5)}, {1, starting_offset}}, {{0, starting_offset}, {0.2, V.v(offset_x - 10, offset_y)}, {0.5, V.v(offset_x + 5, offset_y + 10)}, {0.7, V.v(offset_x - 5, offset_y)}, {0.8, V.v(offset_x, offset_y + 5)}, {1, starting_offset}}}

	local function current_phase(phase)
		local last_i = 1

		for i, value in ipairs(positions[this.wisp_order]) do
			if phase < value[1] then
				if i > 1 then
					last_i = i - 1
				end

				break
			end
		end

		return last_i
	end

	local function move_step(dest)
		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)
		local ramp_radius = fm.ramp_radius
		local df = (not ramp_radius or ramp_radius < dist) and 1 or math.max(dist / ramp_radius, 0.1)

		fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step * df, dx, dy)))
		fm.v.x, fm.v.y = V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y))
		fm.v.x, fm.v.y = V.trim(fm.max_v, fm.v.x, fm.v.y)
		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
		fm.a.x, fm.a.y = V.mul(-1 * fm.fr / store.tick_length, fm.v.x, fm.v.y)
	end

	if this.particles_name then
		local ps = E:create_entity(this.particles_name)

		ps.particle_system.track_id = this.id
		ps.particle_system.track_offset = V.v(0, this.flight_height)

		simulation:queue_insert_entity(ps)
	end

	S:queue(this.sound)
	U.y_animation_play(this, "spawn", nil, store.tick_ts)

	local effect_x, effect_y

	local function recalculate_offset()
		local phase = (store.tick_ts - spawn_ts) / this.duration
		local current_phase_i = current_phase(phase)
		local last_phase_i = current_phase_i - 1

		if last_phase_i < 1 then
			last_phase_i = 1
		end

		local to = positions[this.wisp_order][current_phase_i][2]
		local easing = "quad-inout"
		local new_pos_x = U.ease_value(this.pos.x, this.pos.x + to.x, phase, easing)
		local new_pos_y = U.ease_value(this.pos.y, this.pos.y + to.y, phase, easing)

		effect_x = new_pos_x - this.pos.x
		effect_y = new_pos_y - this.pos.y
	end

	while true do
		if store.tick_ts - spawn_ts > this.duration then
			this.tween.reverse = true
			this.tween.ts = store.tick_ts

			U.y_animation_play(this, "death", nil, store.tick_ts)

			break
		end

		recalculate_offset()

		dest.x = hero.pos.x + offset_x + effect_x
		dest.y = hero.pos.y + offset_y + effect_y

		move_step(dest)

		if not (store.tick_ts - a.ts > a.cooldown) or not hero or hero.health.dead then
		-- block empty
		else
			local target, _ = U.find_foremost_enemy_in_range_filter_off(this.pos, a.max_range, false, a.vis_flags, a.vis_bans)

			if target and target.health and not target.health.dead then
				local b = E:create_entity(a.bullet)

				b.pos.x, b.pos.y = this.pos.x + sb.offset.x, this.pos.y + sb.offset.y

				b.bullet.from:copy(b.pos)

				b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
				b.bullet.target_id = target.id
				b.bullet.source_id = this.id

				simulation:queue_insert_entity(b)

				a.ts = store.tick_ts

				local sfx = E:create_entity(this.attack_fx)

				sfx.pos = this.pos
				sfx.render.sprites[1].ts = store.tick_ts
				sfx.render.sprites[1].runs = 0
				sfx.render.sprites[1].offset = v(0, this.flight_height)

				simulation:queue_insert_entity(sfx)
			end
		end

		U.animation_start(this, "idle", nil, store.tick_ts, true, sb_sid)
		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function hero_muyrn_leaf_whirlwind_decal_update(this, store)
	local start_ts = store.tick_ts

	U.y_animation_play(this, "start", nil, store.tick_ts)
	U.animation_start_default(this, "loop", nil, store.tick_ts, true)

	while store.tick_ts - start_ts < this.duration and not this.force_end_animation do
		local te = store.entities[this.source_id]

		if not te or te.health and te.health.dead then
			break
		end

		coroutine.yield()
	end

	U.y_animation_play(this, "end", nil, store.tick_ts, 1)
	simulation:queue_remove_entity(this)
end

local function hero_muyrn_root_defender_aura_insert(this, store)
	local function insert_root(pos, duration)
		local fx = E:create_entity(this.root_decal .. "_" .. math.random(1, 2, 3))

		fx.render.sprites[1].flip_x = math.random() < 0.5
		fx.delay = U.frandom(0, 0.3)
		fx.pos = pos
		fx.duration = duration

		simulation:queue_insert_entity(fx)
	end

	this.aura.ts = store.tick_ts
	this.aura.duration = this.duration[this.aura.level]
	this.actual_duration = this.duration[this.aura.level]

	local roots_count = this.roots_count[this.aura.level]
	local root_rows = math.floor(roots_count / 3)
	local ni_inc = 2
	local pi = this.pos_pi
	local ni = this.pos_ni + math.floor((ni_inc + 2.5) * root_rows / 2)

	for i = 1, roots_count do
		local spi = km.zmod(i, 3)

		if P:is_node_valid(pi, ni) then
			local pos = P:node_pos(pi, spi, ni)

			pos.x, pos.y = pos.x + math.random(0, 8), pos.y + math.random(0, 8)

			insert_root(pos, this.actual_duration)
		end

		if i % 3 == 0 then
			ni = ni - ni_inc - math.random(2, 3)
		end
	end

	return true
end

local function hero_muyrn_root_defender_aura_remove(this, store)
	S:queue(this.end_sound)

	return true
end

local function mod_hero_muyrn_faery_dust_fx_insert(this, store)
	if this.render.sprites[1].size_scales then
		local target = store.entities[this.modifier.target_id]

		this.render.sprites[1].scale = this.render.sprites[1].size_scales[target.unit.size]
	end

	return true
end

local function bullet_hero_muyrn_verdant_blast_update(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local mspeed = b.min_speed
	local target, ps
	local new_target = false
	local target_invalid = false

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	::label_286_0::

	if b.store and not b.target_id then
		S:queue(this.sound_events.summon)

		s.z = Z_OBJECTS
		s.sort_y_offset = b.store_sort_y_offset

		U.animation_start_default(this, "idle", nil, store.tick_ts, true)

		if ps then
			ps.particle_system.emit = false
		end
	else
		S:queue(this.sound_events.travel)

		s.z = Z_BULLETS
		s.sort_y_offset = nil

		U.animation_start_default(this, "flying", nil, store.tick_ts, s.loop)

		if ps then
			ps.particle_system.emit = true
		end
	end

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		coroutine.yield()

		if not target_invalid then
			target = store.entities[b.target_id]
		end

		if target and not new_target then
			local tpx, tpy = target.pos.x, target.pos.y

			if not b.ignore_hit_offset then
				tpx, tpy = tpx + target.unit.hit_offset.x, tpy + target.unit.hit_offset.y
			end

			local d = math.max(math.abs(tpx - b.to.x), math.abs(tpy - b.to.y))

			if d > b.max_track_distance or band(target.vis.bans, F_RANGED) ~= 0 then
				target_invalid = true
				target = nil
			end
		end

		if target and target.health and not target.health.dead then
			if b.ignore_hit_offset then
				b.to.x, b.to.y = target.pos.x, target.pos.y
			else
				b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
			end

			new_target = false
		end

		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length

		if not b.ignore_rotation then
			s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
		end

		if ps then
			ps.particle_system.emit_direction = s.r
		end
	end

	while b.store and not b.target_id do
		coroutine.yield()

		if b.target_id then
			mspeed = b.min_speed
			new_target = true

			goto label_286_0
		end
	end

	this.pos.x, this.pos.y = b.to.x, b.to.y

	S:queue(this.sound)

	if target and not target.health.dead then
		local d = SU.create_bullet_damage(b, target.id, this.id)
		local u = UP:get_upgrade("mage_spell_of_penetration")

		if u and math.random() < u.chance then
			d.damage_type = DAMAGE_TRUE
		end

		queue_damage(store, d)

		if b.mod or b.mods then
			local mods = b.mods or {b.mod}

			for _, mod_name in ipairs(mods) do
				local m = E:create_entity(mod_name)

				m.modifier.target_id = b.target_id
				m.modifier.level = b.level

				simulation:queue_insert_entity(m)
			end
		end

		if b.hit_payload then
			local hp = b.hit_payload

			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y

			simulation:queue_insert_entity(hp)
		end
	end

	if b.payload then
		local hp = b.payload

		hp.pos.x, hp.pos.y = b.to.x, b.to.y

		simulation:queue_insert_entity(hp)
	end

	if b.hit_fx then
		local sfx = E:create_entity(b.hit_fx)

		sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
		sfx.render.sprites[1].ts = store.tick_ts
		sfx.render.sprites[1].runs = 0

		if target and sfx.render.sprites[1].size_names then
			sfx.render.sprites[1].name = sfx.render.sprites[1].size_names[target.unit.size]
		end

		simulation:queue_insert_entity(sfx)
	end

	simulation:queue_remove_entity(this)
end

local function hero_muyrn_root_defender_aura_sides_insert(this, store)
	this.aura.ts = store.tick_ts
	this.aura.duration = this.duration[this.aura.level]
	this.actual_duration = this.duration[this.aura.level]

	return true
end

local function hero_muyrn_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	upgrade_skill(this, "sentinel_wisps", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.max_summons = s.max_summons[s.level]

		local e = E:get_template(a.entity)

		e.duration = s.wisp_duration[s.level]

		local b = E:get_template(e.ranged.attacks[1].bullet)

		b.bullet.damage_min = s.wisp_damage_min[s.level]
		b.bullet.damage_max = s.wisp_damage_max[s.level]
	end)
	upgrade_skill(this, "verdant_blast", function(this, s)
		local a = this.timed_attacks.list[4]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local b = E:get_template(a.bullet)

		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "leaf_whirlwind", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local aura = E:get_template(a.aura)

		aura.aura.duration = s.duration[s.level]
		aura.aura.damage_min = s.damage_min[s.level]
		aura.aura.damage_max = s.damage_max[s.level]

		local mod = E:get_template(a.mod)

		mod.modifier.duration = s.duration[s.level]
		mod.hps.heal_min = s.heal_min[s.level]
		mod.hps.heal_max = s.heal_max[s.level]
	end)
	upgrade_skill(this, "faery_dust", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local aura = E:get_template(a.aura)
		local mod = E:get_template(aura.aura.mods[1])

		mod.inflicted_damage_factor = s.damage_factor[s.level]
		mod.modifier.duration = s.duration[s.level]

		local mod_fx = E:get_template(aura.aura.mods[2])

		mod_fx.modifier.duration = fts(26)
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		local sl = s.level

		this.ultimate.disabled = nil

		local uc = E:get_template(s.controller_name)

		this.ultimate.cooldown = s.cooldown[s.level]

		local a = E:get_template(uc.aura)
		local m_slow = E:get_template(a.aura.mods[1])

		m_slow.slow.factor = s.slow_factor[sl]

		local m_damage = E:get_template(a.aura.mods[2])

		m_damage.dps.damage_min = s.damage_min[sl]
		m_damage.dps.damage_max = s.damage_max[sl]
	end)
	update_hp(this)
end

local function hero_muyrn_update(this, store)
	local h = this.health
	local a, skill, brk, sta

	local function distribute_summons(x, y, qty)
		local positions = {}
		local offset_options = {{{0, 20}}, {{-20, 0}, {20, 0}}, {{0, 15}, {-20, 0}, {20, 0}}}
		local offsets = offset_options[qty]

		for _, offset in ipairs(offsets) do
			if qty <= #positions then
				break
			end

			local pos = V.v(x + offset[1], y + offset[2])

			table.insert(positions, pos)
		end

		return positions
	end

	local function shoot_bullet(attack, enemy, dest, flying)
		local b = E:create_entity(attack.bullet)

		b.pos.x, b.pos.y = this.pos.x + attack.bullet_start_offset.x, this.pos.y + attack.bullet_start_offset.y

		b.bullet.from:copy(b.pos)

		b.bullet.to = dest
		b.bullet.target_id = enemy and enemy.id
		b.bullet.source_id = this.id

		if flying then
			b.bullet.ignore_hit_offset = false
			b.bullet.hit_fx = b.bullet.hit_fx_flying
			-- b.bullet.hit_decal = nil
			b.bullet.hit_decal = "decal_timed_empty"
			b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
		end

		simulation:queue_insert_entity(b)

		return b
	end

	this.health_bar.hidden = false

	local treewalk_trail = E:create_entity(this.treewalk.trail)

	treewalk_trail.particle_system.track_id = this.id
	treewalk_trail.particle_system.emit = false

	simulation:queue_insert_entity(treewalk_trail)

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				local r = this.nav_rally
				local tw = this.treewalk
				local force_treewalk = false

				for _, p in pairs(this.nav_grid.waypoints) do
					if GR:cell_is(p.x, p.y, bor(TERRAIN_WATER, TERRAIN_SHALLOW, TERRAIN_NOWALK)) then
						force_treewalk = true

						break
					end
				end

				if force_treewalk or V.dist(this.pos.x, this.pos.y, r.pos.x, r.pos.y) > tw.min_distance then
					r.new = false

					U.unblock_target(store, this)
					U.bans_add(this.vis, F_ALL)

					this.health.immune_to = F_ALL

					U.speed_inc_self(this, tw.extra_speed)

					this.unit.marker_hidden = true
					this.health_bar.hidden = true

					S:queue(this.sound_events.change_rally_point)
					S:queue(this.treewalk.sound)

					treewalk_trail.particle_system.emit = true

					::label_283_0::

					local dest = r.pos
					local n = this.nav_grid

					while not V.veq(this.pos, dest) do
						local w = table.remove(n.waypoints, 1) or dest

						U.set_destination(this, w)

						local an, af = U.animation_name_facing_point(this, tw.animations[1], this.motion.dest)

						U.animation_start_default(this, an, af, store.tick_ts, true)

						while not this.motion.arrived do
							if r.new then
								r.new = false

								goto label_283_0
							end

							U.walk_off__accel__unsnapped(this, store.tick_length)
							coroutine.yield()

							this.motion.speed.x, this.motion.speed.y = 0, 0
						end
					end

					treewalk_trail.particle_system.emit = false

					S:stop(this.treewalk.sound)
					SU.hide_modifiers(store, this, true)
					U.y_animation_play(this, tw.animations[2], nil, store.tick_ts)
					SU.show_modifiers(store, this, true)
					U.speed_dec_self(this, tw.extra_speed)
					U.bans_remove(this.vis, F_ALL)

					this.health.immune_to = 0
					this.unit.marker_hidden = nil
					this.health_bar.hidden = nil
				elseif SU.y_hero_new_rally(store, this) then
					goto label_283_1
				end
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local enemy = find_target_at_critical_moment(this, this.ranged.attacks[1].max_range, F_RANGED, F_NONE, nil, true, true)

				if enemy and enemy.pos then
					U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
					S:queue(this.sound_events.change_rally_point)

					local ultimate_entity = E:create_entity(this.hero.skills.ultimate.controller_name)

					ultimate_entity.damage_factor = this.unit.damage_factor
					ultimate_entity.pos = V.vclone(enemy.pos)
					ultimate_entity.level = this.hero.skills.ultimate.level

					simulation:queue_insert_entity(ultimate_entity)

					this.ultimate.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			skill = this.hero.skills.sentinel_wisps
			a = this.timed_attacks.list[1]

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local enemies = U.find_enemies_in_range_filter_off(this.pos, a.max_range_trigger, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < a.min_targets then
					a.ts = a.ts + fts(10)
				else
					local start_ts = store.tick_ts

					S:queue(a.sound)
					U.animation_start_default(this, a.animation, nil, store.tick_ts, false)

					if SU.y_soldier_wait(store, this, a.cast_time) then
						goto label_283_1
					end

					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, skill)

					local positions = distribute_summons(this.pos.x, this.pos.y, a.max_summons)

					for i, pos in ipairs(positions) do
						local e = E:create_entity(a.entity)

						e.pos = pos
						e.owner_id = this.id
						e.wisp_order = i

						simulation:queue_insert_entity(e)
					end

					SU.y_hero_animation_wait(this)
				end
			end

			skill = this.hero.skills.leaf_whirlwind
			a = this.timed_attacks.list[2]

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local enemies = U.find_enemies_in_range_filter_off(this.pos, a.max_range_trigger, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < a.min_targets then
					a.ts = a.ts + fts(10)
				else
					local start_ts = store.tick_ts

					S:queue(a.sound)

					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, skill)

					local aura = E:create_entity(a.aura)

					aura.aura.source_id = this.id
					aura.aura.ts = store.tick_ts
					aura.pos = this.pos

					simulation:queue_insert_entity(aura)

					local aura_decal = E:create_entity(a.aura_decal)

					aura_decal.duration = aura.aura.duration
					aura_decal.pos = this.pos
					aura_decal.source_id = this.id

					simulation:queue_insert_entity(aura_decal)

					local mod = E:create_entity(a.mod)

					mod.modifier.source_id = this.id
					mod.modifier.target_id = this.id

					simulation:queue_insert_entity(mod)
				end
			end

			skill = this.hero.skills.faery_dust
			a = this.timed_attacks.list[3]

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local _, enemies = U.find_foremost_enemy_in_range_filter_off(this.pos, a.max_range_trigger, false, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < a.min_targets then
					a.ts = a.ts + fts(10)
				else
					local aim_target, _ = U.find_entity_most_surrounded(enemies)
					local start_ts = store.tick_ts

					S:queue(a.sound)

					local an, af = U.animation_name_facing_point(this, a.animation, aim_target.pos)

					U.animation_start_default(this, an, af, store.tick_ts, false)

					if SU.y_soldier_wait(store, this, a.cast_time) then
						goto label_283_1
					end

					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, skill)

					local _, enemies = U.find_foremost_enemy_in_range_filter_off(this.pos, a.max_range_effect, false, a.vis_flags, a.vis_bans)

					if enemies then
						aim_target, _ = U.find_entity_most_surrounded(enemies)
					end

					local aura = E:create_entity(a.aura)

					aura.aura.source_id = this.id
					aura.aura.ts = store.tick_ts
					aura.aura.level = skill.level

					local ni = aim_target.nav_path.ni + P:predict_enemy_node_advance(aim_target, a.node_prediction)

					aura.pos = P:node_pos(aim_target.nav_path.pi, 1, ni)
					aura.pos_pi = aim_target.nav_path.pi
					aura.pos_ni = ni

					simulation:queue_insert_entity(aura)
					SU.y_hero_animation_wait(this)
				end
			end

			skill = this.hero.skills.verdant_blast
			a = this.timed_attacks.list[4]

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local enemies = U.find_enemies_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not enemies then
					a.ts = a.ts + fts(10)
				else
					local start_ts = store.tick_ts
					local enemy = enemies[1]
					local enemy_pos = V.vclone(enemy.pos)

					S:queue(a.sound)

					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, skill)

					local an, af, _ = U.animation_name_facing_point(this, a.animation, enemy_pos)

					U.animation_start_default(this, an, af, store.tick_ts, false)

					if SU.y_soldier_wait(store, this, a.shoot_time) then
						goto label_283_1
					end

					enemies = U.find_enemies_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

					if enemies and #enemies > 0 then
						enemy = enemies[1]
						enemy_pos = V.vclone(enemy.pos)
					end

					local flip_x = enemy_pos.x - this.pos.x < 0

					this.render.sprites[1].flip_x = flip_x

					local flying = U.flag_has(enemy.vis.flags, F_FLYING)

					shoot_bullet(a, enemy, enemy_pos, flying)

					for _, aa in ipairs(this.ranged.attacks) do
						aa.ts = store.tick_ts
					end

					SU.y_hero_animation_wait(this)
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			elseif SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
				-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_283_1::

		coroutine.yield()
	end
end

local function hero_muyrn_ultimate_update(this, store)
	local aura = E:create_entity(this.aura)

	aura.aura.source_id = this.id
	aura.aura.ts = store.tick_ts
	aura.aura.level = this.level

	local available_paths = {}

	for k, v in pairs(P.paths) do
		table.insert(available_paths, k)
	end

	if store.level.ignore_walk_backwards_paths then
		available_paths = table.filter(available_paths, function(k, v)
			return not table.contains(store.level.ignore_walk_backwards_paths, v) and P:is_path_active(v)
		end)
	end

	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, available_paths, nil, true)

	if #nodes < 1 then
		return nil
	end

	local pi, spi, ni = unpack(nodes[1])
	local npos = P:node_pos(pi, spi, ni)

	aura.pos = npos
	aura.pos_pi = pi
	aura.pos_ni = ni

	local aura_left = E:create_entity(this.aura_sides)

	aura_left.aura.source_id = this.id
	aura_left.aura.ts = store.tick_ts
	aura_left.aura.level = this.level

	local npos = P:node_pos(pi, spi, ni + 5)

	aura_left.pos = npos
	aura_left.pos_pi = pi
	aura_left.pos_ni = ni

	local aura_right = E:create_entity(this.aura_sides)

	aura_right.aura.source_id = this.id
	aura_right.aura.ts = store.tick_ts
	aura_right.aura.level = this.level

	local npos = P:node_pos(pi, spi, ni - 5)

	aura_right.pos = npos
	aura_right.pos_pi = pi
	aura_right.pos_ni = ni

	S:queue(this.sounds[this.level])
	simulation:queue_insert_entity(aura)
	simulation:queue_insert_entity(aura_left)
	simulation:queue_insert_entity(aura_right)
	simulation:queue_remove_entity(this)
end

tt = E:register_t("hero_muyrn", "hero")

E:add_comps(tt, "melee", "ranged", "timed_attacks")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {162, 175, 188, 201, 214, 226, 240, 253, 266, 279}
tt.hero.level_stats.melee_damage_max = {10, 11, 12, 13, 14, 16, 17, 18, 19, 20}
tt.hero.level_stats.melee_damage_min = {6, 7, 8, 9, 10, 10, 11, 12, 13, 14}
tt.hero.level_stats.ranged_damage_max = {27, 30, 33, 36, 39, 42, 45, 47, 50, 53}
tt.hero.level_stats.ranged_damage_min = {17, 19, 21, 23, 25, 27, 29, 31, 33, 35}
tt.hero.skills.sentinel_wisps = E:clone_c("hero_skill")
tt.hero.skills.sentinel_wisps.cooldown = {17.5, 17.5, 17.5}
tt.hero.skills.sentinel_wisps.max_summons = {1, 2, 3}
tt.hero.skills.sentinel_wisps.wisp_damage_max = {6, 12, 18}
tt.hero.skills.sentinel_wisps.wisp_damage_min = {3, 6, 9}
tt.hero.skills.sentinel_wisps.wisp_duration = {6, 6, 6}
tt.hero.skills.sentinel_wisps.xp_gain = {140, 280, 420}
tt.hero.skills.sentinel_wisps.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.verdant_blast = E:clone_c("hero_skill")
tt.hero.skills.verdant_blast.cooldown = {22.5, 22.5, 22.5}
tt.hero.skills.verdant_blast.damage_max = {150, 300, 450}
tt.hero.skills.verdant_blast.damage_min = {150, 300, 450}
tt.hero.skills.verdant_blast.xp_gain = {168, 336, 504}
tt.hero.skills.verdant_blast.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.leaf_whirlwind = E:clone_c("hero_skill")
tt.hero.skills.leaf_whirlwind.cooldown = {25, 23.5, 21}
tt.hero.skills.leaf_whirlwind.duration = {8, 8, 8}
tt.hero.skills.leaf_whirlwind.damage_max = {4, 8, 12}
tt.hero.skills.leaf_whirlwind.damage_min = {2, 4, 6}
tt.hero.skills.leaf_whirlwind.heal_min = {2, 3, 4}
tt.hero.skills.leaf_whirlwind.heal_max = {3, 4, 5}
tt.hero.skills.leaf_whirlwind.xp_gain = {224, 448, 672}
tt.hero.skills.leaf_whirlwind.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.faery_dust = E:clone_c("hero_skill")
tt.hero.skills.faery_dust.cooldown = {14, 14, 14}
tt.hero.skills.faery_dust.damage_factor = {0.4, 0.25, 0.1}
tt.hero.skills.faery_dust.duration = {5, 6, 8}
tt.hero.skills.faery_dust.xp_gain = {140, 280, 420}
tt.hero.skills.faery_dust.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_muyrn_ultimate"
tt.hero.skills.ultimate.slow_factor = {0.6, 0.6, 0.6, 0.6}
tt.hero.skills.ultimate.damage_min = {4, 5, 6, 7}
tt.hero.skills.ultimate.damage_max = {6, 7, 9, 11}
tt.hero.skills.ultimate.cooldown = {32, 32, 32, 32}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.xp_gain_factor = 32
tt.health.dead_lifetime = 15
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_muyrn_level_up
tt.info.hero_portrait = "kr5_hero_portraits_0003"
tt.info.portrait = "kr5_info_portraits_heroes_0003"
tt.main_script.update = hero_muyrn_update
tt.motion.max_speed = 75
tt.regen.cooldown = 1
tt.sound_events.change_rally_point = "HeroNyruTaunt"
tt.sound_events.death = "HeroNyruDeath"
tt.sound_events.respawn = "HeroNyruTauntIntro"
tt.sound_events.hero_room_select = "HeroNyruTauntSelect"
tt.soldier.melee_slot_offset = v(10, 0)
tt.health_bar.offset = v(0, 38)
tt.unit.hit_offset = v(0, 16)
tt.unit.mod_offset = v(0, 22)
tt.ui.click_rect = r(-25, -3, 50, 43)
tt.treewalk = {}
tt.treewalk.min_distance = 75
tt.treewalk.extra_speed = 95
tt.treewalk.animations = {"treewalk", "treewalk_end"}
tt.treewalk.trail = "hero_muyrn_treewalk_trail"
tt.treewalk.sound = "HeroNyruTreewalk"
tt.render.sprites[1].prefix = "hero_nyru_muyrn"
tt.render.sprites[1].angles.ranged = {"shoot", "shootUp", "shoot"}
tt.render.sprites[1].angles_custom = {
	ranged = {45, 135, 210, 315}
}
tt.render.sprites[1].angles_flip_vertical = {
	ranged = true
}
tt.render.sprites[1].scale = v(1.15, 1.15)
tt.render.sprites[1].draw_order = DO_HEROES
tt.melee.range = 72
tt.melee.attacks[1] = E:clone_c("melee_attack")
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].hit_fx = "hero_muyrn_melee_attack_hit_fx"
tt.melee.attacks[1].hit_offset = v(24, 0)
tt.melee.attacks[1].sound = "HeroNyruBasicAttackMelee"
tt.melee.attacks[1].xp_gain_factor = 2
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].animation = "melee_attack"
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].max_range = 180
tt.ranged.attacks[1].min_range = 68
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].bullet = "hero_muyrn_bullet"
tt.ranged.attacks[1].bullet_start_offset = {v(12, 32)}
tt.ranged.attacks[1].shoot_time = fts(7)
tt.ranged.attacks[1].animation = "ranged_attack"
tt.ranged.attacks[1].sound = "HeroNyruBasicAttackRanged"
tt.ranged.attacks[1].basic_attack = true
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "sentinel_wisps"
tt.timed_attacks.list[1].max_range_trigger = 200
tt.timed_attacks.list[1].min_targets = 1
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].cast_time = fts(6)
tt.timed_attacks.list[1].xp_from_skill = "sentinel_wisps"
tt.timed_attacks.list[1].sound = "HeroNyruSentinelWispsCast"
tt.timed_attacks.list[1].entity = "hero_muyrn_sentinel_wisps_entity"
tt.timed_attacks.list[2] = E:clone_c("custom_attack")
tt.timed_attacks.list[2].max_range_trigger = 60
tt.timed_attacks.list[2].min_targets = 1
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].cast_time = fts(5)
tt.timed_attacks.list[2].xp_from_skill = "leaf_whirlwind"
tt.timed_attacks.list[2].sound = "HeroNyruLeafWhirlwindCast"
tt.timed_attacks.list[2].aura = "hero_muyrn_leaf_whirlwind_aura"
tt.timed_attacks.list[2].aura_decal = "hero_muyrn_leaf_whirlwind_decal"
tt.timed_attacks.list[2].mod = "hero_muyrn_leaf_whirlwind_heal_mod"
tt.timed_attacks.list[2].vis_flags = F_RANGED
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[3] = E:clone_c("aura_attack")
tt.timed_attacks.list[3].animation = "fairy_dust"
tt.timed_attacks.list[3].max_range_trigger = 160
tt.timed_attacks.list[3].max_range_effect = 180
tt.timed_attacks.list[3].min_targets = 1
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].cast_time = fts(10)
tt.timed_attacks.list[3].xp_from_skill = "faery_dust"
tt.timed_attacks.list[3].sound = "HeroNyruFairyDustCast"
tt.timed_attacks.list[3].aura = "aura_hero_muyrn_faery_dust"
tt.timed_attacks.list[3].vis_flags = F_RANGED
tt.timed_attacks.list[3].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[3].node_prediction = fts(10)
tt.timed_attacks.list[4] = E:clone_c("bullet_attack")
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].max_range = 300
tt.timed_attacks.list[4].min_range = 100
tt.timed_attacks.list[4].bullet = "bullet_hero_muyrn_verdant_blast"
tt.timed_attacks.list[4].bullet_start_offset = v(-7, 50)
tt.timed_attacks.list[4].animation = "verdant_blast"
tt.timed_attacks.list[4].shoot_time = fts(43)
tt.timed_attacks.list[4].node_prediction = fts(43)
tt.timed_attacks.list[4].reset_to_target_pos = true
tt.timed_attacks.list[4].sound = "HeroNyruVerdantBlastCast"
tt.ultimate = {
	ts = 0,
	cooldown = 32
}
tt = E:register_t("hero_muyrn_bullet", "bullet")

E:add_comps(tt, "force_motion")

tt.render.sprites[1].name = "hero_nyru_ranged_attack_projectile"
tt.render.sprites[1].animated = false
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.hit_fx = "hero_muyrn_bolt_hit_fx"
tt.bullet.particles_name = "hero_muyrn_bullet_trail"
tt.bullet.xp_gain_factor = 1.52
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.max_speed = 300
tt.bullet.min_speed = 30
tt.initial_impulse = 15000
tt.initial_impulse_duration = 0.15
tt.initial_impulse_angle_abs = math.pi / 2
tt.force_motion.a_step = 5
tt.force_motion.max_a = 3000
tt.force_motion.max_v = 300
tt.main_script.update = scripts.hero_muyrn_ranged_attack_bullet.update
tt = E:register_t("hero_muyrn_melee_attack_hit_fx", "fx")
tt.render.sprites[1].name = "hero_nyru_ranged_attack_hit"
tt = E:register_t("hero_muyrn_bolt_hit_fx", "fx")
tt.render.sprites[1].name = "hero_nyru_ranged_attack_hit"
tt = E:register_t("hero_muyrn_bullet_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "hero_nyru_ranged_attack_particle"
tt.particle_system.animated = true
tt.particle_system.alphas = {255, 0}
tt.particle_system.particle_lifetime = {fts(16), fts(16)}
tt.particle_system.scales_y = {0.8, 0.8}
tt.particle_system.scales_x = {0.8, 0.8}
tt.particle_system.emission_rate = 70
tt = E:register_t("hero_muyrn_sentinel_wisps_entity")

E:add_comps(tt, "main_script", "pos", "render", "force_motion", "ranged", "tween")

tt.hero_max_distance = 100
tt.flight_height = 40
tt.force_motion.max_a = 135000
tt.force_motion.max_v = 300
tt.force_motion.ramp_radius = 10
tt.main_script.insert = hero_muyrn_sentinel_wisps_entity_insert
tt.main_script.update = hero_muyrn_sentinel_wisps_entity_update
tt.ranged.attacks[1].bullet = "hero_muyrn_sentinel_wisps_entity_bullet"
tt.ranged.attacks[1].shoot_time = fts(6)
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].animation = "shoot"
tt.render.sprites[1].prefix = "hero_nyru_sentinel_wisps_wisp"
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow_hard"
tt.render.sprites[2].hidden = false
tt.render.sprites[2].scale = vv(0.5)
tt.flight_offset = 5
tt.attack_fx = "fx_hero_muyrn_sentinel_wisps_attack"
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.props[1].sprite_id = 2
tt.tween.remove = false
tt.tween.disabled = true
tt.hp = 40
tt.sound = "HeroNyruSentinelWispsSpawn"
tt = E:register_t("hero_muyrn_sentinel_wisps_entity_bullet", "bullet")
tt.image_width = 75
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].name = "hero_nyru_sentinel_wisps_ray"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0.05, 0.5)
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.hit_time = fts(4)
tt.bullet.hit_fx = "hero_muyrn_sentinel_wisps_hit_fx"
tt.sound_events.insert = "HeroNyruSentinelWispsShoot"
tt = E:register_t("hero_muyrn_verdant_blast_bolt_flying_hit_fx", "fx")
tt.render.sprites[1].name = "hero_nyru_verdant_blast_explosion_air"
tt = E:register_t("hero_muyrn_leaf_whirlwind_aura", "aura")
tt.aura.duration = nil
tt.aura.damage_type = DAMAGE_STAB
tt.aura.track_source = true
tt.aura.cycle_time = 0.25
tt.aura.radius = 50
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.vis_flags = F_RANGED
tt.main_script.update = scripts.aura_apply_damage.update
tt.aura.mods = {"hero_muyrn_leaf_whirlwind_enemy_hit_fx_mod"}
tt = E:register_t("hero_muyrn_leaf_whirlwind_enemy_hit_fx_mod", "modifier")

E:add_comps(tt, "render")

tt.render.sprites[1].name = "hero_nyru_leaf_whirlwind_hit"
tt.render.sprites[1].sort_y_offset = -1
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = fts(20)
tt = E:register_t("hero_muyrn_leaf_whirlwind_heal_mod", "modifier")

E:add_comps(tt, "hps")

tt.hps.heal_min = nil
tt.hps.heal_max = nil
tt.hps.heal_every = 0.25
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_hps.update
tt = E:register_t("hero_muyrn_leaf_whirlwind_decal", "decal_scripted")

E:add_comps(tt, "sound_events")

tt.main_script.update = hero_muyrn_leaf_whirlwind_decal_update
tt.render.sprites[1].prefix = "hero_nyru_leaf_whirlwind"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].draw_order = DO_MOD_FX
tt = E:register_t("hero_muyrn_ultimate")

E:add_comps(tt, "pos", "main_script", "sound_events")

tt.main_script.update = hero_muyrn_ultimate_update
tt.aura = "aura_hero_muyrn_ultimate"
tt.aura_sides = "aura_hero_muyrn_ultimate_sides"
tt.sounds = {"HeroNyruRootDefenderStartLvl1", "HeroNyruRootDefenderStartLvl2", "HeroNyruRootDefenderStartLvl3"}
tt = E:register_t("bullet_hero_muyrn_verdant_blast", "bolt")
tt.render.sprites[1].prefix = "hero_nyru_verdant_blast_projectile"
tt.render.sprites[1].name = "flying"
tt.bullet.damage_type = DAMAGE_MAGICAL_EXPLOSION
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.acceleration_factor = 0.1
tt.bullet.min_speed = 300
tt.bullet.max_speed = 600
tt.bullet.hit_distance = 20
tt.bullet.hide_radius = 0
tt.bullet.hit_fx = "hero_muyrn_verdant_blast_bolt_flying_hit_fx"
tt.bullet.hit_fx_flying = "hero_muyrn_verdant_blast_bolt_flying_hit_fx"
tt.bullet.hit_fx_ignore_hit_offset = true
tt.bullet.hit_decal = "decal_hero_muyrn_verdant_blast_hit"
tt.bullet.particles_name = "ps_hero_muyrn_verdant_blast_bolt_trail"
tt.sound = "HeroNyruVerdantBlastHit"
tt.main_script.update = bullet_hero_muyrn_verdant_blast_update
tt = E:register_t("aura_hero_muyrn_faery_dust", "aura")

E:add_comps(tt, "render")

tt.aura.mods = {"mod_hero_muyrn_faery_dust", "mod_hero_muyrn_faery_dust_fx"}
tt.aura.duration = fts(13)
tt.aura.cycle_time = 0.3
tt.aura.radius = 80
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_MOD)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].name = "hero_nyru_fairy_dust_decal"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0.5, 0.8)
tt = E:register_t("aura_hero_muyrn_ultimate", "aura")
tt.aura.duration = nil
tt.aura.cycle_time = 0.3
tt.aura.radius = 60
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.vis_flags = F_RANGED
tt.aura.mods = {"mod_hero_muyrn_ultimate", "mod_hero_muyrn_ultimate_damage"}
tt.root_decal = "decal_hero_muyrn_root_defender_root"
tt.roots_count = {10, 15, 20, 25}
tt.duration = {4, 5, 6, 7}
tt.main_script.insert = hero_muyrn_root_defender_aura_insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.main_script.remove = hero_muyrn_root_defender_aura_remove
tt.end_sound = "HeroNyruRootDefenderEnd"
tt = E:register_t("aura_hero_muyrn_ultimate_sides", "aura_hero_muyrn_ultimate")
tt.main_script.insert = hero_muyrn_root_defender_aura_sides_insert
tt.end_sound = "HeroNyruRootDefenderEnd"
tt = E:register_t("mod_hero_muyrn_faery_dust", "modifier")

E:add_comps(tt, "render")

tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.remove = scripts.mod_damage_factors.remove
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].name = "hero_nyru_fairy_dust_modifier"
tt.render.sprites[1].draw_order = DO_MOD_FX
tt = E:register_t("mod_hero_muyrn_faery_dust_fx", "modifier")

E:add_comps(tt, "render")

tt.main_script.insert = mod_hero_muyrn_faery_dust_fx_insert
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.use_mod_offset = false
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].name = "hero_nyru_fairy_dust_FX"
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.render.sprites[1].loop = false
tt.render.sprites[1].size_scales = {vv(0.9), vv(1), vv(1)}
tt = E:register_t("mod_hero_muyrn_ultimate", "mod_slow")
tt.modifier.duration = 1
tt.slow.factor = nil
tt = E:register_t("mod_hero_muyrn_ultimate_damage", "modifier")

E:add_comps(tt, "dps")

tt.modifier.duration = 1
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = 0.25
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt = E:register_t("hero_muyrn_treewalk_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.animation_fps = 15
tt.particle_system.name = "hero_nyru_walk2_roots_particle"
tt.particle_system.loop = false
tt.particle_system.emission_rate = 10
tt.particle_system.z = Z_OBJECTS
tt.particle_system.emit_area_spread = v(0, 5)
tt = E:register_t("ps_hero_muyrn_verdant_blast_bolt_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "hero_nyru_verdant_blast_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 60
tt.particle_system.emit_rotation_spread = math.pi * 2
tt = E:register_t("fx_hero_muyrn_sentinel_wisps_attack", "fx")
tt.render.sprites[1].name = "hero_nyru_sentinel_wisps_attack_attack"
tt.render.sprites[1].hide_after_runs = 1
tt = E:register_t("hero_muyrn_sentinel_wisps_hit_fx", "fx")
tt.render.sprites[1].name = "hero_nyru_sentinel_wisps_hit"
tt = E:register_t("decal_hero_muyrn_verdant_blast_hit", "decal")
tt.render.sprites[1].name = "hero_nyru_verdant_blast_explosion_decal"
tt.render.sprites[1].hide_after_runs = 1
