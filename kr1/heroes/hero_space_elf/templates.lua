local scripts = require("scripts")
local E = require("entity_db")
local GR = require("grid_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local bit = require("bit")
local HU = require("hero_utils")
local km = require("lib.klua.macros")
local signal = require("lib.hump.signal")
local log = require("lib.klua.log"):new("hero_scripts")
local band = bit.band
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local tt

local function mod_hero_space_elf_black_aegis_update(this, store)
	local m = this.modifier

	this.modifier.ts = store.tick_ts

	local target = store.entities[m.target_id]

	if not target or not target.pos then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos

	for i, s in ipairs(this.render.sprites) do
		if s.size_names then
			s.prefix = s.prefix .. "_" .. s.size_names[target.unit.size]
		end

		if i == 2 then
			s.name = s.prefix
		end
	end

	U.y_animation_play(this, this.animation_start, nil, store.tick_ts, false)

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or m.duration >= 0 and store.tick_ts - m.ts > m.duration or m.last_node and target.nav_path.ni > m.last_node or this.shield_broken then
			this.render.sprites[2].hidden = true

			S:queue(this.sound_explosion)
			U.animation_start_default(this, this.animation_end, nil, store.tick_ts, false)
			U.y_wait_unconditional(store, this.explosion_time)

			local targets = U.find_enemies_in_range_filter_off(this.pos, this.explosion_range, 0, bor(F_FLYING, F_CLIFF))

			if targets then
				for _, target in ipairs(targets) do
					local d = E.assign_damage(this.explosion_damage_type, this.explosion_damage * this.modifier.damage_factor, this.id, target.id)

					queue_damage(store, d)

					local fx_pos = V.vclone(target.pos)

					if target.unit and target.unit.mod_offset then
						fx_pos.x = fx_pos.x + target.unit.mod_offset.x
						fx_pos.y = fx_pos.y + target.unit.mod_offset.y
					end

					local fx = E:create_entity(m.damage_fx)

					fx.pos = fx_pos
					fx.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(fx)
				end
			end

			U.y_animation_wait_default(this)
			simulation:queue_remove_entity(this)

			return
		end

		if this.render and target.unit then
			local s = this.render.sprites[1]
			local flip_sign = 1

			if target.render then
				flip_sign = target.render.sprites[1].flip_x and -1 or 1
			end

			if m.health_bar_offset and target.health_bar then
				local hb = target.health_bar.offset
				local hbo = m.health_bar_offset

				s.offset.x, s.offset.y = hb.x + hbo.x * flip_sign, hb.y + hbo.y
			elseif m.use_mod_offset and target.unit.mod_offset then
				s.offset.x, s.offset.y = target.unit.mod_offset.x * flip_sign, target.unit.mod_offset.y
			end
		end

		U.y_animation_play(this, this.animation_loop, nil, store.tick_ts, 1)
		coroutine.yield()
	end
end

local function aura_hero_space_elf_void_rift_update(this, store)
	this.aura.ts = store.tick_ts

	local last_hit_ts = 0
	local cycles_count = 0

	U.y_animation_play(this, "in", nil, store.tick_ts, 1)

	while true do
		if this.aura.cycles then
			if cycles_count >= this.aura.cycles then
				break
			end
		elseif this.aura.duration >= 0 and store.tick_ts - this.aura.ts >= this.aura.duration then
			break
		end

		if this.aura.track_source and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if not te or te.health and te.health.dead then
				simulation:queue_remove_entity(this)

				return
			end

			if te and te.pos then
				this.pos.x, this.pos.y = te.pos.x, te.pos.y
			end
		end

		if this.ignore_damage then
		-- block empty
		elseif store.tick_ts - last_hit_ts >= this.aura.cycle_time then
			cycles_count = cycles_count + 1
			last_hit_ts = store.tick_ts

			local targets = table.filter(store.enemies, function(k, v)
				return not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)
			end)

			for _, target in ipairs(targets) do
				local dmin, dmax = this.aura.damage_min, this.aura.damage_max

				if this.aura.damage_inc then
					dmin = dmin + this.aura.damage_inc * this.aura.level
					dmax = dmax + this.aura.damage_inc * this.aura.level
				end

				local d = E.assign_damage(this.aura.damage_type, math.random(dmin, dmax) * this.aura.damage_factor, this.id, target.id)

				d.track_damage = this.aura.track_damage
				d.xp_dest_id = this.aura.xp_dest_id
				d.xp_gain_factor = this.aura.xp_gain_factor

				queue_damage(store, d)

				local mods = this.aura.mods or {this.aura.mod}

				for _, mod_name in ipairs(mods) do
					local m = E:create_entity(mod_name)

					m.modifier.level = this.aura.level
					m.modifier.target_id = target.id
					m.modifier.source_id = this.id
					m.modifier.damage_factor = this.aura.damage_factor

					if this.aura.hide_source_fx and target.id == this.aura.source_id then
						m.render = nil
					end

					simulation:queue_insert_entity(m)
				end
			end
		end

		U.animation_start_default(this, "idle", nil, store.tick_ts, true)
		coroutine.yield()
	end

	U.y_animation_play(this, "out", nil, store.tick_ts, 1)
	simulation:queue_remove_entity(this)
end

