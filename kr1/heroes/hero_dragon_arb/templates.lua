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
local v = V.v
local vv = V.vv
local tt

local function bullet_hero_dragon_arb_breath_splint_update(this, store, script)
	local b = this.bullet
	local s = this.render.sprites[1]
	local mspeed = b.min_speed
	local target, ps
	local new_target = false
	local target_invalid = false
	local did_damage_fliers = false

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	local function random_float(lower, greater)
		return lower + math.random() * (greater - lower)
	end

	local function do_damage(is_flying_damage)
		local origin = is_flying_damage and this.fliers_damage_pos or this.pos
		local targets = table.filter(store.entities, function(k, v)
			if v.pending_removal or not v.enemy or not v.vis or not v.nav_path or not v.health or v.health.dead or band(v.vis.flags, b.damage_bans) ~= 0 or band(v.vis.bans, b.damage_flags) ~= 0 then
				return false
			end

			local unit_pos = V.vclone(v.pos)

			if is_flying_damage and v.unit and v.unit.hit_offset then
				unit_pos.y = unit_pos.y + v.unit.hit_offset.y
			end

			return U.is_inside_ellipse(unit_pos, origin, b.damage_radius) and P:is_node_valid(v.nav_path.pi, v.nav_path.ni)
		end)

		if targets and #targets > 0 then
			local mod_hit_times = {}

			for _, e in ipairs(targets) do
				if bit.band(e.vis.flags, F_FLYING) ~= 0 == is_flying_damage then
					local d = SU.create_bullet_damage(b, e.id, this.id)
					local u = UP:get_upgrade("mage_spell_of_penetration")

					if u and math.random() < u.chance then
						d.damage_type = DAMAGE_TRUE
					end

					queue_damage(store, d)

					local passive_mark_mod = E:create_entity(this.passive_mark_mod)

					passive_mark_mod.modifier.target_id = e.id
					passive_mark_mod.cached_controller_dragon_arb_passive_id = this.cached_controller_dragon_arb_passive_id

					simulation:queue_insert_entity(passive_mark_mod)

					for _, v in ipairs(b.mods) do
						do
							local mod = E:create_entity(v)

							if mod.chance and math.random() >= mod.chance then
							-- block empty
							else
								if mod.max_targets_per_hit then
									if not mod_hit_times[v] then
										mod_hit_times[v] = 0
									end

									if mod_hit_times[v] >= mod.max_targets_per_hit then
										goto label_832_0
									else
										mod_hit_times[v] = mod_hit_times[v] + 1
									end
								end

								mod.modifier.target_id = e.id

								if this.instakill_chance then
									mod.instakill_chance = this.instakill_chance
								end

								mod.cached_controller_dragon_arb_passive_id = this.cached_controller_dragon_arb_passive_id

								simulation:queue_insert_entity(mod)
							end
						end

						::label_832_0::
					end
				end
			end
		end
	end

	this.tween.ts = store.tick_ts

	if this.size_variation then
		this.render.sprites[1].scale = V.vv(1 + random_float(-this.size_variation, this.size_variation))

		local speed_variation = random_float(-this.speed_variation, this.speed_variation)

		this.bullet.min_speed = this.bullet.min_speed + this.bullet.min_speed * speed_variation
		this.bullet.max_speed = this.bullet.max_speed + this.bullet.max_speed * speed_variation
	end

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

		if not did_damage_fliers and V.dist(this.pos.x, this.pos.y, this.fliers_damage_pos.x, this.fliers_damage_pos.y) < b.damage_radius / 4 then
			did_damage_fliers = true

			do_damage(true)
		end
	end

	this.pos.x, this.pos.y = b.to.x, b.to.y

	do_damage(false)

	-- TODO: 这里 GR:cell_type 返回 nil 相关的报错很奇怪，检查 grid_db 后我认为它应该一定会返回一个正常值，除非这关的 grid 有问题。
	local terrain_type = band(GR:cell_type(this.pos.x, this.pos.y) or TERRAIN_NONE, TERRAIN_TYPES_MASK)

	if b.payload and terrain_type ~= TERRAIN_WATER then
		local hp = E:create_entity(table.random(b.payload))

		hp.pos.x, hp.pos.y = b.to.x, b.to.y

		local hp_s = hp.render.sprites[1]
		local this_s = this.render.sprites[1]

		hp_s.ts = store.tick_ts

		local hp_scale = hp_s.scale and V.vclone(hp_s.scale) or V.vv(1)
		local scale_diff = V.v(this_s.scale.x - hp_scale.x, this_s.scale.y - hp_scale.y)

		hp_s.scale = V.v(hp_scale.x + scale_diff.x * 0.5, hp_scale.y + scale_diff.y * 0.5)

		if b.from.x > b.to.x then
			hp_s.flip_x = true
		end

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

local function mod_hero_dragon_arb_passive_mark_insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return false
	end

	if band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0 then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)

		return false
	end

	if target.health.dead then
		table.insert(store.entities[this.cached_controller_dragon_arb_passive_id].root_zones_queue, {
			x = target.pos.x,
			y = target.pos.y
		})

		return false
	end

	this.modifier.ts = store.tick_ts

	signal.emit("mod-applied", this, target)

	return true
end

local function mod_hero_dragon_arb_passive_mark_remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or not target.health.dead then
		return true
	end

	table.insert(store.entities[this.cached_controller_dragon_arb_passive_id].root_zones_queue, {
		x = target.pos.x,
		y = target.pos.y
	})

	return true
end

local function decal_hero_dragon_arb_tower_plant_dark_army_update(this, store, script)
	local a = this.area_attack

	this.spawn_ts = store.tick_ts
	a.cooldown = U.frandom(a.cooldown_min, a.cooldown_max)

	U.y_animation_play(this, "spawn", nil, store.tick_ts)
	U.animation_start_default(this, "idle", nil, store.tick_ts, true)

	a.ts = store.tick_ts - a.cooldown

	while true do
		if store.tick_ts - this.spawn_ts > this.duration then
			SU.remove_modifiers(store, this)
			U.y_animation_play(this, "end", nil, store.tick_ts, 1)
			simulation:queue_remove_entity(this)

			return
		end

		if store.tick_ts - a.ts > a.cooldown then
			local target, _, pred_pos = U.find_foremost_enemy_in_range_filter_off(this.pos, a.max_range, a.hit_time, a.vis_flags, a.vis_bans)

			if not target or not pred_pos then
			-- block empty
			else
				a.ts = store.tick_ts

				S:queue(a.sound)

				local flip_x = pred_pos.x < this.pos.x

				U.animation_start_default(this, a.animation, flip_x, store.tick_ts, false)
				U.y_wait_unconditional(store, a.hit_time)

				local enemies = U.find_enemies_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

				if enemies and #enemies > 0 then
					local e = E:create_entity(a.aura)

					e.pos.x, e.pos.y = this.pos.x, this.pos.y
					e.owner = this
					e.aura.source_id = this.id

					simulation:queue_insert_entity(e)
				end

				U.y_animation_wait_default(this)
			end
		end

		coroutine.yield()
	end
end

local function bullet_hero_dragon_arb_arborean_spawn_update(this, store, script)
	local b = this.bullet
	local s = this.render.sprites[1]
	local fm = this.force_motion
	local ps

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	local iix, iiy = V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y)

	if this.initial_impulse_angle_variation_d then
		local variation_rad = math.rad(this.initial_impulse_angle_variation_d)

		variation_rad = -variation_rad + 2 * variation_rad * math.random()
		this.initial_impulse_angle_abs = this.initial_impulse_angle_abs + variation_rad
	end

	local last_pos = V.vclone(this.pos)

	b.ts = store.tick_ts

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

	while true do
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

	this.pos.x, this.pos.y = b.to.x, b.to.y

	S:queue(this.sound_hit)
	table.insert(store.entities[this.cached_controller_dragon_arb_passive_id].root_zones_dequeue, this.zone_target_id)

	if b.payload then
		local hp = E:create_entity(b.payload)
		local nearest_nodes = P:nearest_nodes(b.to.x, b.to.y, nil, {1, 2, 3}, true)
		local pi, spi, ni = unpack(nearest_nodes[1])

		hp.nav_path.pi = pi
		hp.nav_path.ni = ni
		hp.nav_path.spi = spi
		hp.pos.x, hp.pos.y = b.to.x, b.to.y
		hp.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(hp)
	end

	if b.hit_fx then
		local sfx = E:create_entity(b.hit_fx)

		sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
		sfx.render.sprites[1].ts = store.tick_ts
		sfx.render.sprites[1].runs = 0

		simulation:queue_insert_entity(sfx)
	end

	simulation:queue_remove_entity(this)
end

local function mod_hero_dragon_arb_ultimate_insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or not target.unit then
		return false
	end

	if this.received_damage_factor then
		SU.insert_received_damage_factor_by_factor(target, this.received_damage_factor)
	end

	if this.inflicted_damage_factor then
		SU.insert_unit_damage_factor_by_factor(target, this.inflicted_damage_factor)
	end

	if this.extra_armor then
		SU.armor_inc(target, this.extra_armor)
	end

	if this.extra_magic_armor then
		SU.magic_armor_inc(target, this.extra_magic_armor)
	end

	U.speed_mul_self(target, this.fast.factor)
	U.sprites_show(target, this.ultimate_sid, this.ultimate_sid, true)

	if target.tween.props[3] then
		target.tween.props[3].disabled = false
		target.tween.props[3].ts = store.tick_ts
		target.tween.reverse = false
	end

	target.tween.props[2].disabled = false
	target.tween.props[2].ts = store.tick_ts

	signal.emit("mod-applied", this, target)

	return true
end

local function mod_hero_dragon_arb_ultimate_remove(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if target and target.health and target.unit then
		if this.received_damage_factor then
			SU.remove_received_damage_factor_by_factor(target, this.received_damage_factor)
		end

		if this.inflicted_damage_factor then
			SU.remove_unit_damage_factor_by_factor(target, this.inflicted_damage_factor)
		end

		if this.extra_armor then
			SU.armor_dec(target, this.extra_armor)
		end

		if this.extra_magic_armor then
			SU.magic_armor_dec(target, this.extra_magic_armor)
		end

		U.speed_div_self(target, this.fast.factor)
		U.sprites_hide(target, this.ultimate_sid, this.ultimate_sid, true)

		if target.tween.props[3] then
			target.tween.props[3].disabled = false
			target.tween.props[3].ts = store.tick_ts
		end

		target.tween.props[2].disabled = false
		target.tween.props[2].ts = store.tick_ts
		target.tween.reverse = true
	end

	return true
end

local function mod_hero_dragon_arb_ultimate_update(this, store, script)
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

		coroutine.yield()
	end
end

local function mod_hero_dragon_arb_bleed_insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		return false
	end

	if band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0 then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)

		return false
	end

	if target and target.unit and this.render then
		local s = this.render.sprites[1]

		s.ts = store.tick_ts

		if s.size_names then
			s.name = s.size_names[target.unit.size]
		end

		if s.size_scales then
			s.scale = s.size_scales[target.unit.size]
		end

		if target.render then
			s.z = target.render.sprites[1].z
		end
	end

	this.dps.ts = store.tick_ts - this.dps.damage_every
	this.modifier.ts = store.tick_ts

	signal.emit("mod-applied", this, target)

	local passive_mark_mod = E:create_entity(this.passive_mark_mod)

	passive_mark_mod.modifier.target_id = target.id
	passive_mark_mod.cached_controller_dragon_arb_passive_id = this.cached_controller_dragon_arb_passive_id

	simulation:queue_insert_entity(passive_mark_mod)

	return true
