local scripts = require("scripts")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local bit = require("bit")
local km = require("lib.klua.macros")
local signal = require("lib.hump.signal")
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

local function bullet_hero_witch_basic_insert(this, store)
	local b = this.bullet

	if this.impulse_per_distance then
		local dx, dy = V.sub(b.to.x, b.to.y, b.from.x, b.from.y)
		local dist = V.len(dx, dy)

		this.initial_impulse = this.impulse_per_distance * dist
	end

	if b.target_id then
		local target = store.entities[b.target_id]

		if not target or band(target.vis.bans, F_RANGED) ~= 0 then
			return false
		end
	end

	b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

	local s = this.render.sprites[1]

	if not b.ignore_rotation then
		s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
	end

	U.animation_start_default(this, "flying", nil, store.tick_ts, s.loop)

	return true
end

local function bullet_hero_witch_basic_update(this, store)
	local b = this.bullet
	local fm = this.force_motion
	local target = store.entities[b.target_id]
	local ps

	local function move_step(dest)
		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)
		local nx, ny = V.mul(fm.max_v, V.normalize(dx, dy))
		local stx, sty = V.sub(nx, ny, fm.v.x, fm.v.y)

		if dist <= 4 * fm.max_v * store.tick_length then
			stx, sty = V.mul(fm.max_a, V.normalize(stx, sty))
		end

		fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step, stx, sty)))
		fm.v.x, fm.v.y = V.trim(fm.max_v, V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y)))
		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
		fm.a.x, fm.a.y = 0, 0

		return dist <= fm.max_v * store.tick_length
	end

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.emit = true
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	local pred_pos

	if target then
		pred_pos = P:predict_enemy_pos(target, fts(5))
	else
		pred_pos = b.to
	end

	local iix, iiy = V.normalize(pred_pos.x - this.pos.x, pred_pos.y - this.pos.y)
	local last_pos = V.vclone(this.pos)

	b.ts = store.tick_ts

	while true do
		target = store.entities[b.target_id]

		if target and target.health and not target.health.dead and band(target.vis.bans, F_RANGED) == 0 then
			local hit_offset = V.v(0, 0)

			if not b.ignore_hit_offset then
				hit_offset.x = target.unit.hit_offset.x
				hit_offset.y = target.unit.hit_offset.y
			end

			local d = math.max(math.abs(target.pos.x + hit_offset.x - b.to.x), math.abs(target.pos.y + hit_offset.y - b.to.y))

			if d > b.max_track_distance then
				log.debug("BOLT MAX DISTANCE FAIL. (%s) %s / dist:%s target.pos:%s,%s b.to:%s,%s", this.id, this.template_name, d, target.pos.x, target.pos.y, b.to.x, b.to.y)

				target = nil
				b.target_id = nil
			else
				b.to.x, b.to.y = target.pos.x + hit_offset.x, target.pos.y + hit_offset.y
			end
		end

		if this.initial_impulse and store.tick_ts - b.ts < this.initial_impulse_duration then
			local t = store.tick_ts - b.ts

			if this.initial_impulse_angle_abs then
				fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(this.initial_impulse_angle_abs, 1, 0))
			else
				local angle = this.initial_impulse_angle

				if iix < 0 then
					angle = angle * -1
				end

				fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(angle, iix, iiy))
			end
		end

		last_pos.x, last_pos.y = this.pos.x, this.pos.y

		if move_step(b.to) then
			break
		end

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - last_pos.x, this.pos.y - last_pos.y)
		end

		coroutine.yield()
	end

	if target and not target.health.dead then
		local d = SU.create_bullet_damage(b, target.id, this.id)

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
	elseif b.damage_radius and b.damage_radius > 0 then
		local targets = U.find_enemies_in_range_filter_off(this.pos, b.damage_radius, b.vis_flags, b.vis_bans)

		if targets then
			for _, target in ipairs(targets) do
				local d = SU.create_bullet_damage(b, target.id, this.id)

				queue_damage(store, d)
			end
		end
	end

	this.render.sprites[1].hidden = true

	if b.hit_fx then
		local fx = E:create_entity(b.hit_fx)

		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].runs = 0

		simulation:queue_insert_entity(fx)
	end

	if b.hit_decal then
		local decal = E:create_entity(b.hit_decal)

		decal.pos:copy(b.to)

		decal.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(decal)
	end

	if ps and ps.particle_system.emit then
		ps.particle_system.emit = false

		U.y_wait_unconditional(store, ps.particle_system.particle_lifetime[2])
	end

	simulation:queue_remove_entity(this)
end

local function aura_hero_witch_path_aoe_update(this, store)
	local first_hit_ts
	local last_hit_ts = 0
	local cycles_count = 0
	local victims_count = 0

	this.tween.disabled = false
	this.tween.ts = store.tick_ts
	this.tween.props[1].ts = store.tick_ts
	this.tween.props[2].ts = store.tick_ts
	this.tween.props[3].ts = store.tick_ts

	local start_fx = E:create_entity(this.start_fx)

	start_fx.pos:copy(this.pos)

	start_fx.render.sprites[1].ts = store.tick_ts
	start_fx.render.sprites[1].runs = 0
	start_fx.render.sprites[2].ts = store.tick_ts
	start_fx.render.sprites[2].runs = 0

	simulation:queue_insert_entity(start_fx)
	U.y_wait_unconditional(store, this.start_wait_time)
	S:queue(this.sound_impact)

	local targets = table.filter(store.enemies, function(k, v)
		return not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name)) and (not this.aura.filter_source or this.aura.source_id ~= v.id)
	end)

	for i, target in ipairs(targets) do
		local d = E.assign_damage(this.damage_type, math.random(this.damage_min, this.damage_max) * this.aura.damage_factor, this.id, target.id)

		queue_damage(store, d)
	end

	last_hit_ts = store.tick_ts - this.aura.cycle_time

	if this.aura.apply_delay then
		last_hit_ts = last_hit_ts + this.aura.apply_delay
	end

	while true do
		if this.interrupt then
			last_hit_ts = 1e+99
		end

		if this.aura.cycles and cycles_count >= this.aura.cycles or this.aura.duration >= 0 and store.tick_ts - this.aura.ts > this.actual_duration then
			break
		end

		if this.aura.stop_on_max_count and this.aura.max_count and victims_count >= this.aura.max_count then
			break
		end

		if not (store.tick_ts - last_hit_ts >= this.aura.cycle_time) or this.aura.apply_duration and first_hit_ts and store.tick_ts - first_hit_ts > this.aura.apply_duration then
		-- block empty
		else
			if this.render and this.aura.cast_resets_sprite_id then
				this.render.sprites[this.aura.cast_resets_sprite_id].ts = store.tick_ts
			end

			first_hit_ts = first_hit_ts or store.tick_ts
			last_hit_ts = store.tick_ts
			cycles_count = cycles_count + 1

			local targets = table.filter(store.enemies, function(k, v)
				return not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name)) and (not this.aura.filter_source or this.aura.source_id ~= v.id)
			end)

			for i, target in ipairs(targets) do
				if this.aura.targets_per_cycle and i > this.aura.targets_per_cycle then
					break
				end

				if this.aura.max_count and victims_count >= this.aura.max_count then
					break
				end

				local mods = this.aura.mods or {this.aura.mod}

				for _, mod_name in ipairs(mods) do
					local new_mod = E:create_entity(mod_name)

					new_mod.modifier.level = this.aura.level
					new_mod.modifier.target_id = target.id
					new_mod.modifier.source_id = this.id

					if this.aura.hide_source_fx and target.id == this.aura.source_id then
						new_mod.render = nil
					end

					simulation:queue_insert_entity(new_mod)

					victims_count = victims_count + 1
				end
			end
		end

		::label_651_0::

		coroutine.yield()
	end

	signal.emit("aura-apply-mod-victims", this, victims_count)
	simulation:queue_remove_entity(this)