local function hero_space_elf_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	upgrade_skill(this, "astral_reflection", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.entity = string.format("%s_%i", a.entity_prefix, s.level)
	end)
	upgrade_skill(this, "black_aegis", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local m = E:get_template(a.mod)

		m.modifier.duration = s.duration[s.level]
		m.shield_max_damage = s.shield_base[s.level]
		m.explosion_damage = s.explosion_damage[s.level]
	end)
	upgrade_skill(this, "void_rift", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local aura = E:get_template(a.aura)

		aura.aura.duration = s.duration[s.level]
		aura.aura.damage_max = s.damage_max[s.level]
		aura.aura.damage_min = s.damage_min[s.level]
	end)
	upgrade_skill(this, "spatial_distortion", function(this, s)
		local a = this.timed_attacks.list[4]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local modifier = E:get_template(a.mod)

		modifier.modifier.duration = s.duration[s.level]
		modifier.range_factor = s.range_factor[s.level]
		modifier.damage_factor = s.damage_factor[s.level]
		modifier.cooldown_factor = s.cooldown_factor[s.level]
		modifier.tween.props[1].keys[2][1] = modifier.fade_duration
		modifier.tween.props[1].keys[3][1] = s.duration[s.level] - modifier.fade_duration
		modifier.tween.props[1].keys[4][1] = s.duration[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		local u = this.hero.skills.ultimate
		local uc = E:get_template(u.controller_name)
		local modifier = E:get_template(uc.entity)

		modifier.modifier.duration = s.duration[s.level]
		modifier.damage = s.damage[s.level]
		this.ultimate.disabled = nil
		this.ultimate.cooldown = s.cooldown[s.level]
	end)
	update_hp(this)

	this.hero.melee_active_status = {}

	for index, attack in ipairs(this.melee.attacks) do
		this.hero.melee_active_status[index] = attack.disabled
	end
end

local function hero_space_elf_insert(this, store)
	this.hero.fn_level_up(this, store)

	this.melee.order = U.attack_order(this.melee.attacks)
	this.ranged.order = U.attack_order(this.ranged.attacks)

	return true
end

local function hero_space_elf_update(this, store)
	local h = this.health
	local brk, sta, a, skill
	local astral_reflection_attack = this.timed_attacks.list[1]
	local black_aegis_attack = this.timed_attacks.list[2]
	local void_rift_attack = this.timed_attacks.list[3]
	local spatial_distortion_attack = this.timed_attacks.list[4]
	local last_ts = store.tick_ts

	if not astral_reflection_attack.disabled then
		astral_reflection_attack.ts = store.tick_ts - astral_reflection_attack.cooldown
	end

	if not black_aegis_attack.disabled then
		black_aegis_attack.ts = store.tick_ts - black_aegis_attack.cooldown
	end

	if not void_rift_attack.disabled then
		void_rift_attack.ts = store.tick_ts - void_rift_attack.cooldown
	end

	if not spatial_distortion_attack.disabled then
		spatial_distortion_attack.ts = store.tick_ts - spatial_distortion_attack.cooldown
	end

	local function astral_reflection_spawn_pos(x, y)
		local nodes = P:nearest_nodes(x, y, nil, nil, true)

		if #nodes < 1 then
			log.debug("cannot insert summons, no valid nodes nearby %s,%s", x, y)

			return nil
		end

		local opi, ospi, ni = unpack(nodes[1])
		local spi = km.zmod(ospi + 1, 3)
		local npos = P:node_pos(opi, spi, ni - 1)

		if P:is_node_valid(opi, ni - 1) and band(GR:cell_type(npos.x, npos.y), bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK)) == 0 then
			return npos
		end

		return nil
	end

	local function y_hero_space_elf_new_rally(store, this)
		local r = this.nav_rally

		if r.new then
			r.new = false

			U.unblock_target(store, this)

			if this.sound_events then
				S:queue(this.sound_events.change_rally_point)
			end

			if SU.hero_will_teleport(this, r.pos) then
				local tp = this.teleport

				tp.pending = true

				U.set_destination(this, r.pos)
				U.bans_add(this.vis, F_ALL)

				this.health.ignore_damage = true
				this.health_bar.hidden = true

				S:queue(tp.sound_in)

				if tp.fx_out then
					local fx = E:create_entity(tp.fx_out)

					fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
					fx.render.sprites[1].ts = store.tick_ts

					if fx.tween then
						fx.tween.ts = store.tick_ts
					end

					simulation:queue_insert_entity(fx)
				end

				local an, af = U.animation_name_facing_point(this, tp.animations[1], r.pos)

				U.animation_start(this, an, af, store.tick_ts, false, nil)
				SU.y_hero_animation_wait(this)

				if tp.delay > 0 then
					U.sprites_hide(this, nil, nil, true)
					U.y_wait_unconditional(store, tp.delay)
					U.sprites_show(this, nil, nil, true)
				end

				this.pos.x, this.pos.y = r.pos.x, r.pos.y
				this.motion.speed.x, this.motion.speed.y = 0, 0

				if tp.fx_in then
					local fx = E:create_entity(tp.fx_in)

					fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
					fx.render.sprites[1].ts = store.tick_ts

					if fx.tween then
						fx.tween.ts = store.tick_ts
					end

					simulation:queue_insert_entity(fx)
				end

				S:queue(tp.sound_out)
				U.y_animation_play(this, tp.animations[2], nil, store.tick_ts)

				tp.pending = false
				this.health_bar.hidden = false

				U.bans_remove(this.vis, F_ALL)

				this.health.ignore_damage = false

				return false
			elseif SU.hero_will_transfer(this, r.pos) then
				local tr = this.transfer
				local interrupt = false
				local ps

				U.bans_add(this.vis, F_ALL)

				this.health.ignore_damage = true
				this.health_bar.hidden = true

				S:queue(tr.sound_loop)

				local an, af = U.animation_name_facing_point(this, tr.animations[2], r.pos)

				U.animation_start(this, an, af, store.tick_ts, false, nil)
				U.speed_inc_self(this, tr.extra_speed)

				if tr.particles_name then
					ps = E:create_entity(tr.particles_name)
					ps.particle_system.track_id = this.id

					simulation:queue_insert_entity(ps)
				end

				local first_time = true

				::label_244_0::

				if not first_time then
					local an, af = U.animation_name_facing_point(this, tr.animations[2], r.pos)

					U.animation_start(this, an, af, store.tick_ts, true, 1, true)
				end

				local dest = r.pos
				local n = this.nav_grid

				while not V.veq(this.pos, dest) do
					local w = table.remove(n.waypoints, 1) or dest

					U.set_destination(this, w)

					local runs = this.render.sprites[1].runs

					while not this.motion.arrived do
						if r.new then
							if SU.hero_will_teleport(this, r.pos) then
								return y_hero_space_elf_new_rally(store, this)
							else
								r.new = false
								first_time = false

								goto label_244_0
							end
						end

						U.walk_off__accel__unsnapped(this, store.tick_length)
						coroutine.yield()

						this.motion.speed.x, this.motion.speed.y = 0, 0

						if this.render.sprites[1].runs ~= runs then
							local an, af = U.animation_name_facing_point(this, tr.animations[2], this.motion.dest)

							U.animation_start(this, an, af, store.tick_ts, true, 1, true)

							runs = this.render.sprites[1].runs
						end
					end
				end

				if tr.particles_name then
					ps.particle_system.emit = false
					ps.particle_system.source_lifetime = 1
				end

				U.speed_dec_self(this, tr.extra_speed)
				S:stop(tr.sound_loop)
				U.y_animation_play(this, tr.animations[3], nil, store.tick_ts)

				this.health_bar.hidden = false

				U.bans_remove(this.vis, F_ALL)

				this.health.ignore_damage = false

				return interrupt
			end
		end
	end

	local function spatial_distortion_get_towers(a)
		local targets = table.filter(store.towers, function(k, v)
			return not v.pending_removal and not v.tower.blocked and not U.has_modifiers(store, v, a.mod) and v.tower.can_be_mod
		end)

		if targets and #targets > 0 then
			return targets
		end

		return nil
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
	U.animation_start_default(this, "idle", nil, store.tick_ts, true)

	this.health_bar.hidden = false

	local function ultimate_filter_fn(e)
		return not e.unit.is_stunned
	end

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if y_hero_space_elf_new_rally(store, this) then
					goto label_242_0
				end
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local target = find_target_at_critical_moment(this, this.ranged.attacks[1].max_range, F_RANGED, bor(F_BOSS, F_FLYING), ultimate_filter_fn, false, false)

				if target and U.has_valid_rally_node_nearby(target.pos) then
					U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
					S:queue(this.sound_events.change_rally_point)

					local e = E:create_entity(this.hero.skills.ultimate.controller_name)

					e.pos.x, e.pos.y = target.pos.x, target.pos.y
					e.damage_factor = this.unit.damage_factor
					e.level = this.hero.skills.ultimate.level

					simulation:queue_insert_entity(e)

					this.ultimate.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.astral_reflection

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) and store.tick_ts - last_ts > a.min_cooldown then
				local targets = U.find_enemies_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

				if not targets or #targets == 0 then
					a.ts = a.ts + fts(10)
				else
					local pos = astral_reflection_spawn_pos(this.pos.x, this.pos.y)

					if not pos then
						a.ts = a.ts + fts(10)
					else
						local start_ts = store.tick_ts
						local an, af = U.animation_name_facing_point(this, a.animation, pos)

						U.animation_start(this, an, af, store.tick_ts, false, nil)
						S:queue(a.sound)

						if SU.y_soldier_wait(store, this, a.cast_time) then
							goto label_242_0
						end

						local e = E:create_entity(a.entity)

						SU.insert_unit_damage_factor_buff(e, this.unit.damage_factor - e.unit.damage_factor)

						e.pos = pos
						e.nav_rally.center = V.vclone(e.pos)
						e.nav_rally.pos = V.vclone(e.pos)
						e.melee.attacks[1].xp_dest_id = this.id
						e.render.sprites[1].flip_x = math.random() < 0.5

						simulation:queue_insert_entity(e)

						e.owner = this

						SU.y_hero_animation_wait(this)

						a.ts = start_ts
						last_ts = a.ts

						SU.hero_gain_xp_from_skill(this, skill)
					end
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.black_aegis

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) and store.tick_ts - last_ts > a.min_cooldown then
				local targets = U.find_soldiers_in_range(store.soldiers, this.pos, 0, a.range, a.vis_flags, a.vis_bans, function(e)
					return e.soldier.target_id
				end)

				if not targets or #targets == 0 then
					a.ts = a.ts + fts(10)
				else
					local start_ts = store.tick_ts
					local an, af = U.animation_name_facing_point(this, a.animation, targets[1].pos)

					U.animation_start(this, an, af, store.tick_ts, false, nil)

					if SU.y_soldier_wait(store, this, a.cast_time) then
					-- block empty
					else
						S:queue(a.sound)

						a.ts = start_ts
						last_ts = a.ts

						SU.hero_gain_xp_from_skill(this, skill)

						targets = U.find_soldiers_in_range(store.soldiers, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

						if targets then
							for i = 1, #targets do
								local target = targets[i]
								local m = E:create_entity(a.mod)

								m.modifier.source_id = this.id
								m.modifier.target_id = target.id

								simulation:queue_insert_entity(m)
							end
						end

						SU.y_hero_animation_wait(this)
					end

					goto label_242_0
				end
			end

			a = this.timed_attacks.list[3]
			skill = this.hero.skills.void_rift

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) and store.tick_ts - last_ts > a.min_cooldown then
				local enemies = U.find_enemies_in_range_filter_off(this.pos, a.max_range_trigger, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < a.min_targets then
					a.ts = a.ts + fts(10)
				else
					local start_ts = store.tick_ts
					local an, af = U.animation_name_facing_point(this, a.animation, enemies[1].pos)

					U.animation_start(this, an, af, store.tick_ts, false, nil)

					if SU.y_soldier_wait(store, this, a.cast_time) then
						goto label_242_0
					end

					S:queue(a.sound)

					a.ts = start_ts
					last_ts = a.ts

					SU.hero_gain_xp_from_skill(this, skill)

					local target = U.find_foremost_enemy_in_range_filter_off(this.pos, a.max_range_effect, false, a.vis_flags, a.vis_bans)

					if target and not target.health.dead then
						local ni = target.nav_path.ni + P:predict_enemy_node_advance(target, a.predict)
						local last_node_pos
						local decal = E:create_entity(a.cast_decal)

						decal.pos = this.pos
						decal.render.sprites[1].ts = store.tick_ts
						decal.tween.ts = store.tick_ts

						simulation:queue_insert_entity(decal)

						local cracks_fade = 2
						local distance_index = ni
						local aura = E:create_entity(a.aura)

						aura.aura.source_id = this.id
						aura.aura.ts = store.tick_ts
						aura.aura.damage_factor = this.unit.damage_factor
						aura.ignore_damage = true

						for _, s in ipairs(aura.render.sprites) do
							s.scale = V.v(1, 1)

							local scale = math.random(6, 8) * 0.1

							s.scale.x, s.scale.y = scale, scale
						end

						aura.render.sprites[3].alpha = 150

						local pos = P:node_pos(target.nav_path.pi, 1, distance_index)

						distance_index = distance_index - a.border_cracks_distance

						aura.pos:copy(pos)

						last_node_pos = pos

						simulation:queue_insert_entity(aura)
						U.y_wait_unconditional(store, fts(cracks_fade))

						local aura_2 = E:create_entity(a.aura)

						aura_2.aura.source_id = this.id
						aura_2.aura.ts = store.tick_ts
						aura_2.ignore_damage = true
						aura_2.aura.damage_factor = this.unit.damage_factor

						for _, s in ipairs(aura_2.render.sprites) do
							s.scale = V.v(1, 1)

							local scale = math.random(4, 5) * 0.1

							s.scale.x, s.scale.y = scale, scale
						end

						aura_2.render.sprites[3].alpha = 100

						local pos = P:node_pos(target.nav_path.pi, 1, distance_index)

						distance_index = distance_index - a.border_cracks_distance

						aura_2.pos:copy(pos)

						last_node_pos = pos

						simulation:queue_insert_entity(aura_2)
						U.y_wait_unconditional(store, fts(cracks_fade))

						for i = 1, skill.cracks_amount[skill.level] do
							local aura = E:create_entity(a.aura)

							aura.aura.source_id = this.id
							aura.aura.ts = store.tick_ts
							aura.aura.damage_factor = this.unit.damage_factor

							local pos = P:node_pos(target.nav_path.pi, 1, distance_index)

							distance_index = distance_index - a.cracks_distance

							local length1 = V.dist(pos.x, pos.y, last_node_pos.x, last_node_pos.y)
							local v1 = V.v(last_node_pos.x - pos.x, last_node_pos.y - pos.y)

							v1.x = v1.x / length1
							v1.y = v1.y / length1

							local v1perpendicular = V.v(v1.y, -v1.x)

							pos.x = pos.x + v1perpendicular.x * a.crack_offset * km.rand_sign()
							pos.y = pos.y + v1perpendicular.y * a.crack_offset * km.rand_sign()
							aura.pos = pos
							last_node_pos = pos

							simulation:queue_insert_entity(aura)
							U.y_wait_unconditional(store, fts(cracks_fade))
						end

						aura = E:create_entity(a.aura)
						aura.aura.source_id = this.id
						aura.aura.ts = store.tick_ts
						aura.aura.damage_factor = this.unit.damage_factor
						aura.ignore_damage = true

						for _, s in ipairs(aura.render.sprites) do
							s.scale = V.v(1, 1)

							local scale = math.random(6, 8) * 0.1

							s.scale.x, s.scale.y = scale, scale
						end

						aura.render.sprites[3].alpha = 150
						distance_index = distance_index + a.cracks_distance - a.border_cracks_distance

						local pos = P:node_pos(target.nav_path.pi, 1, distance_index)

						distance_index = distance_index - a.border_cracks_distance

						local length1 = V.dist(pos.x, pos.y, last_node_pos.x, last_node_pos.y)
						local v1 = V.v(last_node_pos.x - pos.x, last_node_pos.y - pos.y)

						v1.x = v1.x / length1
						v1.y = v1.y / length1

						local v1perpendicular = V.v(v1.y, -v1.x)

						pos.x = pos.x + v1perpendicular.x * a.crack_offset * km.rand_sign()
						pos.y = pos.y + v1perpendicular.y * a.crack_offset * km.rand_sign()
						aura.pos = pos
						last_node_pos = pos

						simulation:queue_insert_entity(aura)
						U.y_wait_unconditional(store, fts(cracks_fade))

						aura = E:create_entity(a.aura)
						aura.aura.source_id = this.id
						aura.aura.ts = store.tick_ts
						aura.ignore_damage = true

						for _, s in ipairs(aura.render.sprites) do
							s.scale = V.v(1, 1)

							local scale = math.random(4, 5) * 0.1

							s.scale.x, s.scale.y = scale, scale
						end

						aura.render.sprites[3].alpha = 100

						local pos = P:node_pos(target.nav_path.pi, 1, distance_index)
						local length1 = V.dist(pos.x, pos.y, last_node_pos.x, last_node_pos.y)
						local v1 = V.v(last_node_pos.x - pos.x, last_node_pos.y - pos.y)

						v1.x = v1.x / length1
						v1.y = v1.y / length1

						local v1perpendicular = V.v(v1.y, -v1.x)

						pos.x = pos.x + v1perpendicular.x * a.crack_offset * km.rand_sign()
						pos.y = pos.y + v1perpendicular.y * a.crack_offset * km.rand_sign()
						aura.pos = pos
						last_node_pos = pos

						simulation:queue_insert_entity(aura)
					end

					SU.y_hero_animation_wait(this)
				end
			end

			a = this.timed_attacks.list[4]
			skill = this.hero.skills.spatial_distortion

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) and store.tick_ts - last_ts > a.min_cooldown and store.wave_group_number > 0 then
				local towers = spatial_distortion_get_towers(a)

				if not towers then
					a.ts = a.ts + fts(10)
				else
					local start_ts = store.tick_ts

					S:queue(a.sound)
					U.animation_start(this, a.animation, nil, store.tick_ts, false, nil)

					if SU.y_soldier_wait(store, this, a.cast_time) then
						goto label_242_0
					end

					a.ts = start_ts
					last_ts = a.ts

					SU.hero_gain_xp_from_skill(this, skill)

					local towers = spatial_distortion_get_towers(a)

					if not towers then
					-- block empty
					else
						for _, t in pairs(towers) do
							local mod = E:create_entity(a.mod)

							mod.modifier.level = skill.level
							mod.modifier.target_id = t.id
							mod.modifier.source_id = this.id

							for k, v in pairs(mod.offset_y_per_tower) do
								if string.find(t.template_name, k, 1, true) then
									mod.render.sprites[1].offset.y = v
								end
							end

							simulation:queue_insert_entity(mod)
						end

						SU.y_hero_animation_wait(this)
					end
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			else
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
				-- block empty
				elseif SU.soldier_go_back_step(store, this) then
				-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_242_0::

		coroutine.yield()
	end