end

local function mod_hero_dragon_arb_bleed_update(this, store, script)
	local cycles = 0
	local m = this.modifier
	local dps = this.dps
	local fx_ts = 0

	local function do_damage(target, value, damage_type)
		local d = E.assign_damage(damage_type, value, this.id, target.id)

		d.pop = dps.pop
		d.pop_chance = dps.pop_chance
		d.pop_conds = dps.pop_conds

		queue_damage(store, d)

		local passive_mark_mod = E:create_entity(this.passive_mark_mod)

		passive_mark_mod.modifier.target_id = target.id
		passive_mark_mod.cached_controller_dragon_arb_passive_id = this.cached_controller_dragon_arb_passive_id

		simulation:queue_insert_entity(passive_mark_mod)
	end

	local target = store.entities[m.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	if this.instakill_chance and not U.flag_has(target.vis.flags, this.instakill_vis_bans) and not U.flag_has(target.vis.bans, this.instakill_vis_flags) and math.random() < this.instakill_chance then
		do_damage(target, 0, DAMAGE_INSTAKILL)
	end

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead then
			break
		end

		if store.tick_ts - m.ts >= m.duration - 1e-09 then
			if dps.damage_last then
				do_damage(target, dps.damage_last, dps.damage_type)
			end

			break
		end

		if this.render and m.use_mod_offset and target.unit.mod_offset then
			local so = this.render.sprites[1].offset

			so.x, so.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end

		if dps.damage_every and store.tick_ts - dps.ts >= dps.damage_every then
			cycles = cycles + 1
			dps.ts = dps.ts + dps.damage_every

			local damage = target.motion.max_speed * this.damage_speed_ratio

			do_damage(target, damage, dps.damage_type)

			if dps.fx and (not dps.fx_every or store.tick_ts - fx_ts >= dps.fx_every) then
				fx_ts = store.tick_ts

				local fx = E:create_entity(dps.fx)

				if dps.fx_tracks_target then
					fx.pos = target.pos

					if m.use_mod_offset and target.unit.mod_offset then
						fx.render.sprites[1].offset.x = target.unit.mod_offset.x
						fx.render.sprites[1].offset.y = target.unit.mod_offset.y
					end
				else
					fx.pos:copy(this.pos)

					if m.use_mod_offset and target.unit.mod_offset then
						fx.pos.x, fx.pos.y = fx.pos.x + target.unit.mod_offset.x, fx.pos.y + target.unit.mod_offset.y
					end
				end

				fx.render.sprites[1].ts = store.tick_ts
				fx.render.sprites[1].runs = 0

				if fx.render.sprites[1].size_names then
					fx.render.sprites[1].name = fx.render.sprites[1].size_names[target.unit.size]
				end

				if fx.render.sprites[1].use_blood_color and target.unit.blood_color then
					fx.render.sprites[1].name = fx.render.sprites[1].name .. "_" .. target.unit.blood_color
				end

				if dps.fx_target_flip and target and target.render then
					fx.render.sprites[1].flip_x = target.render.sprites[1].flip_x
				end

				simulation:queue_insert_entity(fx)
			end
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function bullet_hero_dragon_arb_linirea_plant_heal_update(this, store)
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

	local iix, iiy = V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y)
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

		simulation:queue_insert_entity(fx)
	end

	if b.hit_decal then
		local decal = E:create_entity(b.hit_decal)

		decal.pos:copy(b.to)

		decal.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(decal)
	end

	if b.mod and target and not target.health.dead then
		local mod = E:create_entity(b.mod)

		mod.modifier.target_id = target.id
		mod.modifier.source_id = this.id

		simulation:queue_insert_entity(mod)
	end

	if ps and ps.particle_system.emit then
		ps.particle_system.emit = false

		U.y_wait_unconditional(store, ps.particle_system.particle_lifetime[2])
	end

	simulation:queue_remove_entity(this)
end

local function controller_hero_dragon_arb_passive_update(this, store)
	local last_expansion_ts = store.tick_ts - this.zone_expansion_cooldown
	local available_paths = {}

	for k, v in pairs(P.paths) do
		table.insert(available_paths, k)
	end

	if store.level.ignore_walk_backwards_paths then
		available_paths = table.filter(available_paths, function(k, v)
			return not table.contains(store.level.ignore_walk_backwards_paths, v) and P:is_path_active(v)
		end)
	end

	local zone_last_id = 1

	local function insert_root_zone(pos)
		local original_pos = V.vclone(pos)
		local nearest_nodes = P:nearest_nodes(pos.x, pos.y, nil, nil, true)

		if not nearest_nodes or #nearest_nodes < 1 then
			return
		end

		local pi, spi, ni = unpack(nearest_nodes[1])

		if band(GR:cell_type(pos.x, pos.y), bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK)) ~= 0 then
			return
		end

		local function is_over_other_zone()
			for _, v in pairs(this.root_zones) do
				if V.dist(v.x, v.y, pos.x, pos.y) <= this.zones_radius then
					return true
				end
			end

			return false
		end

		if is_over_other_zone() then
			local nodes_offset_plus = 0
			local nodes_offset_minus = 0
			local can_expand_plus = true
			local can_expand_minus = true
			local nodes_offset_inc = 3
			local found_new_pos = false

			while not found_new_pos and (can_expand_plus or can_expand_minus) do
				if can_expand_minus then
					nodes_offset_minus = nodes_offset_minus + nodes_offset_inc

					if P:is_node_valid(pi, ni - nodes_offset_minus) then
						pos = P:node_pos(pi, spi, ni - nodes_offset_minus)

						if band(GR:cell_type(pos.x, pos.y), bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK)) == 0 then
							if not is_over_other_zone() then
								found_new_pos = true
								can_expand_plus = false
								ni = ni - nodes_offset_minus
							end
						else
							can_expand_minus = false
						end
					else
						can_expand_minus = false
					end
				end

				if can_expand_plus then
					nodes_offset_plus = nodes_offset_plus + nodes_offset_inc

					if P:is_node_valid(pi, ni + nodes_offset_plus) then
						pos = P:node_pos(pi, spi, ni + nodes_offset_plus)

						if band(GR:cell_type(pos.x, pos.y), bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK)) == 0 then
							if not is_over_other_zone() then
								found_new_pos = true
								can_expand_minus = false
								ni = ni + nodes_offset_plus
							end
						else
							can_expand_plus = false
						end
					else
						can_expand_plus = false
					end
				end
			end

			if not found_new_pos then
				pos = V.vclone(original_pos)
			end
		end

		local zone = {}

		zone.x = pos.x
		zone.y = pos.y
		zone.ts = store.tick_ts + this.zones_duration
		zone.plant_decal_ids = {}
		zone.aura_entity = nil
		zone.zone_id = zone_last_id + 1
		zone_last_id = zone.zone_id

		local aura = E:create_entity(this.aura_slow)

		aura.aura.source_id = this.id
		aura.aura.ts = store.tick_ts
		aura.pos = V.v(zone.x, zone.y)

		simulation:queue_insert_entity(aura)

		zone.aura_entity = aura

		local nodes_count = this.zones_radius / P.average_node_dist
		local ni_inc = 2

		for i = 1, nodes_count do
			local spi = km.zmod(i, 3)

			if P:is_node_valid(pi, ni) then
				local root_pos = P:node_pos(pi, spi, ni)
				local in_another_zone = false

				for _, v in pairs(this.root_zones) do
					if V.dist(v.x, v.y, root_pos.x, root_pos.y) <= this.zones_radius then
						in_another_zone = true

						break
					end

					if v.plant_decals_ids then
						for _, other_zone_root_id in pairs(v.plant_decals_ids) do
							local o_root = store.entities[other_zone_root_id]

							if o_root and V.dist(o_root.pos.x, o_root.pos.y, root_pos.x, root_pos.y) < 20 then
								in_another_zone = true

								break
							end
						end

						if in_another_zone then
							break
						end
					end
				end

				if not in_another_zone then
					root_pos.x, root_pos.y = root_pos.x + math.random(0, 8), root_pos.y + math.random(0, 8)

					local root = E:create_entity(this.plant_decal .. "_" .. math.random(1, 2, 3))

					root.render.sprites[1].flip_x = math.random() < 0.5
					root.delay = U.frandom(0, 0.3)
					root.pos = root_pos
					root.path_i = pi
					root.node_i = ni
					root.s_path_i = spi

					simulation:queue_insert_entity(root)
					table.insert(zone.plant_decal_ids, root.id)
				end
			end

			if i % 3 == 0 then
				ni = ni - ni_inc - math.random(2, 3)
			end
		end

		table.insert(this.root_zones, zone)
	end

	local function process_new_zones_queue()
		if store.tick_ts >= last_expansion_ts + this.zone_expansion_cooldown and #this.root_zones_queue > 0 then
			insert_root_zone(this.root_zones_queue[1])

			this.root_zones_queue = {}
			last_expansion_ts = store.tick_ts
		end
	end

	local function process_zones()
		for i = #this.root_zones, 1, -1 do
			local zone = this.root_zones[i]
			local is_in_dequeue = false

			if table.contains(this.root_zones_dequeue, zone.zone_id) then
				is_in_dequeue = true

				table.removeobject(this.root_zones_dequeue, zone.zone_id)
			end

			if store.tick_ts >= zone.ts or is_in_dequeue then
				for _, v in pairs(zone.plant_decal_ids) do
					local plant_decal = store.entities[v]
					local in_range_of_another_zone = false

					for i2 = 1, #this.root_zones do
						if i2 ~= i then
							local zone2 = this.root_zones[i2]

							if V.dist(plant_decal.pos.x, plant_decal.pos.y, zone2.x, zone2.y) <= this.zones_radius then
								in_range_of_another_zone = true

								table.insert(zone2.plant_decal_ids, plant_decal.id)

								break
							end
						end
					end

					if not in_range_of_another_zone then
						plant_decal.destroy_plant = math.random() * 0.5
					end
				end

				simulation:queue_remove_entity(zone.aura_entity)
				table.remove(this.root_zones, i)
			end
		end
	end

	while true do
		process_new_zones_queue()
		process_zones()
		coroutine.yield()
	end
end

local function soldier_hero_dragon_arb_spawn_get_info(this)
	local t = scripts.soldier_barrack.get_info(this)

	t.respawn = nil

	return t
end