end

local function soldier_hero_witch_decoy_update(this, store)
	local brk, stam, star

	this.reinforcement.ts = store.tick_ts
	this.render.sprites[1].ts = store.tick_ts

	if this.reinforcement.fade or this.reinforcement.fade_in then
		SU.y_reinforcement_fade_in(store, this)
	elseif this.render.sprites[1].name == "raise" then
		if this.sound_events and this.sound_events.raise then
			S:queue(this.sound_events.raise)
		end

		this.health_bar.hidden = true

		U.y_animation_play(this, "raise", nil, store.tick_ts, 1)

		if not this.health.dead then
			this.health_bar.hidden = nil
		end
	end

	local function y_custom_death(store, this)
		U.unblock_target(store, this)
		S:queue(this.sound_death)

		local can_spawn = this.death_spawns and band(this.health.last_damage_types, bor(DAMAGE_EAT, DAMAGE_NO_SPAWNS, this.death_spawns.no_spawn_damage_types or 0)) == 0

		if can_spawn and this.death_spawns.concurrent_with_death then
			SU.do_death_spawns(store, this)
			coroutine.yield()

			can_spawn = false
		end

		local h = this.health

		if band(h.last_damage_types, bor(DAMAGE_DISINTEGRATE, DAMAGE_DISINTEGRATE)) ~= 0 then
			this.unit.hide_during_death = true

			local fx = E:create_entity("fx_soldier_desintegrate")

			fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
			fx.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(fx)
		elseif band(h.last_damage_types, bor(DAMAGE_EAT)) ~= 0 then
			this.unit.hide_during_death = true
		elseif band(h.last_damage_types, bor(DAMAGE_HOST)) ~= 0 then
			S:queue(this.sound_events.death_by_explosion)

			this.unit.hide_during_death = true

			local fx = E:create_entity("fx_unit_explode")

			fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]

			simulation:queue_insert_entity(fx)

			if this.unit.show_blood_pool and this.unit.blood_color ~= BLOOD_NONE then
				local decal = E:create_entity("decal_blood_pool")

				decal.pos:copy(this.pos)

				decal.render.sprites[1].ts = store.tick_ts
				decal.render.sprites[1].name = this.unit.blood_color

				simulation:queue_insert_entity(decal)
			end
		elseif this.reinforcement and (this.reinforcement.fade or this.reinforcement.fade_out) then
			SU.y_reinforcement_fade_out(store, this)

			return
		else
			S:queue(this.sound_events.death, this.sound_events.death_args)
			U.y_animation_play(this, "death", nil, store.tick_ts, 1)

			this.ui.can_select = false
		end

		this.health.death_finished_ts = store.tick_ts

		if this.ui then
			-- if IS_TRILOGY then
			--     this.ui.can_click = not this.unit.hide_after_death
			-- else
			this.ui.can_click = this.ui.can_click and not this.unit.hide_after_death
			-- end
			this.ui.z = -1
		end

		if this.unit.hide_during_death or this.unit.hide_after_death then
			for _, s in ipairs(this.render.sprites) do
				s.hidden = true
			end
		end

		if this.unit.fade_time_after_death then
			local delay = this.unit.fade_time_after_death
			local duration = this.unit.fade_duration_after_death

			if this.health and this.health.delete_after and duration then
				delay = this.health.delete_after - store.tick_ts - duration
			end

			SU.fade_out_entity(store, this, delay, duration)
		end
	end

	while true do
		if this.health.dead or this.reinforcement.duration and store.tick_ts - this.reinforcement.ts > this.reinforcement.duration then
			if this.health.hp > 0 then
				this.reinforcement.hp_before_timeout = this.health.hp
			end

			this.health.hp = 0

			-- if IS_KR5 then
			SU.remove_modifiers(store, this)
			-- end
			y_custom_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			if this.melee then
				brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
					goto label_660_1
				end
			end

			if this.ranged then
				brk, star = SU.y_soldier_ranged_attacks(store, this)

				if brk or star == A_DONE then
					goto label_660_1
				elseif star == A_IN_COOLDOWN then
					goto label_660_0
				end
			end

			if this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
				goto label_660_1
			end

			if SU.soldier_go_back_step(store, this) then
				goto label_660_1
			end

			::label_660_0::

			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_660_1::

		coroutine.yield()
	end
end

local function hero_witch_get_info(this)
	local info = scripts.hero_basic.get_info(this)

	info.ranged_damage_max = info.ranged_damage_max * 2
	info.ranged_damage_min = info.ranged_damage_min * 2

	return info
end