end

local function mod_hero_space_elf_ultimate_update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.health or target.health.dead then
		simulation:queue_remove_entity(this)

		return
	end

	m.ts = store.tick_ts
	this.pos.x, this.pos.y = target.pos.x, target.pos.y
	this.render.sprites[1].offset.y = target.unit.hit_offset.y

	local s = this.render.sprites[1]

	if s.size_names then
		s.prefix = s.prefix .. "_" .. s.size_names[target.unit.size]
	end

	s.hidden = true

	local es = E:create_entity(this.decal)

	this._decal_timelapse = es
	es.pos.x, es.pos.y = target.pos.x, target.pos.y
	es.render = U.render_clone(target.render)

	local tween_keys = es.tween.props[1].keys

	for i, s in ipairs(es.render.sprites) do
		es.tween.props[i] = E:clone_c("tween_prop")
		es.tween.props[i].keys = tween_keys
		es.tween.props[i].sprite_id = i
	end

	simulation:queue_insert_entity(es)
	U.y_wait_unconditional(store, fts(1))
	U.unblock_all(store, target)

	if target.health_bar then
		target.health_bar.hidden = true
	end

	U.sprites_hide(target, nil, nil, true)
	SU.hide_modifiers(store, target, true, this)
	SU.hide_auras(store, target, true)

	this.tween.ts = store.tick_ts

	local tween_levitate = this.tween.props[2]

	es.tween.ts = store.tick_ts
	es.tween.disabled = false

	U.y_wait_unconditional(store, fts(math.random(1, 8)))

	s.hidden = false

	U.animation_start(this, "in", nil, store.tick_ts, false, 1)
	U.y_animation_wait_default(this)

	tween_levitate.keys[1][2].y = this.render.sprites[1].offset.y
	tween_levitate.keys[2][2].y = this.render.sprites[1].offset.y + tween_levitate.keys[2][2].y
	tween_levitate.keys[3][2].y = this.render.sprites[1].offset.y
	tween_levitate.keys[2][1] = fts(math.random(30, 40))
	tween_levitate.keys[3][1] = tween_levitate.keys[2][1] * 2
	tween_levitate.ts = store.tick_ts
	tween_levitate.disabled = false

	U.animation_start(this, "idle", nil, store.tick_ts, true, 1)
	U.y_wait_conditional(store, m.duration - (store.tick_ts - m.ts) - fts(10), function(store, time)
		return this.interrupt or target.health.dead
	end)

	tween_levitate.disabled = true

	U.animation_start(this, "out", nil, store.tick_ts, false, 1)

	this.tween.ts = store.tick_ts
	this.tween.reverse = true

	U.y_wait_unconditional(store, fts(23))

	es.tween.reverse = true
	es.tween.ts = store.tick_ts

	S:queue(this.out_sfx)
	U.y_animation_wait_default(this)

	if this.interrupt then
		target.health.hp = 0

		if target.death_spawns then
			target.health.last_damage_types = DAMAGE_NO_SPAWNS
		end
	else
		local d = E.assign_damage(this.damage_type, this.damage, this.id, target.id)

		queue_damage(store, d)
	end

	signal.emit("mod-applied", this, target)
	simulation:queue_remove_entity(this)