local function soldier_hero_dragon_arb_spawn_update(this, store, script)
	local attack = this.melee.attacks[1]
	local target
	local next_pos = V.vclone(this.pos)
	local brk, sta, nearest

	this.reinforcement.ts = store.tick_ts

	if this.doing_spawn_anim_ts == nil or this.doing_spawn_anim_ts then
		local spawn_anim_ts = this.spawn_anim_ts and this.spawn_anim_ts or store.tick_ts

		this.spawn_anim_ts = spawn_anim_ts

		U.y_animation_play(this, "spawn", nil, spawn_anim_ts, 1)

		this.doing_spawn_anim_ts = false
	end

	this.tween.ts = store.tick_ts

	if #this.tween.props > 1 then
		this.tween.props[4].disabled = false
		this.tween.props[5].disabled = false
	end

	local function break_fn()
		if this.reinforcement.duration and store.tick_ts - this.reinforcement.ts > this.reinforcement.duration then
			return true
		end

		return false
	end

	local function adjust_tween_for_despawn()
		this.tween.ts = store.tick_ts
		this.tween.props[1].disabled = false

		if #this.tween.props > 1 then
			this.tween.props[2].disabled = false
			this.tween.props[3].disabled = false
			this.tween.props[4].disabled = true
			this.tween.props[5].disabled = true
		end

		this.tween.remove = false
		this.tween.reverse = false
		this.tween.disabled = true
	end

	while true do
		if this.health.dead or not next_pos then
			this.ui.can_click = false

			adjust_tween_for_despawn()
			SU.y_soldier_death(store, this)
			simulation:queue_remove_entity(this)

			return
		end

		if this.reinforcement.duration and store.tick_ts - this.reinforcement.ts > this.reinforcement.duration then
			this.ui.can_click = false

			if this.health.hp > 0 then
				this.reinforcement.hp_before_timeout = this.health.hp
			end

			this.health.hp = 0

			adjust_tween_for_despawn()
			SU.y_soldier_death(store, this)
			simulation:queue_remove_entity(this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
		else
			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			else
				nearest = P:nearest_nodes(this.pos.x, this.pos.y, {this.nav_path.pi}, {this.nav_path.spi})

				if nearest and nearest[1] and nearest[1][3] < this.nav_path.ni then
					this.nav_path.ni = nearest[1][3]
				end

				while next_pos and not target and not this.health.dead and not this.unit.is_stunned and not break_fn() do
					U.set_destination(this, next_pos)

					local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

					U.animation_start_default(this, an, af, store.tick_ts, true)
					U.walk_off__accel__unsnapped(this, store.tick_length)
					coroutine.yield()

					target = U.find_foremost_enemy_in_range_filter_off(this.pos, this.melee.range, false, attack.vis_flags, attack.vis_bans)
					next_pos = P:next_entity_node(this, store.tick_length)

					if not next_pos or not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or GR:cell_is(next_pos.x, next_pos.y, bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK)) then
						next_pos = nil
					end
				end

				target = nil
			end
		end

		coroutine.yield()
	end
end

local function hero_dragon_arb_level_up(this, store)
	local hl, ls = level_up_basic(this)
	local b = E:get_template(this.ranged.attacks[1].bullet)

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	upgrade_skill(this, "arborean_spawn", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
	end)
	upgrade_skill(this, "tower_runes", function(this, s)
		local sl = s.level
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.cooldown = s.cooldown[sl]
		a.max_targets = s.max_targets[sl]

		local bullet = E:get_template(a.bullet)
		local mod = E:get_template(bullet.bullet.hit_mod)

		mod.damage_factor = s.damage_factor[sl]
		mod.modifier.duration = s.duration[sl]
	end)
	upgrade_skill(this, "thorn_bleed", function(this, s)
		local sl = s.level
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.cooldown = s.cooldown[sl]
		a.instakill_chance = s.instakill_chance[sl]

		local mod = E:get_template(a.mods[1])

		mod.modifier.duration = s.duration[sl]
		mod.damage_speed_ratio = s.damage_speed_ratio[sl]
	end)
	upgrade_skill(this, "tower_plants", function(this, s)
		local sl = s.level
		local a = this.timed_attacks.list[4]

		a.disabled = nil
		a.cooldown = s.cooldown[sl]
		a.max_targets = s.max_targets[sl]

		local p_lin = E:get_template(a.plant_linirea)

		p_lin.duration = s.duration[sl]

		local p_lin_b = E:get_template(p_lin.bullet_attack.bullet)
		local p_lin_b_mod = E:get_template(p_lin_b.bullet.mod)

		p_lin_b_mod.hps.heal_max = s.heal_max[sl]
		p_lin_b_mod.hps.heal_min = s.heal_min[sl]

		local p_da = E:get_template(a.plant_dark_army)

		p_da.duration = s.duration[sl]

		local p_da_mod_slow = E:get_template("mod_hero_dragon_arb_plant_dark_army_slow")

		p_da_mod_slow.slow.factor = s.slow_factor[sl]

		local p_da_mod_dps = E:get_template("mod_hero_dragon_arb_plant_dark_army_dps")

		p_da_mod_dps.dps.damage_min = s.damage_min[sl]
		p_da_mod_dps.dps.damage_max = s.damage_max[sl]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		local sl = s.level

		this.ultimate.disabled = nil
		this.ultimate.cooldown = s.cooldown[sl]

		local mod = E:get_template(s.mod)

		mod.inflicted_damage_factor = s.inflicted_damage_factor[sl]
		mod.extra_magic_armor = s.extra_magic_armor[sl]
		mod.extra_armor = s.extra_armor[sl]
		mod.fast.factor = s.speed_factor[sl]
	end)
	update_hp(this)
end