local function hero_witch_level_up(this, store, initial)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	for i = 1, #this.ranged.attacks[1].bullets do
		local bt = E:get_template(this.ranged.attacks[1].bullets[i])

		bt.bullet.damage_min = ls.ranged_damage_min[hl]
		bt.bullet.damage_max = ls.ranged_damage_max[hl]
	end

	upgrade_skill(this, "soldiers", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.soldiers_amount = s.soldiers_amount[s.level]

		local e = E:get_template(a.entity)

		e.health.hp_max = s.hp_max[s.level]
		e.melee.attacks[1].damage_max = s.damage_max[s.level]
		e.melee.attacks[1].damage_min = s.damage_min[s.level]
	end)
	upgrade_skill(this, "polymorph", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.hp_max = s.hp_max[s.level]

		local b = E:get_template(a.bullet)
		local m = E:get_template(b.bullet.mod)

		m.modifier.duration = s.duration[s.level]
	end)
	upgrade_skill(this, "disengage", function(this, s)
		local d = this.dodge

		d.disabled = nil
		d.cooldown = s.cooldown[s.level]

		local e = E:get_template(d.decoy)

		e.health.hp_max = s.hp_max[s.level]
		e.melee.attacks[1].damage_max = s.melee_damage_max[s.level]
		e.melee.attacks[1].damage_min = s.melee_damage_min[s.level]

		local a = E:get_template(e.death_spawns.name)
		local m = E:get_template(a.aura.mod)

		m.modifier.duration = s.stun_duration[s.level]
	end)
	upgrade_skill(this, "path_aoe", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local aur = E:get_template(a.new_entity)

		aur.aura.duration = s.duration[s.level]
		aur.damage_min = s.damage_min[s.level]
		aur.damage_max = s.damage_max[s.level]
		aur.tween.props[1].keys = {{0, 0}, {aur.start_wait_time, 0}, {aur.start_wait_time + fts(10), 255}, {aur.aura.duration - 0.5, 255}, {aur.aura.duration, 0}}
		aur.tween.props[2].keys = {{0, 0}, {aur.start_wait_time + fts(4), 0}, {aur.start_wait_time + fts(5), 200}, {aur.start_wait_time + fts(9), 255}, {aur.aura.duration - 0.7, 255}, {aur.aura.duration, 0}}
		aur.tween.props[3].keys = {{0, v(0, 0)}, {aur.start_wait_time + fts(4), v(0, 0)}, {aur.start_wait_time + fts(5), v(0.9, 0.9)}, {aur.start_wait_time + fts(9), v(1.1, 1.1)}, {aur.start_wait_time + fts(11), v(1, 1)}}
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		local u = this.ultimate

		u.disabled = nil

		local uc = E:get_template(s.controller_name)

		uc.max_targets = s.max_targets[s.level]

		local mtel = E:get_template(uc.mod_teleport)
		local mend = E:get_template(mtel.end_mod)

		mend.modifier.duration = s.duration[s.level]
	end)
	update_hp(this)

	this.hero.melee_active_status = {}

	for index, attack in ipairs(this.melee.attacks) do
		this.hero.melee_active_status[index] = attack.disabled
	end
end

local function hero_witch_can_dodge(store, this, ranged_attack, attack, enemy)
	local skill = this.hero.skills.disengage

	if enemy and enemy.health and not enemy.health.dead and not this.dodge.disabled then
		local enp = enemy.nav_path
		local new_ni = enp.ni
		local node_limit = math.floor(skill.min_distance_from_end / P.average_node_dist)
		local node_jump = math.floor(skill.distance / P.average_node_dist)
		local nodes_to_goal = P:nodes_to_goal(enp.pi, enp.spi, enp.ni)

		if node_limit < nodes_to_goal then
			new_ni = new_ni + math.min(nodes_to_goal - 1, node_jump)

			local new_pos = P:node_pos(enp.pi, enp.spi, new_ni)

			this.dodge.new_pos = new_pos

			return true
		end
	end

	return false
end