end

local function hero_space_elf_ultimate_update(this, store)
	local nearest = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

	if #nearest > 0 then
		local pi, _, ni = unpack(nearest[1])

		if P:is_node_valid(pi, ni) then
			local pos = P:node_pos(pi, 1, ni)
			local d = E:create_entity(this.decal)

			d.pos = pos
			d.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(d)

			local enemies = U.find_enemies_in_range_filter_on(pos, this.radius, F_RANGED, F_NONE, function(e)
				return not e.unit.is_stunned
			end)

			if enemies then
				for i = 1, #enemies do
					local m = E:create_entity(this.entity)

					m.modifier.target_id = enemies[i].id
					m.modifier.damage_factor = this.damage_factor
					m.modifier.source_id = this.id

					simulation:queue_insert_entity(m)
				end
			end
		end
	end

	simulation:queue_remove_entity(this)
end

tt = RT("hero_space_elf", "hero")

AC(tt, "melee", "ranged", "teleport", "transfer", "timed_attacks")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {208, 221, 234, 247, 260, 273, 286, 299, 312, 325}
tt.hero.level_stats.melee_damage_max = {9, 11, 13, 15, 16, 19, 20, 23, 26, 31}
tt.hero.level_stats.melee_damage_min = {6, 7, 9, 10, 11, 13, 14, 15, 16, 19}
tt.hero.level_stats.ranged_damage_max = {26, 28, 32, 36, 40, 44, 47, 52, 57, 62}
tt.hero.level_stats.ranged_damage_min = {14, 15, 18, 19, 22, 23, 26, 28, 31, 33}
tt.hero.skills.astral_reflection = CC("hero_skill")
tt.hero.skills.astral_reflection.cooldown = {25, 25, 25}
tt.hero.skills.astral_reflection.xp_gain = {200, 400, 600}
tt.hero.skills.astral_reflection.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.black_aegis = CC("hero_skill")
tt.hero.skills.black_aegis.cooldown = {18, 16, 14}
tt.hero.skills.black_aegis.duration = {6, 8, 10}
tt.hero.skills.black_aegis.shield_base = {50, 85, 120}
tt.hero.skills.black_aegis.explosion_damage = {25, 50, 75}
tt.hero.skills.black_aegis.xp_gain = {120, 240, 360}
tt.hero.skills.black_aegis.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.void_rift = CC("hero_skill")
tt.hero.skills.void_rift.cooldown = {30, 25, 20}
tt.hero.skills.void_rift.duration = {6, 8, 10}
tt.hero.skills.void_rift.damage_min = {3, 3, 3}
tt.hero.skills.void_rift.damage_max = {6, 6, 6}
tt.hero.skills.void_rift.cracks_amount = {1, 2, 3}
tt.hero.skills.void_rift.xp_gain = {240, 480, 720}
tt.hero.skills.void_rift.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.spatial_distortion = CC("hero_skill")
tt.hero.skills.spatial_distortion.cooldown = {25, 23, 20}
tt.hero.skills.spatial_distortion.duration = {6, 7, 8}
tt.hero.skills.spatial_distortion.range_factor = {1.04, 1.06, 1.08}
tt.hero.skills.spatial_distortion.damage_factor = {1.04, 1.06, 1.08}
tt.hero.skills.spatial_distortion.cooldown_factor = {0.96, 0.94, 0.92}
tt.hero.skills.spatial_distortion.xp_gain = {200, 400, 600}
tt.hero.skills.spatial_distortion.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "controller_hero_space_elf_ultimate"
tt.hero.skills.ultimate.cooldown = {45, 45, 45, 45}
tt.hero.skills.ultimate.duration = {5, 6, 7, 8}
tt.hero.skills.ultimate.damage = {39, 117, 234, 351}
tt.hero.skills.ultimate.xp_gain_factor = 50
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.health.dead_lifetime = 15
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_space_elf_level_up
tt.info.hero_portrait = "kr5_hero_portraits_0007"
tt.info.portrait = "kr5_info_portraits_heroes_0007"
tt.main_script.insert = hero_space_elf_insert
tt.main_script.update = hero_space_elf_update
tt.motion.max_speed = 90
tt.regen.cooldown = 1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_therien_therien"
tt.render.sprites[1].draw_order = DO_HEROES
tt.sound_events.change_rally_point = "HeroSpaceElfTaunt"
tt.sound_events.death = "HeroSpaceElfDeath"
tt.sound_events.respawn = "HeroSpaceElfTauntIntro"
tt.sound_events.hero_room_select = "HeroSpaceElfTauntSelect"
tt.teleport.min_distance = 72.5
tt.teleport.sound_in = "HeroSpaceElfTeleportIn"
tt.teleport.sound_out = "HeroSpaceElfTeleportOut"
tt.teleport.animations = {"out", "in"}
tt.transfer.animations = {"to_walk", "walk", "to_idle"}
tt.transfer.extra_speed = 1
tt.soldier.melee_slot_offset = vec_2(10, 0)
tt.health_bar.offset = vec_2(0, 38)
tt.unit.hit_offset = vec_2(0, 13)
tt.unit.mod_offset = vec_2(0, 13)
tt.ui.click_rect = r(-17, -5, 37, 40)
tt.melee.range = 72.5
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].hit_fx = "fx_hero_space_elf_melee_hit"
tt.melee.attacks[1].sound_args = {
	delay = fts(14)
}
tt.melee.attacks[1].xp_gain_factor = 2.36
tt.melee.attacks[1].hit_offset = vec_2(27, 15)
tt.melee.attacks[1].animation = "ability1"
tt.melee.attacks[1].basic_attack = true
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "ability2"
tt.ranged.attacks[1].bullet = "bolt_hero_space_elf_basic_attack"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(-9, 42), vec_2(9, 42)}
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].max_range = 160
tt.ranged.attacks[1].min_range = 68
tt.ranged.attacks[1].shoot_time = fts(10)
tt.ranged.attacks[1].xp_gain_factor = 1.6
tt.ranged.attacks[1].basic_attack = true
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "ability5"
tt.timed_attacks.list[1].max_range = 175
tt.timed_attacks.list[1].xp_gain_factor = 1.6
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_CLIFF, F_WATER)
tt.timed_attacks.list[1].damage_type = DAMAGE_MAGICAL
tt.timed_attacks.list[1].cast_time = fts(6)
tt.timed_attacks.list[1].entity_prefix = "soldier_hero_space_elf_astral_reflection"
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].min_cooldown = 3
tt.timed_attacks.list[1].sound = "HeroSpaceElfAstralReflection"
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].animation = "ability3"
tt.timed_attacks.list[2].range = 200
tt.timed_attacks.list[2].mod = "mod_hero_space_elf_black_aegis"
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].cast_time = fts(8)
tt.timed_attacks.list[2].xp_from_skill = "black_aegis"
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[2].min_cooldown = 3
tt.timed_attacks.list[2].sound = "HeroSpaceElfBlackAegis"
tt.timed_attacks.list[3] = CC("aura_attack")
tt.timed_attacks.list[3].animation = "ability6"
tt.timed_attacks.list[3].aura = "aura_hero_space_elf_void_rift"
tt.timed_attacks.list[3].max_range_trigger = 200
tt.timed_attacks.list[3].max_range_effect = 300
tt.timed_attacks.list[3].min_targets = 2
tt.timed_attacks.list[3].cast_time = fts(32)
tt.timed_attacks.list[3].xp_from_skill = "void_rift"
tt.timed_attacks.list[3].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[3].vis_bans = bor(F_BOSS, F_FLYING)
tt.timed_attacks.list[3].predict = fts(30)
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].cracks_distance = 4
tt.timed_attacks.list[3].border_cracks_distance = 2
tt.timed_attacks.list[3].crack_offset = 4
tt.timed_attacks.list[3].cast_decal = "decal_hero_space_elf_void_rift_therien"
tt.timed_attacks.list[3].min_cooldown = 3
tt.timed_attacks.list[3].sound = "HeroSpaceElfVoidRift"
tt.timed_attacks.list[4] = CC("custom_attack")
tt.timed_attacks.list[4].animation = "ability4"
tt.timed_attacks.list[4].cast_time = fts(11)
tt.timed_attacks.list[4].xp_from_skill = "spatial_distortion"
tt.timed_attacks.list[4].mod = "mod_hero_space_elf_spatial_distortion"
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].excluded_templates = {}
tt.timed_attacks.list[4].min_cooldown = 3
tt.timed_attacks.list[4].sound = "HeroSpaceElfSpatialDistortion"
tt.ultimate = {
	cooldown = 45,
	disabled = true,
	ts = 0
}
tt = RT("mod_hero_space_elf_void_rift", "mod_slow")
tt.slow.factor = 0.8
tt = RT("aura_hero_space_elf_void_rift", "aura")