local function hero_dragon_arb_update(this, store)
	local h = this.health
	local a, skill

	this.ultimate_ts = store.tick_ts

	local s_ult = this.hero.skills.ultimate
	local attack_arborean_spawns = this.timed_attacks.list[1]
	local attack_thorn_bleed = this.timed_attacks.list[2]
	local attack_tower_runes = this.timed_attacks.list[3]
	local attack_tower_plants = this.timed_attacks.list[4]

	this.tween.disabled = false
	this.tween.ts = store.tick_ts
	this.health_bar.hidden = false

	local passive_controller = E:create_entity(this.controller_passive)

	simulation:queue_insert_entity(passive_controller)

	local function can_ranged_attack()
		local a = this.ranged.attacks[1]

		if a.disabled then
			return false
		end

		if a.sync_animation and not this.render.sprites[1].sync_flag then
			return false
		end

		if store.tick_ts - a.ts < a.cooldown then
			return false
		end

		return true
	end

	local function attack_is_tower_valid(v, a)
		local is_tower = v.tower and not v.pending_removal and not v.tower.blocked and (not a.excluded_templates or not table.contains(a.excluded_templates, v.template_name)) and v.vis and band(v.vis.flags, a.vis_bans) == 0 and band(v.vis.bans, a.vis_flags) == 0 and v.tower.can_be_mod and U.is_inside_ellipse(v.pos, this.pos, a.max_range) and (a.min_range == 0 or not U.is_inside_ellipse(v.pos, this.pos, a.min_range))

		return is_tower
	end

	local function attack_get_towers(a)
		local targets = table.filter(store.entities, function(k, v)
			return attack_is_tower_valid(v, a)
		end)

		if targets and #targets > 0 then
			return targets
		end

		return nil
	end

	this.desired_rotation = 0

	local function update_dragon_rotation(new_rotation)
		if new_rotation then
			this.desired_rotation = new_rotation
		end

		local current_rotation = math.abs(this.render.sprites[1].r)
		local rotation = U.ease_value(current_rotation, this.desired_rotation, 0.2, "linear")

		if not this.render.sprites[1].flip_x then
			rotation = -rotation
		end

		this.render.sprites[1].r = rotation
		this.render.sprites[3].r = rotation
	end

	local function y_hero_dragon_arb_walk_waypoints(store, this, animation)
		local animation = animation or "walk"
		local r = this.nav_rally
		local n = this.nav_grid
		local dest = r.pos
		local x_to_flip = 0
		local last_af
		local start_ts = store.tick_ts

		while not V.veq(this.pos, dest) do
			local w = table.remove(n.waypoints, 1) or dest
			local unsnap = #n.waypoints > 0

			U.set_destination(this, w)

			local an, af = U.animation_name_facing_point(this, animation, this.motion.dest)
			local new_af = af

			if x_to_flip > math.abs(this.pos.x - this.motion.dest.x) then
				new_af = last_af
			end

			U.animation_start_default(this, an, new_af, store.tick_ts, true)

			last_af = new_af

			local time_to_accel = 0.7
			local dist_to_break = 50
			local orig_vx = r.pos.x - this.pos.x
			local rotation_multiplier = math.min(math.abs(orig_vx) / 300, 1)
			local current_dir = -1

			if orig_vx > 0 then
				current_dir = 1
			end

			local same_dir = false

			if this.old_rally_dir == current_dir then
				same_dir = true
			end

			local old_rally_ease_step = same_dir and this.old_rally_ease_step or nil

			this.old_rally_dir = current_dir

			while not this.motion.arrived do
				if this.health.dead and not this.health.ignore_damage then
					return true
				end

				if r.new then
					return false
				end

				local vx, vy = V.sub(r.pos.x, r.pos.y, this.pos.x, this.pos.y)
				local dist = V.len(vx, vy)
				local stored_max_speed = this.motion.max_speed
				local target_ease_step, ease_from

				if dist_to_break < dist then
					target_ease_step = (store.tick_ts - start_ts) / time_to_accel
					ease_from = 0
				else
					target_ease_step = dist / dist_to_break
					ease_from = 20
				end

				local ease_step = target_ease_step

				if old_rally_ease_step then
					ease_step = U.ease_value(old_rally_ease_step, target_ease_step, math.min(1, (store.tick_ts - start_ts) / (time_to_accel / 2)), "linear")
				end

				U.update_max_speed(this, U.ease_value(ease_from, stored_max_speed, ease_step, "quad-in"))

				this.old_rally_ease_step = ease_step

				local desired_rotation = math.rad(13 * this.motion.max_speed / stored_max_speed) * rotation_multiplier

				update_dragon_rotation(desired_rotation)
				U.walk(this, store.tick_length, nil, unsnap)
				U.update_max_speed(this, stored_max_speed)
				coroutine.yield()

				this.motion.speed.x, this.motion.speed.y = 0, 0
			end

			this.old_rally_ease_step = nil
			this.old_rally_dir = nil
		end
	end

	local function y_hero_dragon_arb_new_rally(store, this)
		local r = this.nav_rally

		if r.new then
			r.new = false

			U.unblock_target(store, this)

			if this.sound_events then
				S:queue(this.sound_events.change_rally_point)
			end

			local prev_immune = this.health.immune_to

			U.bans_add(this.vis, F_ALL)

			this.health.immune_to = r.immune_to

			local out = y_hero_dragon_arb_walk_waypoints(store, this)

			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
			U.bans_remove(this.vis, F_ALL)

			this.health.immune_to = prev_immune

			return out
		end
	end

	U.animation_start_group(this, this.idle_flip.last_animation, nil, store.tick_ts - fts(4), this.idle_flip.loop, this.render.sprites[1].group)

	while true do
		if h.dead then
			SU.remove_modifiers(store, this, this.hero.skills.ultimate.mod)
			U.sprites_hide(this, 3, 3, true)
			SU.y_hero_death_and_respawn(store, this)
			U.animation_start_group(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, this.render.sprites[1].group)
			U.sprites_show(this, 3, 3, true)

			this.tween.props[2].disabled = false
			this.tween.props[2].ts = store.tick_ts
			this.tween.reverse = false
		end

		if this.ultimate_active and store.tick_ts > this.ultimate_ts + s_ult.duration[s_ult.level] then
			this.tween.reverse = true
			this.tween.props[2].disabled = false
			this.tween.props[2].ts = store.tick_ts

			SU.y_hero_wait(store, this, this.tween.props[2].keys[2][1])

			this.ultimate_active = false

			SU.remove_modifiers(store, this, s_ult.mod)
		end

		while this.nav_rally.new do
			y_hero_dragon_arb_new_rally(store, this)
		end

		if SU.hero_level_up(store, this) then
			U.y_animation_play_group(this, "levelup", nil, store.tick_ts, 1, this.render.sprites[1].group)
		end

		if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) and find_target_at_critical_moment(this, 200, F_RANGED, F_NONE) then
			if not this.ultimate_active then
				local ue = E:create_entity(this.hero.skills.ultimate.controller_name)

				simulation:queue_insert_entity(ue)

				this.ultimate.ts = store.tick_ts

				SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
			else
				this.ultimate.ts = this.ultimate.ts + 1
			end
		end

		if can_ranged_attack() then
			local a = this.ranged.attacks[1]
			local bullet_t = E:get_template(a.bullet)
			local flight_time = bullet_t.bullet.flight_time
			local target = U.find_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, a.shoot_time + flight_time, a.vis_flags, a.vis_bans)

			for _, e in pairs(store.entities) do
				if e.remove_this_decal_aa then
					simulation:queue_remove_entity(e)

					break
				end
			end

			if target then
				do
					local start_ts = store.tick_ts
					local b
					local bullet_start_offset = V.vv(0)
					local apply_thorn_bleed = false

					if not attack_thorn_bleed.disabled and store.tick_ts - attack_thorn_bleed.ts >= attack_thorn_bleed.cooldown then
						apply_thorn_bleed = true
					end

					local node_offset = P:predict_enemy_node_advance(target, flight_time)
					local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
					local an, af = U.animation_name_facing_point(this, a.animation, t_pos)

					U.animation_start_group(this, an, af, store.tick_ts, false, this.render.sprites[1].group)
					S:queue(a.start_sound, a.start_sound_args)

					while store.tick_ts - start_ts < a.shoot_times[1] do
						if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
							goto label_819_0
						end

						coroutine.yield()
					end

					S:queue(a.sound)

					if a.bullet_start_offset and #a.bullet_start_offset == 2 then
						local offset_index = af and 2 or 1

						bullet_start_offset = a.bullet_start_offset[offset_index]
					end

					local bullet_from_pos = V.v(this.pos.x + (af and -1 or 1) * bullet_start_offset.x, this.pos.y + bullet_start_offset.y)
					local bullet_dest_pos = V.vclone(t_pos)

					if band(target.vis.flags, F_FLYING) ~= 0 and target.unit.hit_offset then
						bullet_dest_pos.x = bullet_dest_pos.x + target.unit.hit_offset.x
						bullet_dest_pos.y = bullet_dest_pos.y + target.unit.hit_offset.y
					end

					local diff = V.v(bullet_dest_pos.x - bullet_from_pos.x, bullet_dest_pos.y - bullet_from_pos.y)
					local normal_x, normal_y = V.normalize(diff.x, diff.y)
					local angle = V.angleTo(normal_x, normal_y)
					local fliers_bullet_damage_pos = V.v(bullet_dest_pos.x - diff.x / 3, bullet_dest_pos.y - diff.y / 3)

					if band(target.vis.flags, F_FLYING) ~= 0 and target.unit.hit_offset then
						local extra_dist = target.unit.hit_offset.y / math.sin(angle)

						fliers_bullet_damage_pos.x = bullet_dest_pos.x
						fliers_bullet_damage_pos.y = bullet_dest_pos.y
						bullet_dest_pos.x = bullet_dest_pos.x - normal_x * extra_dist
						bullet_dest_pos.y = bullet_dest_pos.y - normal_y * extra_dist
					end

					b = E:create_entity(a.bullet_ray)
					b.bullet.target_id = target.id
					b.bullet.source_id = this.id
					b.bullet.xp_dest_id = this.id

					b.pos:copy(bullet_from_pos)
					b.bullet.from:copy(b.pos)
					b.bullet.to:copy(bullet_dest_pos)
					simulation:queue_insert_entity(b)

					if this.ultimate_active or apply_thorn_bleed then
						local function create_mouth_fx(fx_t, offset)
							local fx = E:create_entity(fx_t)

							fx.pos = V.v(b.pos.x + normal_x * offset, b.pos.y + normal_y * offset)

							local s = fx.render.sprites[1]

							s.r = angle
							s.ts = store.tick_ts
							s.flip_x = this.render.sprites[1].flip_x

							if s.flip_x then
								s.r = s.r + math.rad(180)
							end

							simulation:queue_insert_entity(fx)
						end

						if this.ultimate_active then
							create_mouth_fx(a.ultimate_fx, a.ultimate_fx_offset)
						end

						if apply_thorn_bleed then
							create_mouth_fx(a.spikes_fx, a.spikes_fx_offset)
						end
					end

					if apply_thorn_bleed then
						b = E:create_entity(a.bullet_spikes)
						b.bullet.target_id = target.id
						b.bullet.source_id = this.id
						b.bullet.xp_dest_id = this.id
						b.pos = V.v(bullet_from_pos.x + math.random(-5, 5), bullet_from_pos.y + math.random(-5, 5))

						b.bullet.from:copy(b.pos)

						b.fliers_damage_pos = V.vclone(fliers_bullet_damage_pos)
						b.bullet.to = V.v(bullet_dest_pos.x + math.random(-20, 20), bullet_dest_pos.y + math.random(-20, 20))

						simulation:queue_insert_entity(b)
						SU.hero_gain_xp_from_skill(this, this.hero.skills.thorn_bleed)
					end

					a.ts = start_ts

					if a.xp_from_skill then
						SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
					end

					for shot_time_i = 1, #a.shoot_times do
						while store.tick_ts - start_ts < a.shoot_times[shot_time_i] do
							if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
								goto label_819_0
							end

							coroutine.yield()
						end

						b = E:create_entity(a.bullet)
						b.bullet.target_id = target.id
						b.bullet.source_id = this.id
						b.bullet.xp_gain_factor = a.xp_gain_factor
						b.bullet.xp_dest_id = this.id
						b.pos = V.v(bullet_from_pos.x + math.random(-5, 5), bullet_from_pos.y + math.random(-5, 5))

						b.bullet.from:copy(b.pos)

						b.fliers_damage_pos = V.vclone(fliers_bullet_damage_pos)
						b.bullet.to = V.v(bullet_dest_pos.x + math.random(-20, 20), bullet_dest_pos.y + math.random(-20, 20))
						b.bullet.damage_max = b.bullet.damage_max / #a.shoot_times
						b.bullet.damage_min = b.bullet.damage_min / #a.shoot_times
						b.bullet.damage_factor = this.unit.damage_factor
						b.cached_controller_dragon_arb_passive_id = passive_controller.id

						if apply_thorn_bleed then
							b.bullet.mods = table.deepclone(attack_thorn_bleed.mods)

							if this.ultimate_active then
								b.instakill_chance = attack_thorn_bleed.instakill_chance
							end
						end

						simulation:queue_insert_entity(b)
					end

					if apply_thorn_bleed then
						attack_thorn_bleed.ts = start_ts
					end

					SU.y_hero_animation_wait(this)
					U.animation_start_group(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, this.render.sprites[1].group)
				end

				::label_819_0::
			end
		end

		skill = this.hero.skills.arborean_spawn
		a = attack_arborean_spawns

		if not a.disabled and store.tick_ts - a.ts > a.cooldown then
			local plant_zones = table.filter(passive_controller.root_zones, function(k, v)
				if not U.is_inside_ellipse({
					x = v.x,
					y = v.y
				}, this.pos, a.max_range) then
					return false
				end

				if a.min_range ~= 0 and not not U.is_inside_ellipse({
					x = v.x,
					y = v.y
				}, this.pos, a.min_range) then
					return false
				end

				local enemies = U.find_enemies_in_range_filter_off({
					x = v.x,
					y = v.y
				}, a.spawn_max_range_to_enemy, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < 1 then
					return false
				end

				return true
			end)

			if not plant_zones or #plant_zones < a.min_targets then
				a.ts = a.ts + fts(10)
			else
				plant_zones = table.random_order(plant_zones)
				plant_zones = table.slice(plant_zones, 1, a.max_targets)

				local start_ts = store.tick_ts

				S:queue(a.sound)
				U.animation_start_group(this, a.animation, nil, store.tick_ts, false, this.render.sprites[1].group)

				if SU.y_hero_wait(store, this, a.cast_time) then
					goto label_819_1
				end

				a.ts = start_ts

				SU.hero_gain_xp_from_skill(this, skill)

				for i = 1, #plant_zones do
					local zone_target = plant_zones[i]
					local b = E:create_entity(a.bullet)

					b.bullet.target_id = nil
					b.bullet.source_id = this.id
					b.bullet.xp_dest_id = this.id

					b.pos:copy(this.pos)

					local bullet_start_offset = v(0, 0)
					local af = this.render.sprites[1].flip_x

					if a.bullet_start_offset and #a.bullet_start_offset == 2 then
						local offset_index = af and 2 or 1

						bullet_start_offset = a.bullet_start_offset[offset_index]
					end

					b.pos.x = b.pos.x + (af and -1 or 1) * bullet_start_offset.x
					b.pos.y = b.pos.y + bullet_start_offset.y

					b.bullet.from:copy(b.pos)

					b.bullet.to = V.v(zone_target.x, zone_target.y)
					b.bullet.level = skill.level
					b.bullet.payload = (this.ultimate_active and a.spawn_evolved or a.spawn) .. "_lvl" .. skill.level
					b.cached_controller_dragon_arb_passive_id = passive_controller.id
					b.zone_target_id = zone_target.zone_id

					simulation:queue_insert_entity(b)

					if SU.y_hero_wait(store, this, a.shoots_delay) then
						goto label_819_1
					end
				end

				SU.y_hero_animation_wait(this)
			end
		end

		skill = this.hero.skills.tower_runes
		a = attack_tower_runes

		if not a.disabled and store.tick_ts - a.ts > a.cooldown and store.wave_group_number > 0 then
			local towers = attack_get_towers(a)

			if not towers then
				a.ts = a.ts + fts(10)
			else
				local start_ts = store.tick_ts

				S:queue(a.sound)
				U.animation_start_group(this, a.animation, nil, store.tick_ts, false, this.render.sprites[1].group)

				if SU.y_hero_wait(store, this, a.cast_time) then
					goto label_819_1
				end

				towers = attack_get_towers(a)

				if not towers then
					a.ts = a.ts + fts(60)

					SU.y_hero_animation_wait(this)

					goto label_819_1
				end

				towers = table.random_order(towers)
				towers = table.slice(towers, 1, a.max_targets)
				a.ts = start_ts

				SU.hero_gain_xp_from_skill(this, skill)

				for i = 1, #towers do
					local target = towers[i]

					if not store.entities[target.id] then
					-- block empty
					elseif not attack_is_tower_valid(target, a) then
					-- block empty
					else
						local b = E:create_entity(a.bullet)

						b.bullet.target_id = target.id
						b.bullet.source_id = this.id
						b.bullet.xp_dest_id = this.id

						b.pos:copy(this.pos)

						local bullet_start_offset = v(0, 0)
						local af = this.render.sprites[1].flip_x

						if a.bullet_start_offset and #a.bullet_start_offset == 2 then
							local offset_index = af and 2 or 1

							bullet_start_offset = a.bullet_start_offset[offset_index]
						end

						b.pos.x = b.pos.x + (af and -1 or 1) * bullet_start_offset.x
						b.pos.y = b.pos.y + bullet_start_offset.y

						b.bullet.from:copy(b.pos)

						b.bullet.to = V.v(target.pos.x, target.pos.y + 16)

						simulation:queue_insert_entity(b)

						if SU.y_hero_wait(store, this, a.shoots_delay) then
							goto label_819_1
						end
					end
				end

				SU.y_hero_animation_wait(this)
			end
		end

		skill = this.hero.skills.tower_plants
		a = attack_tower_plants

		if not a.disabled and store.tick_ts - a.ts > a.cooldown and store.wave_group_number > 0 then
			local towers = attack_get_towers(a)

			if not towers then
				a.ts = a.ts + fts(10)
			else
				local start_ts = store.tick_ts

				S:queue(a.sound)
				U.animation_start_group(this, a.animation, nil, store.tick_ts, false, this.render.sprites[1].group)

				if SU.y_hero_wait(store, this, a.cast_time) then
					goto label_819_1
				end

				towers = attack_get_towers(a)

				if not towers then
					a.ts = a.ts + fts(60)

					SU.y_hero_animation_wait(this)

					goto label_819_1
				end

				towers = table.random_order(towers)
				towers = table.slice(towers, 1, a.max_targets)
				a.ts = start_ts

				SU.hero_gain_xp_from_skill(this, skill)

				for i = 1, #towers do
					local target = towers[i]

					if not store.entities[target.id] then
					-- block empty
					elseif not attack_is_tower_valid(target, a) then
					-- block empty
					else
						local b = E:create_entity(a.bullet)

						b.bullet.target_id = target.id
						b.bullet.source_id = this.id
						b.bullet.xp_dest_id = this.id

						b.pos:copy(this.pos)

						local bullet_start_offset = v(0, 0)
						local af = this.render.sprites[1].flip_x

						if a.bullet_start_offset and #a.bullet_start_offset == 2 then
							local offset_index = af and 2 or 1

							bullet_start_offset = a.bullet_start_offset[offset_index]
						end

						b.pos.x = b.pos.x + (af and -1 or 1) * bullet_start_offset.x
						b.pos.y = b.pos.y + bullet_start_offset.y

						b.bullet.from:copy(b.pos)
						b.bullet.to:copy(target.tower.default_rally_pos)

						if math.random() < 0.5 then
							b.bullet.hit_payload = a.plant_linirea
						else
							b.bullet.hit_payload = a.plant_dark_army
						end

						simulation:queue_insert_entity(b)
						SU.y_hero_wait(store, this, a.shots_delay)
					end
				end

				SU.y_hero_animation_wait(this)
			end
		end

		SU.soldier_idle(store, this)

		this.render.sprites[3].flip_x = this.render.sprites[1].flip_x

		SU.soldier_regen(store, this)

		::label_819_1::

		coroutine.yield()
	end
end

local function mod_hero_dragon_arb_tower_buff_update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		this.pos = target.pos
	end

	m.ts = store.tick_ts

	if this.tween then
		this.tween.ts = store.tick_ts
	end

	U.y_animation_play_group(this, "start", nil, store.tick_ts, 1, this.render.sprites[1].group)
	U.animation_start_group(this, "idle", nil, store.tick_ts, true, this.render.sprites[1].group)

	while store.tick_ts - m.ts < m.duration - this.out_anim_duration do
		coroutine.yield()
	end

	U.y_animation_play_group(this, "end", nil, store.tick_ts, 1, this.render.sprites[1].group)
	simulation:queue_remove_entity(this)
end

local function mod_hero_dragon_arb_plant_linirea_heal_update(this, store, script)
	local m = this.modifier
	local hps = this.hps
	local duration = m.duration

	if m.duration_inc then
		duration = duration + m.level * m.duration_inc
	end

	local heal_min = hps.heal_min
	local heal_max = hps.heal_max

	if hps.heal_min_inc and hps.heal_max_inc then
		heal_min = hps.heal_min + m.level * hps.heal_min_inc
		heal_max = hps.heal_max + m.level * hps.heal_max_inc
	end

	if hps.heal_inc then
		heal_min = hps.heal_min + m.level * hps.heal_inc
		heal_max = hps.heal_max + m.level * hps.heal_inc
	end

	local target = store.entities[m.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	if target.unit and target.unit.size == UNIT_SIZE_LARGE then
		for _, v in ipairs(this.render.sprites) do
			v.scale = V.v(1.4, 1.4)
		end
	end

	if target.vis and band(target.vis.flags, F_FLYING) ~= 0 then
		U.sprites_hide(this, 1, 2, true)
	end

	if target.render and target.render.sprites[1].z == Z_FLYING_HEROES then
		this.render.sprites[3].z = Z_FLYING_HEROES + 1
	end

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or duration < store.tick_ts - m.ts then
			simulation:queue_remove_entity(this)

			return
		end

		if this.render and m.use_mod_offset and target.unit.mod_offset then
			for i = 1, #this.render.sprites do
				local s = this.render.sprites[i]

				if not s.exclude_mod_offset then
					s.offset.x, s.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
				end
			end
		end

		if hps.heal_every and store.tick_ts - hps.ts >= hps.heal_every then
			hps.ts = store.tick_ts

			local heal_amount = U.heal(target, math.random(heal_min, heal_max))

			signal.emit("entity-healed", this, target, heal_amount)

			if hps.fx then
				local fx = E:create_entity(hps.fx)

				fx.pos:copy(this.pos)

				fx.render.sprites[1].ts = store.tick_ts
				fx.render.sprites[1].runs = 0

				simulation:queue_insert_entity(fx)
			end
		end

		coroutine.yield()
	end
end

local function bullet_hero_dragon_arb_tower_buff_update(this, store, script)
	local b = this.bullet
	local mspeed = b.min_speed
	local target, ps

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	if b.target_id then
		S:queue(this.sound_events.travel)
	else
		S:queue(this.sound_events.summon)
	end

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		if b.target_id then
			target = store.entities[b.target_id]
		end

		if target then
			if b.max_track_distance then
				local d = math.max(math.abs(target.pos.x - b.to.x), math.abs(target.pos.y - b.to.y))

				if d > b.max_track_distance then
					b.target_id = nil
					target = nil
				end
			else
				b.to.x, b.to.y = target.pos.x, target.pos.y
			end
		end

		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
		else
			this.render.sprites[1].r = 0
			this.render.sprites[1].flip_x = b.to.x < this.pos.x
		end

		if ps then
			ps.particle_system.emit_direction = this.render.sprites[1].r
		end

		coroutine.yield()
	end

	if target then
		local mod = E:create_entity(b.hit_mod)

		mod.modifier.target_id = target.id
		mod.modifier.source_id = b.source

		simulation:queue_insert_entity(mod)
	end

	if b.hit_fx then
		local sfx = E:create_entity(b.hit_fx)

		sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
		sfx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(sfx)
	end

	if this.tween then
		ps.particle_system.emit = false
		this.tween.disabled = false
		this.tween.ts = store.tick_ts

		U.y_wait_unconditional(store, fts(10))
	end

	simulation:queue_remove_entity(this)
end

local function hero_dragon_arb_ultimate_update(this, store)
	S:queue(this.ultimate_sound)

	for _, v in pairs(store.entities) do
		if v.template_name == "hero_dragon_arb" then
			v.ultimate_active = true
			v.ultimate_ts = store.tick_ts

			local s_ult = v.hero.skills.ultimate

			if not U.has_modifiers(store, this, s_ult.mod) then
				local modifier = E:create_entity(s_ult.mod)

				modifier.modifier.target_id = v.id
				modifier.modifier.source_id = this.id

				simulation:queue_insert_entity(modifier)
			end
		elseif table.contains(this.soldiers_target, v.template_name) and not v.health.dead then
			local mod = E:create_entity(this.soldiers_polymorph_mod)

			mod.modifier.target_id = v.id
			mod.modifier.source_id = this.id

			simulation:queue_insert_entity(mod)
		end
	end

	simulation:queue_remove_entity(this)
end

local function mod_hero_dragon_arb_ultimate_paragons_polymorph_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if target then
		this.target_ref = target

		for _, s in ipairs(target.render.sprites) do
			s.hidden = true
		end

		SU.remove_modifiers(store, target)
		SU.remove_auras(store, target)
		simulation:queue_remove_entity(target)
		U.unblock_target(store, target)

		if target.ui then
			target.ui.can_click = false
		end

		target.main_script.co = nil
		target.main_script.runs = 0

		if target.count_group then
			target.count_group.in_limbo = true
		end

		local polymorph_template

		for k, v in pairs(this.entity_t) do
			if target.template_name == v[1] then
				polymorph_template = v[2]

				break
			end
		end

		local entity_poly = E:create_entity(polymorph_template)

		entity_poly.pos = target.pos
		entity_poly.nav_path = target.nav_path

		simulation:queue_insert_entity(entity_poly)

		entity_poly.doing_spawn_anim_ts = target.doing_spawn_anim_ts
		entity_poly.spawn_anim_ts = target.spawn_anim_ts

		return true
	end

	return false
end

local function decal_hero_dragon_arb_tower_plant_linirea_update(this, store, script)
	local a = this.bullet_attack

	this.spawn_ts = store.tick_ts
	a.cooldown = U.frandom(a.cooldown_min, a.cooldown_max)

	U.y_animation_play(this, "spawn", nil, store.tick_ts)
	U.animation_start_default(this, "idle", nil, store.tick_ts, true)

	a.ts = store.tick_ts - a.cooldown

	while true do
		if store.tick_ts - this.spawn_ts > this.duration then
			SU.remove_modifiers(store, this)
			U.y_animation_play(this, "end", nil, store.tick_ts, 1)
			simulation:queue_remove_entity(this)

			return
		end

		if store.tick_ts - a.ts > a.cooldown then
			local target = U.find_nearest_soldier(store.soldiers, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(v, origin)
				return v.health and not v.health.dead and v.health.hp < v.health.hp_max and not U.has_modifiers(store, v, a.mark_mod)
			end)

			if not target then
				a.ts = a.ts + 0.2
			else
				local mark_mod = E:create_entity(a.mark_mod)

				mark_mod.modifier.target_id = target.id
				mark_mod.modifier.source_id = this.id

				simulation:queue_insert_entity(mark_mod)

				a.ts = store.tick_ts
				a.cooldown = U.frandom(a.cooldown_min, a.cooldown_max)

				local b = E:create_entity(a.bullet)
				local shooting_right = this.pos.x < target.pos.x
				local boffset = a.bullet_start_offset[shooting_right and 1 or 2]

				b.bullet.from = V.v(this.pos.x + boffset.x, this.pos.y + boffset.y)
				b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
				b.bullet.target_id = target.id
				b.bullet.source_id = this.id

				b.pos:copy(b.bullet.from)

				local target_pos = target.pos
				local an, af = U.animation_name_facing_point(this, a.animation, target_pos)

				U.animation_start_default(this, an, af, store.tick_ts, false)
				U.y_wait_unconditional(store, a.shoot_time)
				simulation:queue_insert_entity(b)
				S:queue("ArrowSound")
				U.y_animation_wait_default(this)
				U.animation_start_default(this, "idle", nil, store.tick_ts)
			end
		end

		coroutine.yield()
	end
end

tt = E:register_t("ps_bullet_hero_dragon_arb_arborean_spawn")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "hero_dragon_arborean_leaf_projectile"
tt.particle_system.loop = false
tt.particle_system.alphas = {255, 0}
tt.particle_system.particle_lifetime = {fts(4), fts(4)}
tt.particle_system.emission_rate = 14
tt.particle_system.track_rotation = true
tt = E:register_t("ps_bullet_hero_dragon_arb_rune")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "hero_dragon_arborean_rune_projectile"
tt.particle_system.loop = false
tt.particle_system.alphas = {255, 0}
tt.particle_system.particle_lifetime = {fts(5), fts(5)}
tt.particle_system.emission_rate = 14
tt = E:register_t("ps_bullet_hero_dragon_arb_water")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "hero_dragon_arborean_water_projectile_trail_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 14
tt.particle_system.track_rotation = true
tt = E:register_t("ps_bullet_hero_dragon_arb_tower_plants")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "hero_dragon_arborean_flower_projectile_trail"
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.alphas = {255, 170, 50}
tt.particle_system.scales_x = {1.2, 1.2}
tt.particle_system.scales_y = {1.2, 1.2}
tt.particle_system.emission_rate = 70
tt.particle_system.track_rotation = true
tt = E:register_t("ps_bullet_hero_dragon_arb_breath_spikes")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "hero_dragon_arborean_spikes_projectile_trail_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(5), fts(10)}
tt.particle_system.emission_rate = 50
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.z = Z_BULLETS + 1
tt = E:register_t("decal_dragon_arb_breath_splint_a", "decal_timed")
tt.render.sprites[1].prefix = "hero_dragon_arborean_splinter_ground_a"
tt.render.sprites[1].name = "idle"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].loop = false
tt.render.sprites[2].name = "hero_dragon_arborean_splinter_decal"
tt.render.sprites[2].z = Z_DECALS
tt = E:register_t("decal_dragon_arb_breath_splint_b", "decal_timed")
tt.render.sprites[1].prefix = "hero_dragon_arborean_splinter_ground_b"
tt.render.sprites[1].name = "idle"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].loop = false
tt.render.sprites[2].name = "hero_dragon_arborean_splinter_decal"
tt.render.sprites[2].z = Z_DECALS
tt = E:register_t("hero_dragon_arb", "hero")