local function hero_witch_update(this, store)
	local last_ts = store.tick_ts
	local h = this.health
	local a, skill, brk, stam
	local basic_ranged = this.ranged.attacks[1]
	local skill_soldiers_attack = this.timed_attacks.list[1]
	local p_sys

	this.health_bar.hidden = false
	p_sys = E:create_entity(this.particles_name_1)
	p_sys.particle_system.emit = false
	p_sys.particle_system.track_id = this.id

	simulation:queue_insert_entity(p_sys)

	local function custom_new_rally()
		local r = this.nav_rally

		if r.new then
			p_sys.particle_system.emit = true
			r.new = false

			U.unblock_target(store, this)

			if this.sound_events then
				S:queue(this.sound_events.change_rally_point)
			end

			local prev_immune = this.health.immune_to

			U.bans_add(this.vis, F_ALL)

			this.health.immune_to = r.immune_to

			local out = SU.y_hero_walk_waypoints(store, this)

			U.animation_start_default(this, "idle", nil, store.tick_ts, true)

			p_sys.particle_system.emit = false

			U.bans_remove(this.vis, F_ALL)

			this.health.immune_to = prev_immune

			return out
		end
	end

	local function create_soldier(e_template, s_offset)
		local e = E:create_entity(e_template)

		e.pos.x = this.pos.x + s_offset.x
		e.pos.y = this.pos.y + s_offset.y
		e.nav_rally.center = V.v(this.pos.x, this.pos.y)
		e.nav_rally.pos = V.vclone(e.pos)

		simulation:queue_insert_entity(e)
	end

	while true do
		if h.dead then
			p_sys.particle_system.emit = false

			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if custom_new_rally(store, this) then
					goto label_641_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local target = U.find_teleport_moment(store, this.pos, this.ranged.attacks[1].max_range, MANY_ENEMY_COUNT)

				if target and U.has_valid_rally_node_nearby(target.pos) then
					apply_ultimate(this, store, target.pos, "levelup")
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			skill = this.hero.skills.soldiers
			a = skill_soldiers_attack

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) and store.tick_ts - last_ts > a.min_cooldown then
				local enemies = U.find_enemies_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < a.min_targets then
					a.ts = a.ts + fts(10)
				else
					local start_ts = store.tick_ts

					S:queue(a.sound)

					local an, af, _ = U.animation_name_facing_point(this, a.animation, enemies[1].pos)

					U.animation_start_default(this, an, af, store.tick_ts, false)

					if SU.y_soldier_wait(store, this, a.cast_time) then
					-- block empty
					else
						a.ts = start_ts
						last_ts = start_ts

						SU.hero_gain_xp_from_skill(this, skill)

						for i = 1, a.soldiers_amount do
							create_soldier(a.entity, a.soldiers_offset[i])
						end

						SU.y_hero_animation_wait(this)
					end

					goto label_641_0
				end
			end

			a = this.timed_attacks.list[3]
			skill = this.hero.skills.path_aoe

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) and store.tick_ts - last_ts > a.min_cooldown then
				local _, targets, pred_pos = U.find_foremost_enemy_with_max_coverage_in_range_filter_off(this.pos, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans, E:get_template("aura_hero_witch_path_aoe").aura.radius)

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

					if SU.y_soldier_wait(store, this, a.cast_time) then
						goto label_641_0
					end

					local ne = E:create_entity(a.new_entity)

					ne.source_id = this.id
					ne.pos.x, ne.pos.y = pred_pos.x, pred_pos.y

					simulation:queue_insert_entity(ne)
					SU.y_hero_animation_wait(this)

					a.ts = start_ts
					last_ts = a.ts

					SU.hero_gain_xp_from_skill(this, skill)
				end
			end

			if not this.dodge.disabled and this.dodge.active and this.vis.bans ~= F_ALL then
				local enemy = store.entities[this.soldier.target_id]

				if not enemy then
				-- block empty
				else
					this.dodge.active = false
					this.dodge.ts = store.tick_ts

					local new_pos = this.dodge.new_pos

					S:queue(this.dodge.sound)
					U.unblock_target(store, this)
					U.bans_add(this.vis, F_ALL)
					SU.hide_modifiers(store, this, true)
					SU.hide_auras(store, this, true)
					U.animation_start_default(this, this.dodge.animation_dissapear, nil, store.tick_ts, false)
					U.y_wait_unconditional(store, fts(6))
					create_soldier(this.dodge.decoy, V.v(0, 0))

					this.timed_attacks.list[1].ts = this.timed_attacks.list[1].ts - 2
					this.timed_attacks.list[2].ts = this.timed_attacks.list[2].ts - 2
					this.timed_attacks.list[3].ts = this.timed_attacks.list[3].ts - 2
					this.ultimate.ts = this.ultimate.ts - 2

					U.y_animation_wait_default(this)
					U.y_wait_unconditional(store, fts(3))

					this.pos.x, this.pos.y = new_pos.x, new_pos.y
					this.nav_rally.center = V.vclone(this.pos)
					this.nav_rally.pos = V.vclone(this.pos)

					SU.hero_gain_xp_from_skill(this, this.hero.skills.disengage)
					U.y_animation_play(this, this.dodge.animation_appear, nil, store.tick_ts)
					U.bans_remove(this.vis, F_ALL)
					SU.show_modifiers(store, this, true)
					SU.show_auras(store, this, true)
					U.animation_start_default(this, "idle", nil, store.tick_ts, true)
				end
			end

			brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or stam ~= A_NO_TARGET then
			-- block empty
			else
				if store.tick_ts - basic_ranged.ts >= basic_ranged.cooldown then
					local enemy, _, enemy_pos = U.find_foremost_enemy_between_range_filter_off(this.pos, basic_ranged.min_range, basic_ranged.max_range, basic_ranged.node_prediction, basic_ranged.vis_flags, basic_ranged.vis_bans)

					if not enemy then
						basic_ranged.ts = basic_ranged.ts + fts(10)
					else
						local start_ts = store.tick_ts
						local enemy_id = enemy.id

						S:queue(basic_ranged.sound)

						local an, af, _ = U.animation_name_facing_point(this, basic_ranged.animation, enemy_pos)

						U.animation_start_default(this, an, af, store.tick_ts, false)

						if SU.y_soldier_wait(store, this, basic_ranged.shoot_time) then
						-- block empty
						else
							for i = 1, #basic_ranged.bullets do
								local bullet = E:create_entity(basic_ranged.bullets[i])

								bullet.bullet.damage_min = bullet.bullet.damage_min + this.unit.damage_buff
								bullet.bullet.damage_max = bullet.bullet.damage_max + this.unit.damage_buff
								bullet.bullet.damage_factor = this.unit.damage_factor
								bullet.bullet.source_id = this.id
								bullet.bullet.to = enemy_pos
								bullet.bullet.target_id = store.entities[enemy_id] and enemy_id or nil

								local start_offset = basic_ranged.bullet_start_offset[af and 2 or 1][i]

								bullet.bullet.from = V.v(this.pos.x + start_offset.x, this.pos.y + start_offset.y)
								bullet.bullet.xp_dest_id = this.id
								bullet.bullet.xp_gain_factor = basic_ranged.xp_gain_factor

								bullet.pos:copy(bullet.bullet.from)
								simulation:queue_insert_entity(bullet)
							end

							basic_ranged.ts = start_ts

							if SU.y_hero_animation_wait(this) then
							-- block empty
							end
						end
					end
				end

				a = this.timed_attacks.list[2]

				if ready_to_use_skill(a, store, this.unit.cooldown_factor) and store.tick_ts - last_ts > a.min_cooldown then
					local enemy = U.find_foremost_enemy_in_range_filter_on(this.pos, a.range, false, a.vis_flags, a.vis_bans, function(e)
						return e.health and e.health.hp_max <= a.hp_max and P:nodes_to_goal(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni) >= a.max_nodes_to_goal
					end)

					if not enemy then
						a.ts = a.ts + fts(10)
					else
						local start_ts = store.tick_ts
						local enemy_pos = V.vclone(enemy.pos)
						local enemy_id = enemy.id
						local an, af, _ = U.animation_name_facing_point(this, a.animation, enemy_pos)

						U.animation_start_default(this, an, af, store.tick_ts, false)

						if SU.y_soldier_wait(store, this, a.shoot_time) then
						-- block empty
						else
							local bullet = E:create_entity(a.bullet)

							bullet.bullet.damage_factor = this.unit.damage_factor
							bullet.bullet.source_id = this.id
							bullet.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
							bullet.bullet.target_id = store.entities[enemy_id] and enemy_id or nil

							local start_offset = a.bullet_start_offset[af and 1 or 2]

							bullet.bullet.from = V.v(this.pos.x + start_offset.x, this.pos.y + start_offset.y)
							bullet.bullet.xp_dest_id = this.id
							bullet.bullet.xp_gain_factor = basic_ranged.xp_gain_factor
							bullet.bullet.level = this.hero.skills.polymorph.level

							bullet.pos:copy(bullet.bullet.from)

							bullet.pred_pos = enemy_pos
							bullet.source_id = this.id

							simulation:queue_insert_entity(bullet)

							a.ts = start_ts
							last_ts = start_ts

							SU.hero_gain_xp_from_skill(this, this.hero.skills.polymorph)
							SU.y_hero_animation_wait(this)
						end
					end
				end

				if this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
				-- block empty
				elseif SU.soldier_go_back_step(store, this) then
				-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_641_0::

		coroutine.yield()
	end