AC(tt, "track_damage", "render")

tt.aura.duration = nil
tt.aura.track_damage = true
tt.aura.damage_inc = 0
tt.aura.damage_type = DAMAGE_MAGICAL_EXPLOSION
tt.aura.cycle_time = 0.25
tt.aura.radius = 120
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.vis_flags = F_RANGED
tt.aura.mod = "mod_hero_space_elf_void_rift"
tt.render.sprites[1].prefix = "hero_therien_rift_fx_decal"
tt.render.sprites[1].z = Z_DECALS + 1
tt.render.sprites[1].loop = false
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "hero_therien_rift_fx_decal2"
tt.render.sprites[2].z = Z_DECALS + 2
tt.render.sprites[2].loop = false
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "hero_therien_rift_fx_decalbrillo"
tt.render.sprites[3].z = Z_DECALS + 3
tt.render.sprites[3].loop = false
tt.main_script.update = aura_hero_space_elf_void_rift_update
tt.ignore_damage = false
tt = RT("mod_hero_space_elf_black_aegis", "modifier")

AC(tt, "render", "health_bar", "health")

tt.modifier.vis_flags = bor(F_MOD)
tt.modifier.use_mod_offset = false
tt.shield_max_damage = 0
tt.damage_taken = 0
tt.main_script.insert = scripts.mod_shield.insert
tt.main_script.remove = scripts.mod_shield.remove
tt.main_script.update = mod_hero_space_elf_black_aegis_update
tt.health_bar.offset = vec_2(0, 42)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.colors = {}
tt.health_bar.colors.fg = {255, 255, 0, 255}
tt.health_bar.colors.bg = {0, 0, 0, 255}
tt.health_bar.sort_y_offset = -2
tt.health_bar.disable_fade = true
tt.health_bar.hidden = true
tt.animation_start = "in"
tt.animation_loop = "idle"
tt.animation_end = "out"
tt.explosion_range = 80
tt.explosion_damage_type = DAMAGE_MAGICAL_EXPLOSION
tt.explosion_time = fts(8)
tt.render.sprites[1].prefix = "hero_therien_black_aegis_top"
tt.render.sprites[1].name = nil
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.render.sprites[1].scale = vec_2(0.8, 0.8)
tt.render.sprites[1].offset = vec_2(0, 3)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].prefix = "hero_therien_black_aegis_bottom"
tt.render.sprites[2].name = nil
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].size_names = {"small", "big", "big"}
tt.render.sprites[2].scale = vec_2(0.8, 0.8)
tt.render.sprites[2].offset = vec_2(0, 3)
tt.modifier.damage_fx = "fx_hero_space_elf_black_aegis_hit"
tt.sound_explosion = "HeroSpaceElfBlackAegisExplosion"
tt = RT("mod_hero_space_elf_spatial_distortion", "modifier")