E:add_comps(tt, "ranged", "timed_attacks", "tween")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.magic_armor = {0.03, 0.06, 0.09, 0.12, 0.15, 0.18, 0.21, 0.24, 0.27, 0.3}
tt.hero.level_stats.hp_max = {254, 286, 318, 351, 384, 416, 448, 481, 514, 546}
tt.hero.level_stats.melee_damage_max = {1, 2, 4, 4, 5, 6, 7, 8, 9, 10}
tt.hero.level_stats.melee_damage_min = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
tt.hero.level_stats.ranged_damage_min = {11, 14, 16, 19, 23, 26, 29, 31, 35, 38}
tt.hero.level_stats.ranged_damage_max = {16, 20, 25, 29, 35, 39, 44, 48, 53, 58}
tt.hero.skills.arborean_spawn = E:clone_c("hero_skill")
tt.hero.skills.arborean_spawn.cooldown = {35, 35, 35}
tt.hero.skills.arborean_spawn.xp_gain = {280, 560, 840}
tt.hero.skills.arborean_spawn.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.tower_runes = E:clone_c("hero_skill")
tt.hero.skills.tower_runes.cooldown = {35, 35, 35}
tt.hero.skills.tower_runes.max_targets = {3, 3, 3}
tt.hero.skills.tower_runes.duration = {6, 7, 8}
tt.hero.skills.tower_runes.damage_factor = {1.3, 1.45, 1.6}
tt.hero.skills.tower_runes.xp_gain = {280, 560, 840}
tt.hero.skills.tower_runes.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.thorn_bleed = E:clone_c("hero_skill")
tt.hero.skills.thorn_bleed.cooldown = {12, 10, 8}
tt.hero.skills.thorn_bleed.instakill_chance = {0.3, 0.3, 0.3}
tt.hero.skills.thorn_bleed.duration = {5, 5, 5}
tt.hero.skills.thorn_bleed.damage_speed_ratio = {0.375, 0.564, 0.825}
tt.hero.skills.thorn_bleed.xp_gain = {280, 560, 840}
tt.hero.skills.thorn_bleed.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.tower_plants = E:clone_c("hero_skill")
tt.hero.skills.tower_plants.cooldown = {20, 20, 20}
tt.hero.skills.tower_plants.max_targets = {1, 2, 3}
tt.hero.skills.tower_plants.duration = {8, 10, 12}
tt.hero.skills.tower_plants.heal_max = {15, 15, 15}
tt.hero.skills.tower_plants.heal_min = {15, 15, 15}
tt.hero.skills.tower_plants.slow_factor = {0.5, 0.4, 0.3}
tt.hero.skills.tower_plants.damage_min = {5, 7, 9}
tt.hero.skills.tower_plants.damage_max = {5, 7, 9}
tt.hero.skills.tower_plants.xp_gain = {280, 560, 840}
tt.hero.skills.tower_plants.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_dragon_arb_ultimate"
tt.hero.skills.ultimate.cooldown = {36, 36, 36, 36}
tt.hero.skills.ultimate.duration = {8, 10, 13, 15}
tt.hero.skills.ultimate.inflicted_damage_factor = {1.3, 1.4, 1.5, 1.6}
tt.hero.skills.ultimate.speed_factor = {1.3, 1.4, 1.5, 1.6}
tt.hero.skills.ultimate.extra_armor = {0.3, 0.4, 0.5, 0.6}
tt.hero.skills.ultimate.extra_magic_armor = {0.3, 0.4, 0.5, 0.6}
tt.hero.skills.ultimate.mod = "mod_hero_dragon_arb_ultimate"
tt.hero.skills.ultimate.skip_confirmation = true
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.flight_height = 80
tt.health.dead_lifetime = 15
tt.health_bar.draw_order = -1
tt.health_bar.offset = v(0, 170)
tt.health_bar.sort_y_offset = -171
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.health_bar.z = Z_FLYING_HEROES
tt.hero.fn_level_up = hero_dragon_arb_level_up
tt.idle_flip.cooldown = 10
tt.info.hero_portrait = "kr5_hero_portraits_0015"
tt.info.portrait = "kr5_info_portraits_heroes_0015"
tt.main_script.update = hero_dragon_arb_update
tt.motion.max_speed = 130
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.all_except_flying_nowalk = bor(TERRAIN_NONE, TERRAIN_LAND, TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_SHALLOW, TERRAIN_FAERIE, TERRAIN_ICE)
tt.nav_grid.valid_terrains = tt.all_except_flying_nowalk
tt.nav_grid.valid_terrains_dest = tt.all_except_flying_nowalk
tt.drag_line_origin_offset = v(0, tt.flight_height)
tt.ultimate = {
	ts = 0,
	cooldown = 36
}
tt.regen.cooldown = 1
tt.render.sprites[1].offset.y = tt.flight_height
tt.render.sprites[1].prefix = "hero_dragon_arborean_hero"
tt.render.sprites[1].name = "respawn"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[1].group = "unit"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_dragon_arborean_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.render.sprites[2].scale = vv(0.93)
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].prefix = "hero_dragon_arborean_transformation_overlay"
tt.render.sprites[3].hidden = true
tt.render.sprites[3].scale = vv(1.1625)
tt.unit.size = UNIT_SIZE_LARGE
tt.sound_events.change_rally_point = "HeroDragonArbTaunt"
tt.sound_events.death = "HeroDragonArbDeath"
tt.sound_events.respawn = "HeroDragonArbTauntIntro"
tt.sound_events.hero_room_select = "HeroDragonArbTauntSelect"
tt.ui.click_rect = r(-37, tt.flight_height - 40, 75, 100)
tt.unit.hit_offset = v(0, tt.flight_height + 10)
tt.unit.mod_offset = v(0, tt.flight_height + 10)
tt.unit.death_animation = "death"
tt.unit.hide_after_death = true
tt.use_hidden_count_on_respawn = true
tt.hero.respawn_animation = "respawn"
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].max_angle = 85
tt.ranged.attacks[1].max_angle_fliers = 60
tt.ranged.attacks[1].bullet_ray = "bullet_hero_dragon_arb_breath"
tt.ranged.attacks[1].bullet = "bullet_hero_dragon_arb_breath_splint"
tt.ranged.attacks[1].bullet_spikes = "bullet_hero_dragon_arb_breath_spikes"
tt.ranged.attacks[1].spikes_fx = "fx_bullet_hero_dragon_arb_breath_spikes"
tt.ranged.attacks[1].spikes_fx_offset = 30
tt.ranged.attacks[1].ultimate_fx = "fx_bullet_hero_dragon_arb_breath_powered"
tt.ranged.attacks[1].ultimate_fx_offset = 30
tt.ranged.attacks[1].bullet_start_offset = {v(19, tt.flight_height + 13), v(19, tt.flight_height + 13)}
tt.ranged.attacks[1].cooldown = 1.75
tt.ranged.attacks[1].min_range = 10
tt.ranged.attacks[1].max_range = 300
tt.ranged.attacks[1].shoot_times = {fts(14), fts(16), fts(18), fts(20), fts(22), fts(24), fts(26)}
tt.ranged.attacks[1].sync_animation = true
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].basic_attack = true
tt.ranged.attacks[1].xp_gain_factor = 1.82
tt.ranged.attacks[1].sound = "HeroDragonArbAttackSplints"
tt.timed_attacks.list[1] = E:clone_c("bullet_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].animation = "power_1"
tt.timed_attacks.list[1].cast_time = fts(22)
tt.timed_attacks.list[1].shoots_delay = 0.05
tt.timed_attacks.list[1].min_targets = 2
tt.timed_attacks.list[1].max_targets = 3
tt.timed_attacks.list[1].max_range = 10000
tt.timed_attacks.list[1].spawn_max_range_to_enemy = 200
tt.timed_attacks.list[1].vis_flags = F_BLOCK
tt.timed_attacks.list[1].vis_bans = F_FLYING
tt.timed_attacks.list[1].sync_animation = true
tt.timed_attacks.list[1].xp_from_skill = "arborean_spawn"
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.timed_attacks.list[1].spawn = "soldier_hero_dragon_arb_spawn"
tt.timed_attacks.list[1].spawn_evolved = "soldier_hero_dragon_arb_spawn_paragon"
tt.timed_attacks.list[1].bullet = "bullet_hero_dragon_arb_arborean_spawn"
tt.timed_attacks.list[1].bullet_start_offset = {v(0, tt.flight_height + 95), v(0, tt.flight_height + 95)}
tt.timed_attacks.list[2] = E:clone_c("custom_attack")
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].mods = {"mod_hero_dragon_arb_bleed", "mod_bullet_hero_dragon_arb_breath_spike_hit"}
tt.timed_attacks.list[3] = E:clone_c("bullet_attack")
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].animation = "power_2"
tt.timed_attacks.list[3].cast_time = fts(25)
tt.timed_attacks.list[3].shoots_delay = 0.05
tt.timed_attacks.list[3].excluded_templates = {}
tt.timed_attacks.list[3].max_range = 300
tt.timed_attacks.list[3].sync_animation = true
tt.timed_attacks.list[3].xp_from_skill = "tower_runes"
tt.timed_attacks.list[3].vis_flags = bor(F_RANGED, F_MOD)
tt.timed_attacks.list[3].bullet = "bullet_hero_dragon_arb_tower_buff"
tt.timed_attacks.list[3].bullet_start_offset = {v(40, tt.flight_height + 15), v(-40, tt.flight_height + 15)}
tt.timed_attacks.list[4] = E:clone_c("bullet_attack")
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].animation = "power_4"
tt.timed_attacks.list[4].cast_time = fts(26)
tt.timed_attacks.list[4].shots_delay = fts(3)
tt.timed_attacks.list[4].excluded_templates = {}
tt.timed_attacks.list[4].max_range = 300
tt.timed_attacks.list[4].sync_animation = true
tt.timed_attacks.list[4].xp_from_skill = "tower_plants"
tt.timed_attacks.list[4].vis_flags = bor(F_RANGED, F_MOD)
tt.timed_attacks.list[4].bullet = "bullet_hero_dragon_arb_tower_plants"
tt.timed_attacks.list[4].bullet_start_offset = {v(0, tt.flight_height + 100), v(0, tt.flight_height + 100)}
tt.timed_attacks.list[4].plant_linirea = "decal_hero_dragon_arb_tower_plant_linirea"
tt.timed_attacks.list[4].plant_dark_army = "decal_hero_dragon_arb_tower_plant_dark_army"
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.tween.props[1].ignore_reverse = true
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {{0, 0}, {0.2, 255}}
tt.tween.props[2].sprite_id = 3
tt.tween.props[2].disabled = true
tt.controller_passive = "controller_hero_dragon_arb_passive"
tt = E:register_t("hero_dragon_arb_ultimate")