end

local function mod_hero_witch_ultimate_teleport_remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target then
		target.health.ignore_damage = false

		SU.stun_dec(target)

		local mod_sleep = E:create_entity(this.end_mod)

		mod_sleep.modifier.target_id = target.id
		mod_sleep.modifier.source_id = this.source_id

		simulation:queue_insert_entity(mod_sleep)
	end

	return true
end

local function hero_witch_ultimate_update(this, store)
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, {1}, true)

	if #nodes < 1 then
		return false
	end

	local pi, spi, ni = unpack(nodes[1])
	local npos = P:node_pos(pi, spi, ni)

	S:queue(this.sound_cast)

	local d = E:create_entity(this.teleport_decal)

	d.pos = V.vclone(npos)
	d.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(d)
	U.y_wait_unconditional(store, fts(5))

	local target, targets = U.find_nearest_enemy(store, npos, 0, this.radius, this.vis_flags, this.vis_bans)

	if not target or not targets or #targets < 1 then
		return true
	end

	local num_targets = math.min(#targets, this.max_targets)

	for i = 1, num_targets do
		local t = targets[i]
		local mod_mark = E:create_entity(this.mod_mark)

		mod_mark.modifier.target_id = t.id
		mod_mark.modifier.source_id = this.id

		simulation:queue_insert_entity(mod_mark)
		S:queue(this.sound_teleport_in)

		local mod_teleport = E:create_entity(this.mod_teleport)

		mod_teleport.modifier.target_id = t.id
		mod_teleport.modifier.source_id = this.id

		simulation:queue_insert_entity(mod_teleport)
		S:queue(this.sound_teleport_out, {
			delay = mod_teleport.hold_time
		})
	end

	simulation:queue_remove_entity(this)
end

local function mod_hero_witch_skill_polymorph_insert(this, store)
	local target = store.entities[this.modifier.target_id]
	local hero = store.entities[this.modifier.source_id]

	if target then
		this.target_ref = target

		for _, s in ipairs(target.render.sprites) do
			s.hidden = true
		end

		hero.polymorph_enemy = {
			enemy = target
		}

		SU.remove_modifiers(store, target)
		SU.remove_auras(store, target)
		simulation:queue_remove_entity(target)
		U.unblock_all(store, target)

		if target.ui then
			target.ui.can_click = false
		end

		if target.main_script then
			target.main_script.co = nil
			target.main_script.runs = 0
		end

		if target.count_group then
			target.count_group.in_limbo = true
		end

		target.trigger_deselect = true

		local is_flying = U.flag_has(target.vis.flags, F_FLYING)
		local pumpkin = E:create_entity(is_flying and this.entity_t_flying or this.entity_t)

		pumpkin.pos = target.pos
		pumpkin.nav_path = target.nav_path
		pumpkin.health.hp_max = target.health.hp * this.entity_hp[this.modifier.level]
		pumpkin.health.hp = target.health.hp * this.entity_hp[this.modifier.level]
		pumpkin.health.patched = target.health.patched
		pumpkin.enemy.gold = target.enemy.gold

		simulation:queue_insert_entity(pumpkin)

		hero.polymorph_enemy.pumpkin = pumpkin

		return true
	end

	return false
end

local function mod_hero_witch_skill_polymorph_update(this, store)
	local m = this.modifier

	this.modifier.ts = store.tick_ts

	local target = this.target_ref

	this.pos = target.pos

	while true do
		if m.duration >= 0 and store.tick_ts - m.ts > m.duration then
			simulation:queue_remove_entity(this)

			return
		end

		coroutine.yield()
	end
end

local function mod_hero_witch_skill_polymorph_remove(this, store)
	local hero = store.entities[this.modifier.source_id]

	if hero and hero.polymorph_enemy and hero.polymorph_enemy.enemy then
		local target = hero.polymorph_enemy.enemy
		local pumpkin = hero.polymorph_enemy.pumpkin

		if pumpkin and store.entities[pumpkin.id] and not pumpkin.health.dead then
			for _, s in ipairs(target.render.sprites) do
				s.hidden = false
			end

			target.main_script.runs = 1

			if target.ui then
				target.ui.can_click = true
			end

			target.pos = V.vclone(pumpkin.pos)
			target.nav_path = pumpkin.nav_path
			target.health.patched = pumpkin.health.patched
			target.health.hp = target.health.hp * pumpkin.health.hp / pumpkin.health.hp_max
			target.health.hp_max = target.health.hp

			simulation:queue_insert_entity(target)

			pumpkin.trigger_deselect = true

			S:queue(this.sound_transform_out)

			local sfx = E:create_entity(this.transform_fx)

			sfx.pos = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].runs = 0

			if target and sfx.render.sprites[1].size_names then
				sfx.render.sprites[1].name = sfx.render.sprites[1].size_names[target.unit.size]
			end

			simulation:queue_insert_entity(sfx)
			simulation:queue_remove_entity(pumpkin)
		end

		hero.polymorph_enemy = nil
	end

	return true
end

local function bullet_witch_skill_polymorph_update(this, store)
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

	::label_654_0::

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

			goto label_654_0
		end
	end

	this.pos.x, this.pos.y = b.to.x, b.to.y

	if target and not target.health.dead then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)

		if b.mod or b.mods then
			local mods = b.mods or {b.mod}

			for _, mod_name in ipairs(mods) do
				local m = E:create_entity(mod_name)

				m.modifier.target_id = b.target_id
				m.modifier.source_id = this.source_id
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

tt = RT("soldier_hero_witch_cat", "soldier_militia")

AC(tt, "reinforcement", "tween")

tt.health.armor = 0
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 30)
tt.info.portrait = "kr5_info_portraits_soldiers_0018"
tt.info.random_name_format = "SOLDIER_HERO_WITCH_CAT_%i_NAME"
tt.info.random_name_count = 8
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].sound = "CommonNoSwordAttack"
tt.melee.range = 100
tt.motion.max_speed = 60
tt.regen.health = 0
tt.reinforcement.duration = 8
tt.render.sprites[1].prefix = "hero_witch_cat"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
-- tt.render.sprites[1].scale = vec_1(1)
tt.soldier.melee_slot_offset = vec_2(3, 0)
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.tween.disabled = true
tt.unit.hit_offset = vec_2(0, 5)
tt.unit.mod_offset = vec_2(0, 14)
tt = RT("soldier_hero_witch_decoy", "soldier_militia")