AC(tt, "render", "tween")

tt.main_script.insert = scripts.mod_tower_factors.insert
tt.main_script.remove = scripts.mod_tower_factors.remove
tt.main_script.update = scripts.mod_tower_factors.update
tt.range_factor = 1
tt.cooldown_factor = 1
tt.damage_factor = 1
tt.render.sprites[1].name = "hero_therien_space_warp_idle"
tt.render.sprites[1].offset.y = 13
tt.render.sprites[1].draw_order = DO_TOWER_MODS
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}, {3, 255}, {3.5, 0}}
tt.fade_duration = 0.4
tt.offset_y_per_tower = {
	necromancer = 16,
	royal_archers = 20,
	elven_stargazers = 16,
	tricannon = 10,
	arborean_emissary = 20,
	flamespitter = 16,
	ballista = 20
}
tt = RT("mod_hero_space_elf_ultimate", "modifier")

AC(tt, "render", "tween", "track_kills")

tt.modifier.type = MOD_TYPE_TIMELAPSE
tt.modifier.vis_flags = F_MOD
tt.modifier.vis_bans = F_BOSS
tt.render.sprites[1].prefix = "hero_therien_void_prison_fx"
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fts(10), 0}, {fts(15), 255}}
tt.tween.props[1].sprite_id = 2
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {{0, vec_2(0, 0)}, {fts(30), vec_2(0, 10)}, {fts(60), vec_2(0, 0)}}
tt.tween.props[2].disabled = true
tt.tween.props[2].loop = true
tt.main_script.update = mod_hero_space_elf_ultimate_update
tt.main_script.insert = scripts.mod_timelapse.insert
tt.main_script.remove = scripts.mod_timelapse.remove
tt.damage_type = bor(DAMAGE_TRUE, DAMAGE_NO_SPAWNS)
tt.sound_events.insert = "HeroSpaceElfCosmicPrisonIn"
tt.out_sfx = "HeroSpaceElfCosmicPrisonOut"
tt.decal = "decal_hero_space_elf_ultimate_mod"
tt = RT("controller_hero_space_elf_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.entity = "mod_hero_space_elf_ultimate"
tt.decal = "decal_hero_space_elf_ultimate"
tt.main_script.update = hero_space_elf_ultimate_update
tt.radius = 90
tt = RT("fx_hero_space_elf_black_aegis_hit", "fx")
tt.render.sprites[1].name = "hero_therien_black_aegis_hit"
tt = RT("decal_hero_space_elf_ultimate", "decal_timed")
tt.render.sprites[1].name = "hero_therien_void_prison_floor_fx_idle"
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_hero_space_elf_ultimate_mod", "decal_tween")
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.13, 0}}
tt = RT("decal_hero_space_elf_void_rift_therien", "decal_tween")
tt.render.sprites[1].name = "hero_therien_rift_therien_fx_idle"
tt.render.sprites[1].z = Z_DECALS + 1
tt.render.sprites[1].loop = false
tt.tween.disabled = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.3, 255}, {1.5, 255}, {1.8, 0}}