E:add_comps(tt, "pos", "main_script", "sound_events")

tt.main_script.update = hero_dragon_arb_ultimate_update
tt.soldiers_target = {"soldier_hero_dragon_arb_spawn_lvl1", "soldier_hero_dragon_arb_spawn_lvl2", "soldier_hero_dragon_arb_spawn_lvl3"}
tt.soldiers_polymorph_mod = "mod_hero_dragon_arb_ultimate_paragons_polymorph"
tt.ultimate_sound = "HeroDragonArbUltimate"
tt = E:register_t("fx_bullet_hero_dragon_arb_breath_powered", "fx")
tt.render.sprites[1].name = "hero_dragon_arborean_powered_hit_fx_idle"
tt.render.sprites[1].z = Z_BULLETS + 3
tt.render.sprites[1].scale = vv(1.25)
tt = E:register_t("fx_bullet_hero_dragon_arb_breath_spikes", "fx")
tt.render.sprites[1].name = "hero_dragon_arborean_spikes_mouth_fx_idle"
tt.render.sprites[1].anchor = v(0.621, 0.5)
tt.render.sprites[1].r = math.rad(45)
tt.render.sprites[1].z = Z_BULLETS + 2
tt = E:register_t("fx_bullet_hero_dragon_arb_arboreans_hit", "fx")
tt.render.sprites[1].prefix = "hero_dragon_arborean_hit_fx"
tt.render.sprites[1].name = "run"
tt = E:register_t("fx_water_bullet_hero_dragon_arb_water_decal", "fx")
tt.render.sprites[1].name = "hero_dragon_arborean_water_ground_fx_idle"
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("fx_water_bullet_hero_dragon_arb_water_hit", "fx")
tt.render.sprites[1].name = "hero_dragon_arborean_water_hit_fx_idle"
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("fx_bullet_hero_dragon_arb_linirea_plant_heal_hit", "fx")
tt.render.sprites[1].name = "hero_dragon_arborean_flower_projectile_hit_fx_idle"
tt = E:register_t("mod_bullet_hero_dragon_arb_breath_hit", "modifier")