AC(tt, "reinforcement", "tween", "death_spawns")

tt.health.armor = 0
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 30)
tt.info.portrait = "kr5_info_portraits_soldiers_0021"
tt.info.random_name_format = "SOLDIER_HERO_WITCH_DECOY_NAME"
tt.info.random_name_count = 8
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = soldier_hero_witch_decoy_update
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.range = 80
tt.motion.max_speed = 60
tt.regen.health = 0
tt.reinforcement.duration = 8
tt.reinforcement.fade = nil
tt.render.sprites[1].prefix = "hero_witch_decoy"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.soldier.melee_slot_offset = vec_2(3, 0)
tt.tween.disabled = true
tt.unit.hit_offset = vec_2(0, 5)
tt.unit.mod_offset = vec_2(0, 14)
tt.death_spawns.name = "aura_hero_witch_decoy_explotion"
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.delay = fts(19)
tt.sound_death = "HeroWitchDazzlingDecoyExplosion"
tt = RT("hero_witch", "hero")

AC(tt, "melee", "ranged", "dodge", "timed_attacks")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {169, 188, 208, 227, 247, 266, 288, 305, 325, 344}
tt.hero.level_stats.melee_damage_max = {13, 14, 16, 18, 19, 22, 23, 24, 27, 28}
tt.hero.level_stats.melee_damage_min = {9, 10, 10, 11, 13, 14, 15, 16, 18, 19}
tt.hero.level_stats.ranged_damage_max = {14, 15, 17, 19, 20, 24, 25, 26, 29, 30}
tt.hero.level_stats.ranged_damage_min = {10, 11, 11, 12, 14, 15, 16, 18, 19, 20}
tt.sound_events.change_rally_point = "HeroWitchTaunt"
tt.sound_events.death = "HeroWitchDeath"
tt.sound_events.respawn = "HeroWitchTauntIntro"
tt.sound_events.hero_room_select = "HeroWitchTauntSelect"
tt.hero.skills.soldiers = CC("hero_skill")
tt.hero.skills.soldiers.cooldown = {17.5, 17.5, 17.5}
tt.hero.skills.soldiers.damage_min = {2, 5, 7}
tt.hero.skills.soldiers.damage_max = {3, 7, 11}
tt.hero.skills.soldiers.soldiers_amount = {2, 3, 4}
tt.hero.skills.soldiers.hp_max = {60, 85, 110}
tt.hero.skills.soldiers.xp_gain = {144, 288, 432}
tt.hero.skills.soldiers.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.polymorph = CC("hero_skill")
tt.hero.skills.polymorph.cooldown = {20, 20, 20}
tt.hero.skills.polymorph.hp_max = {1000, 2000, 3000}
tt.hero.skills.polymorph.duration = {8, 8, 8}
tt.hero.skills.polymorph.xp_gain = {160, 320, 480}
tt.hero.skills.polymorph.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.path_aoe = CC("hero_skill")
tt.hero.skills.path_aoe.cooldown = {16, 16, 16}
tt.hero.skills.path_aoe.duration = {5, 6, 8}
tt.hero.skills.path_aoe.min_range = 75
tt.hero.skills.path_aoe.max_range = 180
tt.hero.skills.path_aoe.damage_min = {65, 104, 156}
tt.hero.skills.path_aoe.damage_max = {65, 104, 156}
tt.hero.skills.path_aoe.min_targets = 1
tt.hero.skills.path_aoe.xp_gain = {128, 256, 384}
tt.hero.skills.path_aoe.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.disengage = CC("hero_skill")
tt.hero.skills.disengage.cooldown = {12, 12, 12}
tt.hero.skills.disengage.melee_damage_min = {10, 15, 20}
tt.hero.skills.disengage.melee_damage_max = {15, 23, 31}
tt.hero.skills.disengage.hp_max = {65, 97, 130}
tt.hero.skills.disengage.min_distance_from_end = 270
tt.hero.skills.disengage.distance = 130
tt.hero.skills.disengage.stun_duration = {2, 2.5, 3}
tt.hero.skills.disengage.xp_gain = {160, 320, 480}
tt.hero.skills.disengage.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "controller_hero_witch_ultimate"
tt.hero.skills.ultimate.duration = {3, 4, 5, 6}
tt.hero.skills.ultimate.max_targets = {4, 6, 8, 10}
tt.hero.skills.ultimate.cooldown = 30
tt.hero.skills.ultimate.xp_gain_factor = 30
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 40)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_witch_level_up
tt.info.hero_portrait = "kr5_hero_portraits_0013"
tt.info.fn = hero_witch_get_info
tt.info.portrait = "kr5_info_portraits_heroes_0013"
tt.main_script.update = hero_witch_update
tt.motion.max_speed = 180
tt.regen.cooldown = 1

for i = 1, 3 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].prefix = "hero_witch_hero_layer" .. i
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].group = "layers"
end