E:add_comps(tt, "render")

tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = 1
tt.modifier.vis_flags = F_MOD
tt.chance = 0.24
tt.max_targets_per_hit = 2
tt.render.sprites[1].prefix = "hero_dragon_arborean_hit_fx"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].loop = false
tt = E:register_t("mod_bullet_hero_dragon_arb_breath_spike_hit", "mod_bullet_hero_dragon_arb_breath_hit")
tt.render.sprites[1].prefix = "hero_dragon_arborean_spikes_projectile_hit_fx"
tt.render.sprites[1].name = "idle"
tt = E:register_t("mod_hero_dragon_arb_ultimate", "modifier")

E:add_comps(tt, "render", "fast")

tt.main_script.insert = mod_hero_dragon_arb_ultimate_insert
tt.main_script.update = mod_hero_dragon_arb_ultimate_update
tt.main_script.remove = mod_hero_dragon_arb_ultimate_remove
tt.modifier.duration = 1e+99
tt.fast.factor = nil
tt.render.sprites[1].prefix = "hero_dragon_arborean_transformation_fx"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_FLYING_HEROES + 1
tt.ultimate_sid = 3
tt = E:register_t("soldier_hero_dragon_arb_spawn", "unit")

E:add_comps(tt, "soldier", "motion", "nav_path", "main_script", "sound_events", "vis", "info", "melee", "reinforcement", "tween")

tt.info.enc_icon = 3
tt.info.portrait = "kr5_info_portraits_soldiers_0032"
tt.info.fn = soldier_hero_dragon_arb_spawn_get_info
tt.health.armor = 0
tt.health.magic_armor = 0
tt.health_bar.offset = v(0, 53)
tt.main_script.update = soldier_hero_dragon_arb_spawn_update
tt.melee.attacks[1].cooldown = 2
-- tt.melee.attacks[1].hit_fx = "fx_enemy_deathwood_hit"
tt.melee.attacks[1].hit_time = fts(18)
tt.melee.attacks[1].hit_offset = v(45, 10)
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].sound = "HeroDragonArbArboreansHit"
tt.melee.range = 70
tt.motion.max_speed = 30
tt.nav_path.dir = -1
tt.render.sprites[1].prefix = "hero_dragon_arborean_arborean"
tt.render.sprites[1].group = "unit"
tt.render.sprites[1].scale = vv(0.93)
tt.ui.click_rect = r(-25, 0, 50, 50)
tt.unit.hit_offset = v(0, 22)
tt.unit.head_offset = v(0, 10)
tt.unit.marker_offset = v(-1, 0)
tt.unit.mod_offset = v(0, 19)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.can_explode = false
tt.unit.blood_color = BLOOD_GRAY
tt.unit.fade_time_after_death = 3
tt.unit.fade_duration_after_death = 0.3
tt.soldier.melee_slot_offset.x = 5
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.vis.flags = bor(F_FRIEND)
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.props[1].disabled = true
tt.tween.remove = false
tt.tween.disabled = false

for i = 1, 3 do
	tt = E:register_t("soldier_hero_dragon_arb_spawn_lvl" .. i, "soldier_hero_dragon_arb_spawn")
	tt.health.hp_max = ({104, 143, 182})[i]
	tt.melee.attacks[1].damage_max = ({4, 6, 8})[i]
	tt.melee.attacks[1].damage_min = ({2, 3, 5})[i]
	tt.reinforcement.duration = ({10, 12, 14})[i]
end

tt = E:register_t("soldier_hero_dragon_arb_spawn_paragon", "soldier_hero_dragon_arb_spawn")
tt.health.armor = 0
tt.health.magic_armor = 0
tt.melee.attacks[1].cooldown = 1
tt.ui.click_rect = r(-25, 0, 50, 50)
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].prefix = "hero_dragon_arborean_arborean_powered_fx_front"
tt.render.sprites[2].alpha = 0
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].prefix = "hero_dragon_arborean_arborean_powered_fx_back_idle"
tt.render.sprites[3].scale = vv(1, 0.8)
tt.render.sprites[3].sort_y_offset = 1
tt.render.sprites[3].scale = vv(0.93)
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[2].name = "alpha"
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].disabled = true
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[3].name = "alpha"
tt.tween.props[3].sprite_id = 3
tt.tween.props[3].disabled = true
tt.tween.props[4] = E:clone_c("tween_prop")
tt.tween.props[4].keys = {{0, 0}, {fts(4), 255}}
tt.tween.props[4].name = "alpha"
tt.tween.props[4].sprite_id = 2
tt.tween.props[4].disabled = true
tt.tween.props[5] = E:clone_c("tween_prop")
tt.tween.props[5].keys = {{0, 0}, {fts(4), 255}}
tt.tween.props[5].name = "alpha"
tt.tween.props[5].sprite_id = 3
tt.tween.props[5].disabled = true

for i = 1, 3 do
	tt = E:register_t("soldier_hero_dragon_arb_spawn_paragon_lvl" .. i, "soldier_hero_dragon_arb_spawn_paragon")
	tt.health.hp_max = ({156, 208, 260})[i]
	tt.melee.attacks[1].damage_max = ({12, 16, 20})[i]
	tt.melee.attacks[1].damage_min = ({8, 12, 16})[i]
	tt.reinforcement.duration = ({10, 12, 14})[i]
end

tt = E:register_t("mod_hero_dragon_arb_bleed", "modifier")

E:add_comps(tt, "dps")

tt.main_script.insert = mod_hero_dragon_arb_bleed_insert
tt.main_script.update = mod_hero_dragon_arb_bleed_update
tt.modifier.vis_flags = bor(F_MOD)
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_type = DAMAGE_MAGICAL
tt.dps.damage_every = 0.75
tt.dps.fx = "fx_bleeding"
tt.dps.fx_with_blood_color = true
tt.dps.fx_target_flip = true
tt.dps.fx_tracks_target = true
tt.passive_mark_mod = "mod_hero_dragon_arb_passive_mark"
tt.instakill_vis_flags = bor(F_INSTAKILL)
tt.instakill_vis_bans = bor(F_BOSS, F_MINIBOSS)
tt = E:register_t("mod_hero_dragon_arb_tower_buff", "modifier")

E:add_comps(tt, "render")

tt.main_script.insert = scripts.mod_tower_factors.insert
tt.main_script.remove = scripts.mod_tower_factors.remove
tt.main_script.update = mod_hero_dragon_arb_tower_buff_update
tt.range_factor = 1
tt.render.sprites[1].prefix = "hero_dragon_arborean_tower_fx_a"
tt.render.sprites[1].offset.y = 33
tt.render.sprites[1].sort_y_offset = -10
tt.render.sprites[1].draw_order = DO_TOWER_MODS
tt.render.sprites[1].group = "layers"
tt.render.sprites[1].scale = vv(1.25)
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].prefix = "hero_dragon_arborean_tower_fx_b"
tt.out_anim_duration = fts(29)
tt.render.sprites[1].name = "idle"
tt = E:register_t("decal_hero_dragon_arb_tower_plant_linirea", "decal_scripted")

E:add_comps(tt, "bullet_attack")