tt.particles_name_1 = "ps_hero_witch_spark_1"
tt.soldier.melee_slot_offset = vec_2(10, 0)
tt.unit.hit_offset = vec_2(0, 15)
tt.unit.mod_offset = vec_2(0, 15)
tt.dodge.disabled = true
tt.dodge.ranged = false
tt.dodge.chance = 1
tt.dodge.animation_dissapear = "disengage_disappear"
tt.dodge.animation_appear = "disengage_appear"
tt.dodge.can_dodge = hero_witch_can_dodge
tt.dodge.sound = "HeroWitchDazzlingDecoyCast"
tt.dodge.hp_to_trigger = 0.4
tt.dodge.decoy = "soldier_hero_witch_decoy"
tt.melee.range = 72
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animation = "melee_attack"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].xp_gain_factor = 2.2
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].sound = "HeroBuilderBasicAttack"
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullets = {"bullet_hero_witch_basic_1", "bullet_hero_witch_basic_2"}
tt.ranged.attacks[1].bullet = "bullet_hero_witch_basic_1"
tt.ranged.attacks[1].bullet_start_offset = {{vec_2(21, 42), vec_2(21, 37)}, {vec_2(-21, 42), vec_2(-21, 37)}}
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].max_range = 200
tt.ranged.attacks[1].shoot_time = fts(13)
tt.ranged.attacks[1].sync_animation = true
tt.ranged.attacks[1].animation = "range_attack"
tt.ranged.attacks[1].node_prediction = fts(30)
tt.ranged.attacks[1].ignore_hit_offset = true
tt.ranged.attacks[1].start_sound = "HeroDragonGemBasicAttackCast"
tt.ranged.attacks[1].basic_attack = true
tt.ranged.attacks[1].xp_gain_factor = 1.7
tt.ranged.attacks[1].sound = "HeroWitchBasicAttackCast"
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "skill_3"
tt.timed_attacks.list[1].cast_time = fts(36)
tt.timed_attacks.list[1].entity = "soldier_hero_witch_cat"
tt.timed_attacks.list[1].max_range = 180
tt.timed_attacks.list[1].min_targets = 2
tt.timed_attacks.list[1].soldiers_offset = {vec_2(10, -10), vec_2(-10, 10), vec_2(-15, -13), vec_2(15, 13)}
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1].sound = "HeroWitchNightFuriesCast"
tt.timed_attacks.list[1].min_cooldown = 5
tt.timed_attacks.list[2] = CC("bullet_attack")
tt.timed_attacks.list[2].animation = "skill_1"
tt.timed_attacks.list[2].range = 200
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].shoot_time = fts(16)
tt.timed_attacks.list[2].xp_from_skill = "polymorph"
tt.timed_attacks.list[2].bullet = "bullet_witch_skill_polymorph"
tt.timed_attacks.list[2].bullet_start_offset = {vec_2(-13, 42), vec_2(13, 42)}
tt.timed_attacks.list[2].vis_bans = bor(F_BOSS, F_POLYMORPH)
tt.timed_attacks.list[2].vis_flags = bor(F_POLYMORPH)
tt.timed_attacks.list[2].min_cooldown = 2
tt.timed_attacks.list[2].max_nodes_to_goal = 50
tt.timed_attacks.list[3] = CC("custom_attack")
tt.timed_attacks.list[3].animation = "skill_4"
tt.timed_attacks.list[3].new_entity = "aura_hero_witch_path_aoe"
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].cast_time = fts(25)
tt.timed_attacks.list[3].node_prediction = fts(30)
tt.timed_attacks.list[3].max_range = 180
tt.timed_attacks.list[3].min_targets = 1
tt.timed_attacks.list[3].vis_bans = bor(F_FLYING, F_CLIFF)
tt.timed_attacks.list[3].sound = "HeroWitchSquishNSquashCast"
tt.timed_attacks.list[3].min_cooldown = 5
tt.ui.click_rect = r(-20, -5, 40, 43)
tt.nav_grid.valid_terrains = bor(TERRAIN_LAND, TERRAIN_WATER, TERRAIN_SHALLOW, TERRAIN_NOWALK, TERRAIN_ICE)
tt.ultimate = {
	ts = 0,
	cooldown = 30,
	disabled = true
}
tt = RT("bullet_hero_witch_basic_1", "bolt")

AC(tt, "force_motion")

tt.render.sprites[1].prefix = "hero_witch_ranged_attack_projectile"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].scale = vec_1(1)
tt.bullet.damage_type = DAMAGE_MAGICAL_EXPLOSION
tt.transition_time = 1
tt.target_distance_detection = 20
tt.main_script.update = bullet_hero_witch_basic_update
tt.main_script.insert = bullet_hero_witch_basic_insert
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.acceleration_factor = 0.1
tt.bullet.hit_fx = "fx_hero_witch_basic_ranged_hit"
tt.bullet.particles_name = "ps_hero_witch_ranged_basic_trail"
tt.impulse_per_distance = 37.5
tt.initial_impulse = 6000
tt.initial_impulse_duration = 0.05
tt.initial_impulse_angle = 0.75 * math.pi * 0.5
tt.force_motion.a_step = 13
tt.force_motion.max_a = 1800
tt.force_motion.max_v = 450
tt.sound_events.insert = nil
tt = RT("bullet_hero_witch_basic_2", "bullet_hero_witch_basic_1")
tt.initial_impulse_angle = 3.5 * math.pi * 0.5
tt = RT("bullet_witch_skill_polymorph", "bolt")

AC(tt, "force_motion")

tt.render.sprites[1].prefix = "hero_witch_skill_1_particle_idle"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].scale = vec_1(1)
tt.main_script.update = bullet_witch_skill_polymorph_update
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.acceleration_factor = 0.1
tt.bullet.hit_fx = "fx_hero_witch_skill_polymorph"
tt.bullet.particles_name = "ps_bullet_hero_witch_skill_polymorph"
tt.bullet.max_speed = 1800
tt.bullet.max_track_distance = 50
tt.bullet.mod = "mod_hero_witch_skill_polymorph"
tt.force_motion.a_step = 6
tt.force_motion.max_a = 3000
tt.force_motion.max_v = 360
tt.initial_impulse = 9000
tt.initial_impulse_duration = 0.1
tt.initial_impulse_angle = math.pi * 0.5
tt.spawn_time = fts(18)
tt.sound_events.insert = "HeroWitchVeggiefyIn"
tt = RT("aura_hero_witch_path_aoe", "aura")

AC(tt, "render", "tween")

tt.aura.mod = "mod_hero_witch_path_aoe"
tt.aura.duration = nil
tt.aura.radius = 75
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.cycle_time = fts(5)
tt.render.sprites[1].name = "hero_witch_skill_4_potion_decal_1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
-- tt.render.sprites[1].scale = vec_1(1080 / 768)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "hero_witch_skill_4_potion_decal_2"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
-- tt.render.sprites[2].scale = vec_1(1080 / 768)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = aura_hero_witch_path_aoe_update
tt.start_fx = "fx_hero_witch_skill_path_aoe_in"
tt.start_wait_time = fts(14)
tt.tween.disabled = true
-- level_up fn 中被动态定义
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "alpha"
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].keys = {}
tt.tween.props[3] = CC("tween_prop")
tt.tween.props[3].name = "scale"
tt.tween.props[3].sprite_id = 2
tt.tween.props[3].keys = {}
tt.damage_type = DAMAGE_MAGICAL_EXPLOSION
tt.sound_impact = "HeroWitchSquishNSquashImpact"
tt = RT("aura_hero_witch_decoy_explotion", "aura")

AC(tt, "render")

tt.aura.mod = "mod_hero_witch_decoy_stun"
tt.aura.radius = 45
tt.aura.vis_flags = F_MOD
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.cycle_time = 99
tt.aura.duration = 3
tt.render.sprites[1].prefix = "hero_witch_skill_2_stun"
tt.render.sprites[1].name = "decal_death"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = false
tt.render.sprites[1].scale = vec_1(1.25 / 768 * 1080)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "hero_witch_skill_2_stun"
tt.render.sprites[2].name = "fx_death"
tt.render.sprites[2].loop = false
tt.render.sprites[2].scale = vec_1(1.25 / 768 * 1080)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt = RT("mod_hero_witch_path_aoe", "mod_slow")
tt.slow.factor = 0.5
tt = RT("mod_hero_witch_decoy_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt = RT("mod_hero_witch_skill_polymorph", "modifier")
tt.entity_hp = {0.7, 0.55, 0.4}
tt.main_script.insert = mod_hero_witch_skill_polymorph_insert
tt.main_script.update = mod_hero_witch_skill_polymorph_update
tt.main_script.remove = mod_hero_witch_skill_polymorph_remove
tt.entity_t = "enemy_pumpkin_witch"
tt.entity_t_flying = "enemy_pumpkin_witch_flying"
tt.transform_fx = "fx_hero_witch_skill_polymorph"
tt.sound_transform_out = "HeroWitchVeggiefyOut"
tt = RT("mod_hero_witch_ultimate_teleport", "mod_teleport")
tt.main_script.remove = mod_hero_witch_ultimate_teleport_remove
tt.modifier.vis_flags = bor(F_MOD)
tt.modifier.vis_bans = bor(F_BOSS)
tt.modifier.duration = 1
tt.nodes_offset = -50
tt.dest_valid_node = true
tt.max_times_applied = 1e+99
tt.delay_start = fts(3)
tt.hold_time = 0.34
tt.delay_end = fts(3)
tt.fx_start = "fx_hero_witch_ultimate"
tt.fx_end = "fx_hero_witch_ultimate"
tt.end_mod = "mod_hero_witch_ultimate_sleep"
tt.sound_events.insert = "HeroDragonBoneUltimateOut"
tt.sound_events.remove = "HeroDragonBoneUltimateIn"
tt = RT("mod_hero_witch_ultimate_mark", "modifier")

AC(tt, "mark_flags")

tt.mark_flags.vis_bans = F_TELEPORT
tt.modifier.duration = fts(50)
tt.main_script.insert = scripts.mod_mark_flags.insert
tt.main_script.remove = scripts.mod_mark_flags.remove
tt.main_script.update = scripts.mod_mark_flags.update
tt = RT("mod_hero_witch_ultimate_sleep", "modifier")

AC(tt, "render")

tt.main_script.insert = scripts.mod_stun.insert
tt.main_script.update = scripts.mod_stun.update
tt.main_script.remove = scripts.mod_stun.remove
tt.render.sprites[1].prefix = "hero_witch_ultimate_sleep_fx"
tt.render.sprites[1].keep_flip_x = true
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.render.sprites[1].scale = vec_1(1)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "hero_witch_ultimate_sleep_particles"
tt.render.sprites[2].name = "loop"
tt.render.sprites[2].keep_flip_x = true
tt.render.sprites[2].draw_order = DO_MOD_FX
tt.render.sprites[2].scale = vec_1(1)
tt = RT("controller_hero_witch_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.main_script.update = hero_witch_ultimate_update
tt.teleport_decal = "decal_hero_witch_ultimate"
tt.vis_bans = bor(F_BOSS)
tt.vis_flags = bor(F_TELEPORT)
tt.radius = 100
tt.mod_mark = "mod_hero_witch_ultimate_mark"
tt.mod_teleport = "mod_hero_witch_ultimate_teleport"
tt = RT("ps_hero_witch_ranged_basic_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_witch_ranged_attack_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 60
tt.particle_system.particle_lifetime = {fts(5), fts(8)}
tt.particle_system.emit_rotation_spread = math.pi * 0.5
tt = RT("ps_hero_witch_spark_1")

AC(tt, "pos", "particle_system", "main_script")

tt.particle_system.name = "hero_witch_walk_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 10
tt.particle_system.particle_lifetime = {fts(25), fts(30)}
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_area_spread = vec_2(2, 1)
tt.particle_system.emit_direction = 2 * math.pi / 3
tt.particle_system.emit_speed = {10, 10}
tt.particle_system.emit_offset = vec_2(-15, 0)
tt.particle_system.z = Z_OBJECTS
tt.particle_system.animation_fps = 15
tt.particle_system.sort_y_offset = -40
tt.main_script.update = scripts.ps_hero_mecha_smoke.update
tt.emit_direction_sides = {2 * math.pi / 3, math.pi / 3}
tt = RT("ps_bullet_hero_witch_skill_polymorph")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_witch_skill_1_particle_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 60
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_area_spread = vec_2(8, 8)
tt.particle_system.scales_y = {1, 1.5}
tt.particle_system.scales_x = {1, 1.5}
tt.particle_system.emit_offset = vec_2(0, 0)
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.emit_offset_relative = vec_2(-15, 0)
tt = RT("fx_hero_witch_basic_ranged_hit", "fx")
tt.render.sprites[1].name = "hero_witch_ranged_attack_hit"
tt.render.sprites[1].scale = vec_1(1)
tt = RT("fx_hero_witch_ultimate", "fx")
tt.render.sprites[1].name = "hero_witch_ultimate_teleport_fx"
tt.render.sprites[1].scale = vec_1(1)
tt = RT("fx_hero_witch_skill_path_aoe_in", "fx")
tt.render.sprites[1].name = "hero_witch_skill_4_potion_in_layer1_in"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].scale = vec_1(1)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "hero_witch_skill_4_potion_in_layer2_in"
tt.render.sprites[2].loop = false
tt.render.sprites[2].z = Z_EFFECTS
tt.render.sprites[2].scale = vec_1(1)
tt = RT("fx_hero_witch_skill_polymorph", "fx")
tt.render.sprites[1].name = "hero_witch_skill_1_hit_run"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.render.sprites[1].scale = vec_1(1)
tt = RT("decal_hero_witch_ultimate", "decal_timed")
tt.render.sprites[1].name = "hero_witch_ultimate_teleport_decal"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].scale = vec_1(1)