tt.render.sprites[1].prefix = "hero_dragon_arborean_flower"
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].sort_y_offset = 1
tt.main_script.update = decal_hero_dragon_arb_tower_plant_linirea_update
tt.bullet_attack.max_range = 240
tt.bullet_attack.bullet = "bullet_hero_dragon_arb_linirea_plant_heal"
tt.bullet_attack.mark_mod = "mod_hero_dragon_arb_plant_linirea_heal_mark"
tt.bullet_attack.shoot_time = fts(6)
tt.bullet_attack.cooldown_min = 0.5
tt.bullet_attack.cooldown_max = 0.5
tt.bullet_attack.bullet_start_offset = {v(0, 30), v(0, 30)}
tt.bullet_attack.animation = "attack"
tt.bullet_attack.vis_flags = bor(F_RANGED, F_MOD)
tt = E:register_t("decal_hero_dragon_arb_tower_plant_dark_army", "decal_scripted")

E:add_comps(tt, "area_attack")

tt.render.sprites[1].prefix = "hero_dragon_arborean_mushroom"
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].sort_y_offset = 1
tt.main_script.update = decal_hero_dragon_arb_tower_plant_dark_army_update
tt.area_attack.max_range = 120
tt.area_attack.aura = "aura_hero_dragon_arb_plant_dark_army_slow"
tt.area_attack.hit_time = fts(14)
tt.area_attack.cooldown_min = 2
tt.area_attack.cooldown_max = 2
tt.area_attack.animation = "attack"
tt.area_attack.vis_flags = bor(tt.area_attack.vis_flags, F_MOD)
tt.area_attack.vis_bans = 0
tt = E:register_t("mod_hero_dragon_arb_plant_linirea_heal", "modifier")

E:add_comps(tt, "hps", "render")

tt.render.sprites[1].prefix = "hero_dragon_arborean_heal_back"
tt.render.sprites[1].sort_y_offset = 5
tt.render.sprites[1].anchor = v(0.5, 0.6)
tt.render.sprites[1].loop = false
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].prefix = "hero_dragon_arborean_heal_front_a"
tt.render.sprites[2].sort_y_offset = -1
tt.render.sprites[2].anchor = v(0.5, 0.7)
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].prefix = "hero_dragon_arborean_heal_front_b"
tt.modifier.duration = 1.5
tt.hps.heal_every = 0.2
tt.hps.heal_min = nil
tt.hps.heal_max = nil
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = mod_hero_dragon_arb_plant_linirea_heal_update
tt = E:register_t("mod_hero_dragon_arb_plant_linirea_heal_mark", "modifier")

E:add_comps(tt, "mark_flags")

tt.mark_flags.vis_bans = F_CUSTOM
tt.modifier.duration = 1.5 + 2
tt.main_script.insert = scripts.mod_mark_flags.insert
tt.main_script.remove = scripts.mod_mark_flags.remove
tt.main_script.update = scripts.mod_mark_flags.update
tt = E:register_t("mod_hero_dragon_arb_plant_dark_army_slow", "mod_slow")
tt.slow.factor = nil
tt = E:register_t("mod_hero_dragon_arb_plant_dark_army_dps", "modifier")

E:add_comps(tt, "dps")

tt.modifier.duration = 0.5
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_type = DAMAGE_MAGICAL
tt.dps.damage_every = 0.25
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt = E:register_t("aura_hero_dragon_arb_plant_dark_army_slow", "aura")
tt.aura.mods = {"mod_hero_dragon_arb_plant_dark_army_slow", "mod_hero_dragon_arb_plant_dark_army_dps"}
tt.aura.duration = fts(32)
tt.aura.cycle_time = 0.3
tt.aura.radius = 120
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_MOD)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt = E:register_t("mod_hero_dragon_arb_passive_slow", "mod_slow")

E:add_comps(tt)

tt.modifier.duration = 0.3
tt.slow.factor = 0.5
tt = E:register_t("aura_hero_dragon_arb_passive_slow", "aura")

E:add_comps(tt)

tt.aura.mods = {"mod_hero_dragon_arb_passive_slow"}
tt.aura.duration = 1e+99
tt.aura.cycle_time = 0.2
tt.aura.radius = 15
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_MOD)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt = E:register_t("mod_hero_dragon_arb_passive_mark", "modifier")

E:add_comps(tt)

tt.main_script.insert = mod_hero_dragon_arb_passive_mark_insert
tt.main_script.remove = mod_hero_dragon_arb_passive_mark_remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = 0.2
tt = E:register_t("bullet_hero_dragon_arb_breath", "bullet")
tt.render.sprites[1].prefix = "hero_dragon_arborean_breath"
tt.render.sprites[1].anchor = v(0.464, 0.5)
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = false
tt.bullet.flight_time = fts(19)
tt.image_width = 146.5
tt.hit_delay = fts(1)
tt.bullet.hit_time = fts(1)
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.ignore_hit_offset = true
tt.main_script.update = scripts.ray_simple.update
tt.passive_mark_mod = "mod_hero_dragon_arb_passive_mark"
tt = E:register_t("bullet_hero_dragon_arb_breath_splint", "bolt")

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "hero_dragon_arborean_splinter_projectile"
tt.render.sprites[1].animated = false
tt.size_variation = 0.3
tt.bullet.align_with_trajectory = true
tt.bullet.flight_time = fts(19)
tt.bullet.min_speed = 900
tt.bullet.max_speed = 3000
tt.speed_variation = 0.3
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.mods = {"mod_bullet_hero_dragon_arb_breath_hit"}
tt.bullet.damage_radius = 40
tt.bullet.damage_flags = F_AREA
tt.bullet.hit_fx = nil
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.payload = {"decal_dragon_arb_breath_splint_a", "decal_dragon_arb_breath_splint_b"}
tt.main_script.update = bullet_hero_dragon_arb_breath_splint_update
tt.passive_mark_mod = "mod_hero_dragon_arb_passive_mark"
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {fts(2), 255}}
tt.tween.remove = false
tt.sound_events.insert = nil
tt = E:register_t("bullet_hero_dragon_arb_breath_spikes", "bolt")

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "hero_dragon_arborean_spikes_projectile"
tt.render.sprites[1].animated = false
tt.bullet.align_with_trajectory = true
tt.bullet.flight_time = fts(19)
tt.bullet.min_speed = 450
tt.bullet.max_speed = 1500
tt.bullet.damage_flags = F_AREA
tt.bullet.hit_fx = nil
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.particles_name = "ps_bullet_hero_dragon_arb_breath_spikes"
tt.main_script.update = bullet_hero_dragon_arb_breath_splint_update
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {fts(2), 255}}
tt.tween.remove = false
tt.sound_events.insert = nil
tt = E:register_t("bullet_hero_dragon_arb_arborean_spawn", "bolt")

E:add_comps(tt, "force_motion")

tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_fx = "fx_bullet_hero_dragon_arb_arboreans_hit"
tt.bullet.ignore_hit_offset = true
tt.bullet.particles_name = "ps_bullet_hero_dragon_arb_arborean_spawn"
tt.bullet.max_speed = 150
tt.bullet.align_with_trajectory = true
tt.bullet.xp_gain_factor = nil
tt.bullet.pop_chance = 0
tt.initial_impulse = 9000
tt.initial_impulse_duration = 0.2
tt.initial_impulse_angle_abs = math.pi / 2
tt.initial_impulse_angle_variation_d = 20
tt.force_motion.a_step = 5
tt.force_motion.max_a = 3000
tt.force_motion.max_v = 300
tt.render.sprites[1].name = "hero_dragon_arborean_leaf_projectile"
tt.render.sprites[1].animated = false
tt.main_script.update = bullet_hero_dragon_arb_arborean_spawn_update
tt.sound_events.insert = nil
tt = E:register_t("bullet_hero_dragon_arb_tower_buff", "bolt")

E:add_comps(tt, "force_motion", "tween")

tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_fx = nil
tt.bullet.ignore_hit_offset = true
tt.bullet.particles_name = "ps_bullet_hero_dragon_arb_rune"
tt.bullet.min_speed = 150
tt.bullet.align_with_trajectory = false
tt.bullet.xp_gain_factor = nil
tt.bullet.pop_chance = 0
tt.bullet.hit_mod = "mod_hero_dragon_arb_tower_buff"
tt.force_motion.a_step = 5
tt.force_motion.max_a = 3000
tt.force_motion.max_v = 600
tt.render.sprites[1].name = "hero_dragon_arborean_rune_projectile"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{0, 255}, {fts(4), 0}}
tt.tween.props[1].name = "alpha"
tt.tween.disabled = true
tt.main_script.update = bullet_hero_dragon_arb_tower_buff_update
tt.sound_events.insert = nil
tt = E:register_t("bullet_hero_dragon_arb_tower_plants", "bomb")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.damage_radius = 0
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.rotation_speed = 0
tt.bullet.hit_decal = "fx_water_bullet_hero_dragon_arb_water_decal"
tt.bullet.hit_fx = "fx_water_bullet_hero_dragon_arb_water_hit"
tt.bullet.particles_name = "ps_bullet_hero_dragon_arb_water"
tt.bullet.align_with_trajectory = true
tt.bullet.xp_gain_factor = nil
tt.bullet.pop = nil
tt.bullet.pop_chance = 0
tt.render.sprites[1].prefix = "hero_dragon_arborean_water_projectile"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.sound_events.insert = nil
tt.sound_events.hit = nil
tt.sound_events.hit_water = nil
tt = E:register_t("bullet_hero_dragon_arb_linirea_plant_heal", "bolt")

E:add_comps(tt, "force_motion")

tt.render.sprites[1].name = "hero_dragon_arborean_flower_projectile"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = vv(0.5)
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_fx = "fx_bullet_hero_dragon_arb_linirea_plant_heal_hit"
tt.bullet.particles_name = "ps_bullet_hero_dragon_arb_tower_plants"
tt.bullet.align_with_trajectory = true
tt.bullet.vis_flags = bor(F_RANGED, F_MOD)
tt.bullet.mod = "mod_hero_dragon_arb_plant_linirea_heal"
tt.initial_impulse = 15000
tt.initial_impulse_duration = 0.15
tt.initial_impulse_angle_abs = math.pi / 2
tt.force_motion.a_step = 5
tt.force_motion.max_a = 3000
tt.force_motion.max_v = 300
tt.main_script.update = bullet_hero_dragon_arb_linirea_plant_heal_update
tt = E:register_t("mod_hero_dragon_arb_ultimate_paragons_polymorph", "modifier")
tt.modifier.duration = fts(2)
tt.main_script.insert = mod_hero_dragon_arb_ultimate_paragons_polymorph_insert
tt.entity_t = {{"soldier_hero_dragon_arb_spawn_lvl1", "soldier_hero_dragon_arb_spawn_paragon_lvl1"}, {"soldier_hero_dragon_arb_spawn_lvl2", "soldier_hero_dragon_arb_spawn_paragon_lvl2"}, {"soldier_hero_dragon_arb_spawn_lvl3", "soldier_hero_dragon_arb_spawn_paragon_lvl3"}}
tt = E:register_t("controller_hero_dragon_arb_passive")

E:add_comps(tt, "main_script")

tt.main_script.update = controller_hero_dragon_arb_passive_update
tt.plant_decal = "decal_hero_dragon_arb_passive_plant"
tt.aura_slow = "aura_hero_dragon_arb_passive_slow"
tt.zones_duration = 25
tt.zones_radius = 15
tt.zone_expansion_cooldown = 0.3
tt.root_zones_dequeue = {}
tt.root_zones_queue = {}
tt.root_zones = {}
