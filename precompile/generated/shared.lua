local __pc_helpers = {}
__pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"] = function(bullet, target_id, source_id)
	local vmin, vmax = bullet.damage_min, bullet.damage_max
	if (bullet.level and (bullet.level > 0)) then
		if bullet.damage_inc then
			vmax = (vmax + (bullet.damage_inc * bullet.level))
			vmin = (vmin + (bullet.damage_inc * bullet.level))
		end
	end
	local value = U.frandom(vmin, vmax)
	local d = E.assign_damage(bullet.damage_type, math.max(1, (bullet.damage_factor * value)), source_id, target_id)
	d.reduce_armor = bullet.reduce_armor
	d.reduce_magic_armor = bullet.reduce_magic_armor
	d.xp_gain_factor = bullet.xp_gain_factor
	d.xp_dest_id = bullet.xp_dest_id
	d.pop = bullet.pop
	d.pop_chance = bullet.pop_chance
	d.pop_conds = bullet.pop_conds
	d.track_damage = bullet.track_damage
	d.hooks = bullet.damage_hooks
	return d
end
__pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"] = function(store, this, ranged_attack, attack, source)
	if (not this.dodge) then
		return false
	end
	this.dodge.last_check_ts = store.tick_ts
	local is_special_attack = (ranged_attack or ((attack and (attack.type == "area"))))
	if (((((((not this.unit.is_stunned) and ((not this.enemy) or this.enemy.can_do_magic)) and this.dodge.ranged) and ((not this.dodge.cooldown) or ((store.tick_ts - this.dodge.ts) > this.dodge.cooldown))) and (((not attack) or (not attack.damage_type)) or (band(attack.damage_type, DAMAGE_NO_DODGE) == 0))) and (math.random() <= (0.6 * this.dodge.chance))) and ((not this.dodge.can_dodge) or this.dodge.can_dodge(store, this, ranged_attack, attack, source))) then
		this.dodge.last_doge_ts = store.tick_ts
		this.dodge.last_attack = attack
		this.dodge.active = true
		do
			this.dodge.from_ranged_attack = true
		end
		return true
	end
	return false
end
__pc_helpers["__pc_aura_bullet_zeppelin_hero_tank_update_1"] = function(entity, name, flip_x, ts, loop)
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			do
				a.flip_x = flip_x
			end
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if (not a.loop) then
					a.ts = ts
					a.runs = 0
				end
				do
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_bolt_1_insert_1"] = function(entity, name, flip_x, ts, loop)
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if (not a.loop) then
					a.ts = ts
					a.runs = 0
				end
				do
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_bullet_swamp_monster_bomb_tosky_update_1"] = function(bullet, target_id, source_id)
	local vmin, vmax = bullet.damage_min, bullet.damage_max
	if (bullet.level and (bullet.level > 0)) then
		do
			vmin = (vmin + (bullet.damage_min_inc * bullet.level))
		end
		do
			vmax = (vmax + (bullet.damage_max_inc * bullet.level))
		end
		if bullet.damage_inc then
			vmax = (vmax + (bullet.damage_inc * bullet.level))
			vmin = (vmin + (bullet.damage_inc * bullet.level))
		end
	end
	local value = U.frandom(vmin, vmax)
	local d = E.assign_damage(bullet.damage_type, math.max(1, (bullet.damage_factor * value)), source_id, target_id)
	d.reduce_armor = bullet.reduce_armor
	d.reduce_magic_armor = bullet.reduce_magic_armor
	d.xp_gain_factor = bullet.xp_gain_factor
	d.xp_dest_id = bullet.xp_dest_id
	d.pop = bullet.pop
	d.pop_chance = bullet.pop_chance
	d.pop_conds = bullet.pop_conds
	d.track_damage = bullet.track_damage
	d.hooks = bullet.damage_hooks
	return d
end
__pc_helpers["__pc_enemy_abomination_update_10"] = function(entity, name, flip_x, ts, loop, idx, force_ts)
	local first, last
	if idx then
		first, last = idx, idx
	else
		first, last = 1, (# entity.render.sprites)
	end
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or true) then
					a.ts = ts
					a.runs = 0
				end
				do
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_enemy_abomination_update_11"] = function(entity, name, flip_x, ts, times, idx)
	__pc_helpers["__pc_enemy_abomination_update_12"](entity, name, flip_x, ts, (times and (times > 1)), idx, true)
	local a = entity.render.sprites[(idx or 1)]
	times = ((a.loop and ((times or 1))) or 0)
	while (a.runs <= times) do
		coroutine.yield()
	end
end
__pc_helpers["__pc_enemy_abomination_update_12"] = function(entity, name, flip_x, ts, loop, idx, force_ts)
	local first, last
	if idx then
		first, last = idx, idx
	else
		first, last = 1, (# entity.render.sprites)
	end
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or true) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_enemy_abomination_update_13"] = function(entity, name, flip_x, ts, loop)
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if (not a.loop) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_enemy_abomination_update_15"] = function(store, this)
	local flip_x = ((this.motion and (this.motion.dest.x < this.pos.x)) or nil)
	__pc_helpers["__pc_enemy_abomination_update_16"](this, "idle", flip_x, store.tick_ts, true)
	coroutine.yield()
end
__pc_helpers["__pc_enemy_abomination_update_16"] = function(entity, name, flip_x, ts, loop)
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if (flip_x ~= nil) then
				a.flip_x = flip_x
			end
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if (not a.loop) then
					a.ts = ts
					a.runs = 0
				end
				do
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_enemy_abomination_update_17"] = function(store, this)
	local blocker
	local terrain_type = band(GR:cell_type(this.pos.x, this.pos.y), bor(TERRAIN_WATER, TERRAIN_LAND))
	while (not blocker) do
		if this.unit.is_stunned then
			return false, nil
		end
		if this.health.dead then
			return false, nil
		end
		if (((# this.enemy.blockers) > 0) and P:is_node_valid(this.nav_path.pi, this.nav_path.ni, NF_ALL)) then
			U.cleanup_blockers(store, this)
			blocker = store.entities[this.enemy.blockers[1]]
		end
		if (not blocker) then
			__pc_helpers["__pc_enemy_abomination_update_19"](store, this)
		else
			__pc_helpers["__pc_bolt_1_insert_1"](this, "idle", nil, store.tick_ts, true)
		end
		if (terrain_type ~= band(GR:cell_type(this.pos.x, this.pos.y), bor(TERRAIN_WATER, TERRAIN_LAND))) then
			return false, nil
		end
	end
	return true, blocker
end
__pc_helpers["__pc_enemy_abomination_update_19"] = function(store, this)
	local step = (this.motion.real_speed * store.tick_length)
	local m = this.motion
	local pos = this.pos
	if m.forced_waypoint then
		local w = m.forced_waypoint
		local dx = (w.x - pos.x)
		local dy = (w.y - pos.y)
		if (math.sqrt(((dx * dx) + (dy * dy))) < (2 * step)) then
			pos.x, pos.y = w.x, w.y
			m.forced_waypoint = nil
			return false
		end
		m.dest.x, m.dest.y = w.x, w.y
	else
		local n = this.nav_path
		local path = P.paths[n.pi][n.spi]
		local next = path[(n.ni + n.dir)]
		if ((not next) or (math.sqrt(((((next.x - pos.x)) * ((next.x - pos.x))) + (((next.y - pos.y)) * ((next.y - pos.y))))) < (2 * step))) then
			n.ni = (n.ni + n.dir)
			if ((n.ni < 1) or (n.ni > (# path))) then
				if (P.path_connections[n.pi] and (n.dir > 0)) then
					local newni = P.path_connections_spi_to_ni[n.pi][n.spi]
					n.pi = P.path_connections[n.pi]
					n.ni = (newni + n.dir)
					path = P.paths[n.pi][n.spi]
				else
					coroutine.yield()
					return false
				end
			end
			do
				S:queue(this.sound_events.new_node, this.sound_events.new_node_args)
			end
			next = path[(n.ni + n.dir)]
		end
		if (not next) then
			coroutine.yield()
			return false
		end
		m.dest.x, m.dest.y = next.x, next.y
	end
	m.arrived = false
	local dx, dy = (m.dest.x - pos.x), (m.dest.y - pos.y)
	local an
	local af = false
	do
		local _sprite = this.render.sprites[1]
		local _angles = (_sprite.angles and _sprite.angles.walk)
		if _angles then
			local _angle_count = (# _angles)
			if (_angle_count == 1) then
				an, af = _angles[1], (dx < 0)
			elseif (_angle_count == 2) then
				local _coordinate_idx = (((dy > 0) and 1) or 2)
				an = _angles[_coordinate_idx]
				af = ((((_sprite.angles_flip_horizontal and _sprite.angles_flip_horizontal[_coordinate_idx])) and ((dx >= 0))) or ((dx < 0)))
			else
				local _angle = (math.atan2(dy, dx) % 6.2831853071796)
				local _coordinate_idx = 1
				local _a1, _a2, _a3, _a4 = 45, 135, 225, 315
				if (_sprite.angles_custom and _sprite.angles_custom.walk) then
					_a1, _a2, _a3, _a4 = _sprite.angles_custom.walk[1], _sprite.angles_custom.walk[2], _sprite.angles_custom.walk[3], _sprite.angles_custom.walk[4]
				end
				local _stickiness = (_sprite.angles_stickiness and _sprite.angles_stickiness.walk)
				local _angle_deg = (_angle * 57.295779513082)
				if _stickiness then
					local _skew_factor = _sprite._last_skew_factor
					if _skew_factor then
						local _skew = (_stickiness * _skew_factor)
						_a1, _a3 = (_a1 - _skew), (_a3 - _skew)
						_a2, _a4 = (_a2 + _skew), (_a4 + _skew)
					end
					if ((_a1 <= _angle_deg) and (_angle_deg < _a2)) then
						_coordinate_idx = 2
						_sprite._last_skew_factor = 1
					elseif ((_a3 <= _angle_deg) and (_angle_deg < _a4)) then
						_coordinate_idx = 3
						_sprite._last_skew_factor = 1
					else
						_sprite._last_skew_factor = (- 1)
						if (dx < 0) then
							af = true
						end
					end
				else
					if ((_a1 <= _angle_deg) and (_angle_deg < _a2)) then
						_coordinate_idx = 2
					elseif ((_a3 <= _angle_deg) and (_angle_deg < _a4)) then
						_coordinate_idx = 3
					elseif (dx < 0) then
						af = true
					end
				end
				if (_sprite.angles_flip_vertical and _sprite.angles_flip_vertical.walk) then
					af = (dx < 0)
				end
				an = _angles[_coordinate_idx]
			end
		else
			an, af = "walk", (dx < 0)
		end
	end
	do
		local i = 1
		local a = this.render.sprites[i]
		if (not a.ignore_start) then
			a.flip_x = af
			if a.animated then
				a.loop = true
				a.name = an
			end
		end
	end
	if (((dx * dx) + (dy * dy)) <= (step * step)) then
		pos.x, pos.y = m.dest.x, m.dest.y
		m.speed.x, m.speed.y = 0, 0
		m.arrived = true
	else
		local v_angle = math.atan2(dy, dx)
		if this.heading then
			this.heading.angle = v_angle
		end
		local sx, sy = (step * math.cos(v_angle)), (step * math.sin(v_angle))
		pos.x, pos.y = (pos.x + sx), (pos.y + sy)
		m.speed.x, m.speed.y = (sx / store.tick_length), (sy / store.tick_length)
	end
	coroutine.yield()
	m.speed.x, m.speed.y = 0, 0
	return true
end
__pc_helpers["__pc_enemy_abomination_update_29"] = function(store, this, target)
	for _, i in ipairs(this.melee.order) do
		local ma = this.melee.attacks[i]
		local cooldown = ma.cooldown
		if ma.shared_cooldown then
			cooldown = this.melee.cooldown
		end
		cooldown = (cooldown * this.unit.cooldown_factor)
		if (((((not ma.disabled) and (cooldown <= (store.tick_ts - ma.ts))) and (band(ma.vis_flags, target.vis.bans) == 0)) and (band(ma.vis_bans, target.vis.flags) == 0)) and ((not ma.fn_can) or ma.fn_can(this, store, ma, target))) then
			ma.ts = store.tick_ts
			if (math.random() >= ma.chance) then
			else
				for _, aa in ipairs(this.melee.attacks) do
					if ((aa ~= ma) and aa.shared_cooldown) then
						aa.ts = ma.ts
					end
				end
				ma.ts = store.tick_ts
				S:queue(ma.sound, ma.sound_args)
				local an, af = U.animation_name_facing_point(this, ma.animation, target.pos)
				do
					local i = 1
					if this.render.sprites[i].animated then
						__pc_helpers["__pc_enemy_abomination_update_31"](this, an, af, store.tick_ts, false, i)
					end
				end
				local hit_pos = V.vclone(this.pos)
				if ma.hit_offset then
					hit_pos.x = (hit_pos.x + ((((af and (- 1)) or 1)) * ma.hit_offset.x))
					hit_pos.y = (hit_pos.y + ma.hit_offset.y)
				end
				local hit_times = ((ma.hit_times and ma.hit_times) or {ma.hit_time})
				for i = 1, (# hit_times) do
					local hit_time = hit_times[i]
					local dodged = false
					if (ma.dodge_time and target.dodge) then
						local dodge_time = ma.dodge_time
						if (target.dodge and target.dodge.time_before_hit) then
							dodge_time = (hit_time - target.dodge.time_before_hit)
						end
						while (dodge_time > (store.tick_ts - ma.ts)) do
							if ((this.health.dead or (this.unit.is_stunned and (not ma.ignore_stun))) or ((this.dodge and this.dodge.active) and (not this.dodge.silent))) then
								return false
							end
							coroutine.yield()
						end
						dodged = __pc_helpers["__pc_enemy_abomination_update_32"](store, target, false, ma, this)
					end
					while (hit_time > (store.tick_ts - ma.ts)) do
						if ((this.health.dead or (this.unit.is_stunned and (not ma.ignore_stun))) or ((this.dodge and this.dodge.active) and (not this.dodge.silent))) then
							return false
						end
						coroutine.yield()
					end
					S:queue(ma.sound_hit, ma.sound_hit_args)
					if (((ma.type == "melee") and (not dodged)) and table.arraycontains(this.enemy.blockers, target.id)) then
						if ma.damage_min then
							local d = E.assign_damage(ma.damage_type, (this.unit.damage_factor * math.random(ma.damage_min, ma.damage_max)), this.id, target.id)
							d.track_kills = (this.track_kills ~= nil)
							d.track_damage = ma.track_damage
							d.pop = ma.pop
							d.pop_chance = ma.pop_chance
							d.pop_conds = ma.pop_conds
							if ma.side_effect then
								ma.side_effect(this, store, d, target)
							end
							queue_damage(store, d)
						end
						if ma.mod then
							local mod = E:create_entity(ma.mod)
							mod.modifier.target_id = target.id
							mod.modifier.source_id = this.id
							mod.modifier.damage_factor = this.unit.damage_factor
							simulation:queue_insert_entity(mod)
						end
					elseif (ma.type == "area") then
						local targets = table.filter(store.soldiers, function(_, e)
	return (((((not e.health.dead) and (band(e.vis.flags, ma.vis_bans) == 0)) and (band(e.vis.bans, ma.vis_flags) == 0)) and U.is_inside_ellipse(e.pos, hit_pos, ma.damage_radius)) and (((not ma.fn_filter) or ma.fn_filter(this, store, ma, e))))
end)
						local first_damage
						local max_count = ((ma.count and math.min((# targets), ma.count)) or (# targets))
						for i = 1, max_count do
							local e = targets[i]
							local d = E.assign_damage(ma.damage_type, (this.unit.damage_factor * math.random(ma.damage_min, ma.damage_max)), this.id, e.id)
							d.pop = ma.pop
							d.pop_chance = ma.pop_chance
							d.pop_conds = ma.pop_conds
							if (e == target) then
								if dodged then
									goto next_target
								end
								first_damage = d
							end
							queue_damage(store, d)
							if ma.mod then
								local mod = E:create_entity(ma.mod)
								mod.modifier.target_id = e.id
								mod.modifier.source_id = this.id
								mod.modifier.damage_factor = this.unit.damage_factor
								simulation:queue_insert_entity(mod)
							end
							::next_target::
						end
						if (ma.side_effect and first_damage) then
							ma.side_effect(this, store, first_damage, target)
						end
					end
					if (ma.hit_fx and ((not ma.hit_fx_once) or (i == 1))) then
						local fx = E:create_entity(ma.hit_fx)
						fx.pos = V.vclone(hit_pos)
						if ma.hit_fx_offset then
							fx.pos.x = (fx.pos.x + ((((af and (- 1)) or 1)) * ma.hit_fx_offset.x))
							fx.pos.y = (fx.pos.y + ma.hit_fx_offset.y)
						end
						if ma.hit_fx_flip then
							fx.render.sprites[1].flip_x = af
						end
						fx.render.sprites[1].ts = store.tick_ts
						simulation:queue_insert_entity(fx)
					end
					if ma.hit_decal then
						local fx = E:create_entity(ma.hit_decal)
						fx.pos = V.vclone(hit_pos)
						fx.render.sprites[1].ts = store.tick_ts
						simulation:queue_insert_entity(fx)
					end
				end
				while (not U.animation_finished_default(this)) do
					if ((this.health.dead or (ma.ignore_stun and this.unit.is_stunned)) or ((this.dodge and this.dodge.active) and (not this.dodge.silent))) then
						return false
					end
					coroutine.yield()
				end
				__pc_helpers["__pc_bolt_1_insert_1"](this, "idle", nil, store.tick_ts, true)
				return true
			end
		end
	end
	return true
end
__pc_helpers["__pc_enemy_abomination_update_31"] = function(entity, name, flip_x, ts, loop, idx, force_ts)
	local first, last
	do
		first, last = idx, idx
	end
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if (flip_x ~= nil) then
				a.flip_x = flip_x
			end
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or force_ts) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_enemy_abomination_update_32"] = function(store, this, ranged_attack, attack, source)
	if (not this.dodge) then
		return false
	end
	this.dodge.last_check_ts = store.tick_ts
	local is_special_attack = (ranged_attack or ((attack and (attack.type == "area"))))
	if ((((((not this.unit.is_stunned) and ((not this.enemy) or this.enemy.can_do_magic)) and ((not this.dodge.cooldown) or ((store.tick_ts - this.dodge.ts) > this.dodge.cooldown))) and (((not attack) or (not attack.damage_type)) or (band(attack.damage_type, DAMAGE_NO_DODGE) == 0))) and (((not is_special_attack) and (math.random() <= this.dodge.chance)) or (is_special_attack and (math.random() <= (0.6 * this.dodge.chance))))) and ((not this.dodge.can_dodge) or this.dodge.can_dodge(store, this, ranged_attack, attack, source))) then
		this.dodge.last_doge_ts = store.tick_ts
		this.dodge.last_attack = attack
		this.dodge.active = true
		do
			this.dodge.from_ranged_attack = false
		end
		return true
	end
	return false
end
__pc_helpers["__pc_enemy_abomination_update_4"] = function(store, this)
	SU.show_blood_pool = function(e, terrain_type)
	if ((e.unit.show_blood_pool and (e.unit.blood_color ~= BLOOD_NONE)) and (band(terrain_type, TERRAIN_WATER) == 0)) then
		local decal = E:create_entity("decal_blood_pool")
		decal.pos = V.vclone(e.pos)
		decal.render.sprites[1].ts = store.tick_ts
		decal.render.sprites[1].name = e.unit.blood_color
		decal.render.sprites[1].z = e.render.sprites[1].z
		decal.render.sprites[1].sort_y_offset = 1
		simulation:queue_insert_entity(decal)
	end
end
	local can_spawn = (this.death_spawns and (band(this.health.last_damage_types, bor(DAMAGE_EAT, DAMAGE_NO_SPAWNS, (this.death_spawns.no_spawn_damage_types or 0))) == 0))
	if false then
		SU.do_death_spawns(store, this)
		coroutine.yield()
		can_spawn = false
	end
	local terrain_type = band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_TYPES_MASK)
	if ((((band(this.health.last_damage_types, bor(DAMAGE_EXPLOSION, DAMAGE_INSTAKILL, DAMAGE_FX_EXPLODE, DAMAGE_SHOT, DAMAGE_RUDE)) ~= 0) and (band(this.health.last_damage_types, bor(DAMAGE_FX_NOT_EXPLODE, DAMAGE_DISINTEGRATE)) == 0)) and this.unit.can_explode) or (((this.unit.explode_when_silenced_death and (not this.enemy.can_do_magic)) and this.unit.explode_fx) and (band(terrain_type, TERRAIN_WATER) == 0))) then
		S:queue(this.sound_events.death_by_explosion)
		local fx = E:create_entity(this.unit.explode_fx)
		fx.pos = V.vclone(this.pos)
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]
		simulation:queue_insert_entity(fx)
		SU.show_blood_pool(this, terrain_type)
		this.unit.hide_during_death = true
	elseif ((((band(this.health.last_damage_types, bor(DAMAGE_DISINTEGRATE)) ~= 0) or (this.unit.disintegrate_when_silenced_death and (not this.enemy.can_do_magic))) and this.unit.can_disintegrate) and this.unit.disintegrate_fx) then
		local fx = E:create_entity(this.unit.disintegrate_fx)
		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts
		if fx.render.sprites[1].size_names then
			fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]
		end
		if ((band(this.vis.flags, F_FLYING) ~= 0) and this.unit.hit_offset) then
			fx.render.sprites[1].offset.y = this.unit.hit_offset.y
		end
		simulation:queue_insert_entity(fx)
		this.unit.hide_during_death = true
		this.unit.show_blood_pool = false
	elseif (band(this.health.last_damage_types, bor(DAMAGE_EAT)) ~= 0) then
		this.unit.hide_during_death = true
		this.unit.show_blood_pool = false
	elseif (((band(terrain_type, TERRAIN_CLIFF) ~= 0) and (band(this.vis.flags, F_FLYING) == 0)) and false) then
		S:queue("WilhemScream")
		S:queue(this.sound_events.death, this.sound_events.death_args)
		__pc_helpers["__pc_bolt_1_insert_1"](this, "fall", nil, store.tick_ts, true)
		U.set_destination(this, this.cliff.fall_to_pos)
		while (not U.walk(this, store.tick_length, this.cliff.fall_accel)) do
			coroutine.yield()
		end
		SU.show_blood_pool(this, terrain_type)
		__pc_helpers["__pc_enemy_abomination_update_9"](this, "death", nil, store.tick_ts, 1)
	elseif ((band(terrain_type, TERRAIN_WATER) ~= 0) and (band(this.vis.flags, F_FLYING) == 0)) then
		S:queue(this.sound_events.death_water, this.sound_events.death_water_args)
		__pc_helpers["__pc_enemy_abomination_update_11"](this, this.unit.death_animation, nil, store.tick_ts, 1)
	elseif this.unit.death_animation then
		S:queue(this.sound_events.death, this.sound_events.death_args)
		SU.show_blood_pool(this, terrain_type)
		__pc_helpers["__pc_enemy_abomination_update_13"](this, this.unit.death_animation, nil, store.tick_ts, false)
		while (not U.animation_finished_default(this)) do
			coroutine.yield()
		end
	end
	if (this.unit.hide_during_death or this.unit.hide_after_death) then
		for _, s in ipairs(this.render.sprites) do
			s.hidden = true
		end
	end
	if this.ui then
		this.ui.can_click = ((not this.unit.hide_after_death) and (not this.unit.hide_during_death))
		this.ui.z = (- 1)
	end
	if this.unit.fade_time_after_death then
		SU.fade_out_entity(store, this, this.unit.fade_time_after_death)
	end
end
__pc_helpers["__pc_enemy_abomination_update_9"] = function(entity, name, flip_x, ts, times, idx)
	__pc_helpers["__pc_enemy_abomination_update_10"](entity, name, flip_x, ts, (times and (times > 1)), idx, true)
	local a = entity.render.sprites[(idx or 1)]
	times = ((a.loop and ((times or 1))) or 0)
	while (a.runs <= times) do
		coroutine.yield()
	end
end
__pc_helpers["__pc_enemy_bat_update_10"] = function(entity, name, flip_x, ts, loop, idx, force_ts)
	local first, last
	if idx then
		first, last = idx, idx
	else
		first, last = 1, (# entity.render.sprites)
	end
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or true) then
					a.ts = ts
					a.runs = 0
				end
				do
					a.name = name
				end
			end
		end
	end
	do
		local i = 2
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or true) then
					a.ts = ts
					a.runs = 0
				end
				do
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_enemy_bat_update_11"] = function(entity, name, flip_x, ts, times, idx)
	__pc_helpers["__pc_enemy_bat_update_12"](entity, name, flip_x, ts, (times and (times > 1)), idx, true)
	local a = entity.render.sprites[(idx or 1)]
	times = ((a.loop and ((times or 1))) or 0)
	while (a.runs <= times) do
		coroutine.yield()
	end
end
__pc_helpers["__pc_enemy_bat_update_12"] = function(entity, name, flip_x, ts, loop, idx, force_ts)
	local first, last
	if idx then
		first, last = idx, idx
	else
		first, last = 1, (# entity.render.sprites)
	end
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or true) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
	do
		local i = 2
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or true) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_enemy_bat_update_13"] = function(entity, name, flip_x, ts, loop)
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if (not a.loop) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
	do
		local i = 2
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if (not a.loop) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_enemy_bat_update_15"] = function(entity, name, flip_x, ts, loop)
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if (not a.loop) then
					a.ts = ts
					a.runs = 0
				end
				do
					a.name = name
				end
			end
		end
	end
	do
		local i = 2
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if (not a.loop) then
					a.ts = ts
					a.runs = 0
				end
				do
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_enemy_bat_update_16"] = function(store, this)
	local blocker
	local terrain_type = band(GR:cell_type(this.pos.x, this.pos.y), bor(TERRAIN_WATER, TERRAIN_LAND))
	while (not blocker) do
		if this.unit.is_stunned then
			return false, nil
		end
		if this.health.dead then
			return false, nil
		end
		if (((# this.enemy.blockers) > 0) and P:is_node_valid(this.nav_path.pi, this.nav_path.ni, NF_ALL)) then
			U.cleanup_blockers(store, this)
			blocker = store.entities[this.enemy.blockers[1]]
		end
		if (not blocker) then
			__pc_helpers["__pc_enemy_bat_update_18"](store, this)
		else
			__pc_helpers["__pc_enemy_bat_update_15"](this, "idle", nil, store.tick_ts, true)
		end
		if (terrain_type ~= band(GR:cell_type(this.pos.x, this.pos.y), bor(TERRAIN_WATER, TERRAIN_LAND))) then
			return false, nil
		end
	end
	return true, blocker
end
__pc_helpers["__pc_enemy_bat_update_18"] = function(store, this)
	local step = (this.motion.real_speed * store.tick_length)
	local m = this.motion
	local pos = this.pos
	if m.forced_waypoint then
		local w = m.forced_waypoint
		local dx = (w.x - pos.x)
		local dy = (w.y - pos.y)
		if (math.sqrt(((dx * dx) + (dy * dy))) < (2 * step)) then
			pos.x, pos.y = w.x, w.y
			m.forced_waypoint = nil
			return false
		end
		m.dest.x, m.dest.y = w.x, w.y
	else
		local n = this.nav_path
		local path = P.paths[n.pi][n.spi]
		local next = path[(n.ni + n.dir)]
		if ((not next) or (math.sqrt(((((next.x - pos.x)) * ((next.x - pos.x))) + (((next.y - pos.y)) * ((next.y - pos.y))))) < (2 * step))) then
			n.ni = (n.ni + n.dir)
			if ((n.ni < 1) or (n.ni > (# path))) then
				if (P.path_connections[n.pi] and (n.dir > 0)) then
					local newni = P.path_connections_spi_to_ni[n.pi][n.spi]
					n.pi = P.path_connections[n.pi]
					n.ni = (newni + n.dir)
					path = P.paths[n.pi][n.spi]
				else
					coroutine.yield()
					return false
				end
			end
			do
				S:queue(this.sound_events.new_node, this.sound_events.new_node_args)
			end
			next = path[(n.ni + n.dir)]
		end
		if (not next) then
			coroutine.yield()
			return false
		end
		m.dest.x, m.dest.y = next.x, next.y
	end
	m.arrived = false
	local dx, dy = (m.dest.x - pos.x), (m.dest.y - pos.y)
	local an
	local af = false
	do
		local _sprite = this.render.sprites[1]
		local _angles = (_sprite.angles and _sprite.angles.walk)
		if _angles then
			local _angle_count = (# _angles)
			if (_angle_count == 1) then
				an, af = _angles[1], (dx < 0)
			elseif (_angle_count == 2) then
				local _coordinate_idx = (((dy > 0) and 1) or 2)
				an = _angles[_coordinate_idx]
				af = ((((_sprite.angles_flip_horizontal and _sprite.angles_flip_horizontal[_coordinate_idx])) and ((dx >= 0))) or ((dx < 0)))
			else
				local _angle = (math.atan2(dy, dx) % 6.2831853071796)
				local _coordinate_idx = 1
				local _a1, _a2, _a3, _a4 = 45, 135, 225, 315
				if (_sprite.angles_custom and _sprite.angles_custom.walk) then
					_a1, _a2, _a3, _a4 = _sprite.angles_custom.walk[1], _sprite.angles_custom.walk[2], _sprite.angles_custom.walk[3], _sprite.angles_custom.walk[4]
				end
				local _stickiness = (_sprite.angles_stickiness and _sprite.angles_stickiness.walk)
				local _angle_deg = (_angle * 57.295779513082)
				if _stickiness then
					local _skew_factor = _sprite._last_skew_factor
					if _skew_factor then
						local _skew = (_stickiness * _skew_factor)
						_a1, _a3 = (_a1 - _skew), (_a3 - _skew)
						_a2, _a4 = (_a2 + _skew), (_a4 + _skew)
					end
					if ((_a1 <= _angle_deg) and (_angle_deg < _a2)) then
						_coordinate_idx = 2
						_sprite._last_skew_factor = 1
					elseif ((_a3 <= _angle_deg) and (_angle_deg < _a4)) then
						_coordinate_idx = 3
						_sprite._last_skew_factor = 1
					else
						_sprite._last_skew_factor = (- 1)
						if (dx < 0) then
							af = true
						end
					end
				else
					if ((_a1 <= _angle_deg) and (_angle_deg < _a2)) then
						_coordinate_idx = 2
					elseif ((_a3 <= _angle_deg) and (_angle_deg < _a4)) then
						_coordinate_idx = 3
					elseif (dx < 0) then
						af = true
					end
				end
				if (_sprite.angles_flip_vertical and _sprite.angles_flip_vertical.walk) then
					af = (dx < 0)
				end
				an = _angles[_coordinate_idx]
			end
		else
			an, af = "walk", (dx < 0)
		end
	end
	do
		local i = 1
		local a = this.render.sprites[i]
		if (not a.ignore_start) then
			a.flip_x = af
			if a.animated then
				a.loop = true
				a.name = an
			end
		end
	end
	do
		local i = 2
		local a = this.render.sprites[i]
		if (not a.ignore_start) then
			a.flip_x = af
			if a.animated then
				a.loop = true
				a.name = an
			end
		end
	end
	if (((dx * dx) + (dy * dy)) <= (step * step)) then
		pos.x, pos.y = m.dest.x, m.dest.y
		m.speed.x, m.speed.y = 0, 0
		m.arrived = true
	else
		local v_angle = math.atan2(dy, dx)
		if this.heading then
			this.heading.angle = v_angle
		end
		local sx, sy = (step * math.cos(v_angle)), (step * math.sin(v_angle))
		pos.x, pos.y = (pos.x + sx), (pos.y + sy)
		m.speed.x, m.speed.y = (sx / store.tick_length), (sy / store.tick_length)
	end
	coroutine.yield()
	m.speed.x, m.speed.y = 0, 0
	return true
end
__pc_helpers["__pc_enemy_bat_update_4"] = function(store, this)
	SU.show_blood_pool = function(e, terrain_type)
	if ((e.unit.show_blood_pool and (e.unit.blood_color ~= BLOOD_NONE)) and (band(terrain_type, TERRAIN_WATER) == 0)) then
		local decal = E:create_entity("decal_blood_pool")
		decal.pos = V.vclone(e.pos)
		decal.render.sprites[1].ts = store.tick_ts
		decal.render.sprites[1].name = e.unit.blood_color
		decal.render.sprites[1].z = e.render.sprites[1].z
		decal.render.sprites[1].sort_y_offset = 1
		simulation:queue_insert_entity(decal)
	end
end
	local can_spawn = (this.death_spawns and (band(this.health.last_damage_types, bor(DAMAGE_EAT, DAMAGE_NO_SPAWNS, (this.death_spawns.no_spawn_damage_types or 0))) == 0))
	if false then
		SU.do_death_spawns(store, this)
		coroutine.yield()
		can_spawn = false
	end
	local terrain_type = band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_TYPES_MASK)
	if ((((band(this.health.last_damage_types, bor(DAMAGE_EXPLOSION, DAMAGE_INSTAKILL, DAMAGE_FX_EXPLODE, DAMAGE_SHOT, DAMAGE_RUDE)) ~= 0) and (band(this.health.last_damage_types, bor(DAMAGE_FX_NOT_EXPLODE, DAMAGE_DISINTEGRATE)) == 0)) and this.unit.can_explode) or (((this.unit.explode_when_silenced_death and (not this.enemy.can_do_magic)) and this.unit.explode_fx) and (band(terrain_type, TERRAIN_WATER) == 0))) then
		S:queue(this.sound_events.death_by_explosion)
		local fx = E:create_entity(this.unit.explode_fx)
		fx.pos = V.vclone(this.pos)
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]
		simulation:queue_insert_entity(fx)
		SU.show_blood_pool(this, terrain_type)
		this.unit.hide_during_death = true
	elseif ((((band(this.health.last_damage_types, bor(DAMAGE_DISINTEGRATE)) ~= 0) or (this.unit.disintegrate_when_silenced_death and (not this.enemy.can_do_magic))) and this.unit.can_disintegrate) and this.unit.disintegrate_fx) then
		local fx = E:create_entity(this.unit.disintegrate_fx)
		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts
		if fx.render.sprites[1].size_names then
			fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]
		end
		if ((band(this.vis.flags, F_FLYING) ~= 0) and this.unit.hit_offset) then
			fx.render.sprites[1].offset.y = this.unit.hit_offset.y
		end
		simulation:queue_insert_entity(fx)
		this.unit.hide_during_death = true
		this.unit.show_blood_pool = false
	elseif (band(this.health.last_damage_types, bor(DAMAGE_EAT)) ~= 0) then
		this.unit.hide_during_death = true
		this.unit.show_blood_pool = false
	elseif (((band(terrain_type, TERRAIN_CLIFF) ~= 0) and (band(this.vis.flags, F_FLYING) == 0)) and false) then
		S:queue("WilhemScream")
		S:queue(this.sound_events.death, this.sound_events.death_args)
		__pc_helpers["__pc_enemy_bat_update_15"](this, "fall", nil, store.tick_ts, true)
		U.set_destination(this, this.cliff.fall_to_pos)
		while (not U.walk(this, store.tick_length, this.cliff.fall_accel)) do
			coroutine.yield()
		end
		SU.show_blood_pool(this, terrain_type)
		__pc_helpers["__pc_enemy_bat_update_9"](this, "death", nil, store.tick_ts, 1)
	elseif ((band(terrain_type, TERRAIN_WATER) ~= 0) and (band(this.vis.flags, F_FLYING) == 0)) then
		S:queue(this.sound_events.death_water, this.sound_events.death_water_args)
		__pc_helpers["__pc_enemy_bat_update_11"](this, this.unit.death_animation, nil, store.tick_ts, 1)
	elseif this.unit.death_animation then
		S:queue(this.sound_events.death, this.sound_events.death_args)
		SU.show_blood_pool(this, terrain_type)
		__pc_helpers["__pc_enemy_bat_update_13"](this, this.unit.death_animation, nil, store.tick_ts, false)
		while (not U.animation_finished_default(this)) do
			coroutine.yield()
		end
	end
	if (this.unit.hide_during_death or this.unit.hide_after_death) then
		for _, s in ipairs(this.render.sprites) do
			s.hidden = true
		end
	end
	if this.ui then
		this.ui.can_click = ((not this.unit.hide_after_death) and (not this.unit.hide_during_death))
		this.ui.z = (- 1)
	end
	if this.unit.fade_time_after_death then
		SU.fade_out_entity(store, this, this.unit.fade_time_after_death)
	end
end
__pc_helpers["__pc_enemy_bat_update_9"] = function(entity, name, flip_x, ts, times, idx)
	__pc_helpers["__pc_enemy_bat_update_10"](entity, name, flip_x, ts, (times and (times > 1)), idx, true)
	local a = entity.render.sprites[(idx or 1)]
	times = ((a.loop and ((times or 1))) or 0)
	while (a.runs <= times) do
		coroutine.yield()
	end
end
__pc_helpers["__pc_enemy_blazefang_update_17"] = function(store, this)
	local ranged, blocker
	local terrain_type = band(GR:cell_type(this.pos.x, this.pos.y), bor(TERRAIN_WATER, TERRAIN_LAND))
	while ((not blocker) and (not ranged)) do
		if this.unit.is_stunned then
			return false
		end
		if this.health.dead then
			return false
		end
		if P:is_node_valid(this.nav_path.pi, this.nav_path.ni) then
			do
				if (((store.tick_ts - this.ranged.last_range_ts) > 0.1) and this.enemy.can_do_magic) then
					for i = 1, (# this.ranged.attacks) do
						local a = this.ranged.attacks[i]
						if ((not a.disabled) and (a.hold_advance or ((store.tick_ts - a.ts) > a.cooldown))) then
							ranged = U.find_nearest_soldier(store.soldiers, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)
							if ranged then
								break
							else
								a.ts = (a.ts + 0.1)
							end
						end
					end
					if (not ranged) then
						this.ranged.last_range_ts = store.tick_ts
					end
				end
			end
			if ((# this.enemy.blockers) > 0) then
				U.cleanup_blockers(store, this)
				blocker = store.entities[this.enemy.blockers[1]]
			end
		end
		if ((not blocker) and (not ranged)) then
			__pc_helpers["__pc_enemy_abomination_update_19"](store, this)
		else
			__pc_helpers["__pc_bolt_1_insert_1"](this, "idle", nil, store.tick_ts, true)
		end
		if (terrain_type ~= band(GR:cell_type(this.pos.x, this.pos.y), bor(TERRAIN_WATER, TERRAIN_LAND))) then
			return false, nil, nil
		end
	end
	return true, blocker, ranged
end
__pc_helpers["__pc_enemy_razorwing_update_14"] = function(store, this)
	SU.show_blood_pool = function(e, terrain_type)
	if ((e.unit.show_blood_pool and (e.unit.blood_color ~= BLOOD_NONE)) and (band(terrain_type, TERRAIN_WATER) == 0)) then
		local decal = E:create_entity("decal_blood_pool")
		decal.pos = V.vclone(e.pos)
		decal.render.sprites[1].ts = store.tick_ts
		decal.render.sprites[1].name = e.unit.blood_color
		decal.render.sprites[1].z = e.render.sprites[1].z
		decal.render.sprites[1].sort_y_offset = 1
		simulation:queue_insert_entity(decal)
	end
end
	local can_spawn = (this.death_spawns and (band(this.health.last_damage_types, bor(DAMAGE_EAT, DAMAGE_NO_SPAWNS, (this.death_spawns.no_spawn_damage_types or 0))) == 0))
	if false then
		SU.do_death_spawns(store, this)
		coroutine.yield()
		can_spawn = false
	end
	local terrain_type = band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_TYPES_MASK)
	if ((((band(this.health.last_damage_types, bor(DAMAGE_EXPLOSION, DAMAGE_INSTAKILL, DAMAGE_FX_EXPLODE, DAMAGE_SHOT, DAMAGE_RUDE)) ~= 0) and (band(this.health.last_damage_types, bor(DAMAGE_FX_NOT_EXPLODE, DAMAGE_DISINTEGRATE)) == 0)) and this.unit.can_explode) or (((this.unit.explode_when_silenced_death and (not this.enemy.can_do_magic)) and this.unit.explode_fx) and (band(terrain_type, TERRAIN_WATER) == 0))) then
		S:queue(this.sound_events.death_by_explosion)
		local fx = E:create_entity(this.unit.explode_fx)
		fx.pos = V.vclone(this.pos)
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]
		simulation:queue_insert_entity(fx)
		SU.show_blood_pool(this, terrain_type)
		this.unit.hide_during_death = true
	elseif ((((band(this.health.last_damage_types, bor(DAMAGE_DISINTEGRATE)) ~= 0) or (this.unit.disintegrate_when_silenced_death and (not this.enemy.can_do_magic))) and this.unit.can_disintegrate) and this.unit.disintegrate_fx) then
		local fx = E:create_entity(this.unit.disintegrate_fx)
		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts
		if fx.render.sprites[1].size_names then
			fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]
		end
		if ((band(this.vis.flags, F_FLYING) ~= 0) and this.unit.hit_offset) then
			fx.render.sprites[1].offset.y = this.unit.hit_offset.y
		end
		simulation:queue_insert_entity(fx)
		this.unit.hide_during_death = true
		this.unit.show_blood_pool = false
	elseif (band(this.health.last_damage_types, bor(DAMAGE_EAT)) ~= 0) then
		this.unit.hide_during_death = true
		this.unit.show_blood_pool = false
	elseif ((band(terrain_type, TERRAIN_CLIFF) ~= 0) and (band(this.vis.flags, F_FLYING) == 0)) then
		S:queue("WilhemScream")
		S:queue(this.sound_events.death, this.sound_events.death_args)
		__pc_helpers["__pc_enemy_bat_update_15"](this, "fall", nil, store.tick_ts, true)
		U.set_destination(this, this.cliff.fall_to_pos)
		while (not U.walk(this, store.tick_length, this.cliff.fall_accel)) do
			coroutine.yield()
		end
		SU.show_blood_pool(this, terrain_type)
		__pc_helpers["__pc_enemy_bat_update_9"](this, "death", nil, store.tick_ts, 1)
	elseif ((band(terrain_type, TERRAIN_WATER) ~= 0) and (band(this.vis.flags, F_FLYING) == 0)) then
		S:queue(this.sound_events.death_water, this.sound_events.death_water_args)
		__pc_helpers["__pc_enemy_bat_update_11"](this, this.unit.death_animation, nil, store.tick_ts, 1)
	elseif this.unit.death_animation then
		S:queue(this.sound_events.death, this.sound_events.death_args)
		SU.show_blood_pool(this, terrain_type)
		__pc_helpers["__pc_enemy_bat_update_13"](this, this.unit.death_animation, nil, store.tick_ts, false)
		while (not U.animation_finished_default(this)) do
			coroutine.yield()
		end
	end
	if (this.unit.hide_during_death or this.unit.hide_after_death) then
		for _, s in ipairs(this.render.sprites) do
			s.hidden = true
		end
	end
	if this.ui then
		this.ui.can_click = ((not this.unit.hide_after_death) and (not this.unit.hide_during_death))
		this.ui.z = (- 1)
	end
	if this.unit.fade_time_after_death then
		SU.fade_out_entity(store, this, this.unit.fade_time_after_death)
	end
end
__pc_helpers["__pc_enemy_savage_bird_rider_update_15"] = function(store, this)
	local flip_x = ((this.motion and (this.motion.dest.x < this.pos.x)) or nil)
	__pc_helpers["__pc_enemy_savage_bird_rider_update_16"](this, "idle", flip_x, store.tick_ts, true)
	coroutine.yield()
end
__pc_helpers["__pc_enemy_savage_bird_rider_update_16"] = function(entity, name, flip_x, ts, loop)
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if (flip_x ~= nil) then
				a.flip_x = flip_x
			end
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if (not a.loop) then
					a.ts = ts
					a.runs = 0
				end
				do
					a.name = name
				end
			end
		end
	end
	do
		local i = 2
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if (flip_x ~= nil) then
				a.flip_x = flip_x
			end
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if (not a.loop) then
					a.ts = ts
					a.runs = 0
				end
				do
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_enemy_savage_bird_rider_update_17"] = function(store, this)
	local ranged, blocker
	local terrain_type = band(GR:cell_type(this.pos.x, this.pos.y), bor(TERRAIN_WATER, TERRAIN_LAND))
	while ((not blocker) and (not ranged)) do
		if this.unit.is_stunned then
			return false
		end
		if this.health.dead then
			return false
		end
		if P:is_node_valid(this.nav_path.pi, this.nav_path.ni) then
			do
				if (((store.tick_ts - this.ranged.last_range_ts) > 0.1) and this.enemy.can_do_magic) then
					for i = 1, (# this.ranged.attacks) do
						local a = this.ranged.attacks[i]
						if ((not a.disabled) and (a.hold_advance or ((store.tick_ts - a.ts) > a.cooldown))) then
							ranged = U.find_nearest_soldier(store.soldiers, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)
							if ranged then
								break
							else
								a.ts = (a.ts + 0.1)
							end
						end
					end
					if (not ranged) then
						this.ranged.last_range_ts = store.tick_ts
					end
				end
			end
			if ((# this.enemy.blockers) > 0) then
				U.cleanup_blockers(store, this)
				blocker = store.entities[this.enemy.blockers[1]]
			end
		end
		if ((not blocker) and (not ranged)) then
			__pc_helpers["__pc_enemy_bat_update_18"](store, this)
		else
			__pc_helpers["__pc_enemy_bat_update_15"](this, "idle", nil, store.tick_ts, true)
		end
		if (terrain_type ~= band(GR:cell_type(this.pos.x, this.pos.y), bor(TERRAIN_WATER, TERRAIN_LAND))) then
			return false, nil, nil
		end
	end
	return true, blocker, ranged
end
__pc_helpers["__pc_enemy_savage_bird_rider_update_37"] = function(store, this, target)
	for _, i in ipairs(this.melee.order) do
		local ma = this.melee.attacks[i]
		local cooldown = ma.cooldown
		if ma.shared_cooldown then
			cooldown = this.melee.cooldown
		end
		cooldown = (cooldown * this.unit.cooldown_factor)
		if (((((not ma.disabled) and (cooldown <= (store.tick_ts - ma.ts))) and (band(ma.vis_flags, target.vis.bans) == 0)) and (band(ma.vis_bans, target.vis.flags) == 0)) and ((not ma.fn_can) or ma.fn_can(this, store, ma, target))) then
			ma.ts = store.tick_ts
			if (math.random() >= ma.chance) then
			else
				for _, aa in ipairs(this.melee.attacks) do
					if ((aa ~= ma) and aa.shared_cooldown) then
						aa.ts = ma.ts
					end
				end
				ma.ts = store.tick_ts
				S:queue(ma.sound, ma.sound_args)
				local an, af = U.animation_name_facing_point(this, ma.animation, target.pos)
				do
					local i = 1
					if this.render.sprites[i].animated then
						__pc_helpers["__pc_enemy_abomination_update_31"](this, an, af, store.tick_ts, false, i)
					end
				end
				do
					local i = 2
					if this.render.sprites[i].animated then
						__pc_helpers["__pc_enemy_savage_bird_rider_update_39"](this, an, af, store.tick_ts, false, i)
					end
				end
				local hit_pos = V.vclone(this.pos)
				if ma.hit_offset then
					hit_pos.x = (hit_pos.x + ((((af and (- 1)) or 1)) * ma.hit_offset.x))
					hit_pos.y = (hit_pos.y + ma.hit_offset.y)
				end
				local hit_times = ((ma.hit_times and ma.hit_times) or {ma.hit_time})
				for i = 1, (# hit_times) do
					local hit_time = hit_times[i]
					local dodged = false
					if (ma.dodge_time and target.dodge) then
						local dodge_time = ma.dodge_time
						if (target.dodge and target.dodge.time_before_hit) then
							dodge_time = (hit_time - target.dodge.time_before_hit)
						end
						while (dodge_time > (store.tick_ts - ma.ts)) do
							if ((this.health.dead or (this.unit.is_stunned and (not ma.ignore_stun))) or ((this.dodge and this.dodge.active) and (not this.dodge.silent))) then
								return false
							end
							coroutine.yield()
						end
						dodged = __pc_helpers["__pc_enemy_abomination_update_32"](store, target, false, ma, this)
					end
					while (hit_time > (store.tick_ts - ma.ts)) do
						if ((this.health.dead or (this.unit.is_stunned and (not ma.ignore_stun))) or ((this.dodge and this.dodge.active) and (not this.dodge.silent))) then
							return false
						end
						coroutine.yield()
					end
					S:queue(ma.sound_hit, ma.sound_hit_args)
					if (((ma.type == "melee") and (not dodged)) and table.arraycontains(this.enemy.blockers, target.id)) then
						if ma.damage_min then
							local d = E.assign_damage(ma.damage_type, (this.unit.damage_factor * math.random(ma.damage_min, ma.damage_max)), this.id, target.id)
							d.track_kills = (this.track_kills ~= nil)
							d.track_damage = ma.track_damage
							d.pop = ma.pop
							d.pop_chance = ma.pop_chance
							d.pop_conds = ma.pop_conds
							if ma.side_effect then
								ma.side_effect(this, store, d, target)
							end
							queue_damage(store, d)
						end
						if ma.mod then
							local mod = E:create_entity(ma.mod)
							mod.modifier.target_id = target.id
							mod.modifier.source_id = this.id
							mod.modifier.damage_factor = this.unit.damage_factor
							simulation:queue_insert_entity(mod)
						end
					elseif (ma.type == "area") then
						local targets = table.filter(store.soldiers, function(_, e)
	return (((((not e.health.dead) and (band(e.vis.flags, ma.vis_bans) == 0)) and (band(e.vis.bans, ma.vis_flags) == 0)) and U.is_inside_ellipse(e.pos, hit_pos, ma.damage_radius)) and (((not ma.fn_filter) or ma.fn_filter(this, store, ma, e))))
end)
						local first_damage
						local max_count = ((ma.count and math.min((# targets), ma.count)) or (# targets))
						for i = 1, max_count do
							local e = targets[i]
							local d = E.assign_damage(ma.damage_type, (this.unit.damage_factor * math.random(ma.damage_min, ma.damage_max)), this.id, e.id)
							d.pop = ma.pop
							d.pop_chance = ma.pop_chance
							d.pop_conds = ma.pop_conds
							if (e == target) then
								if dodged then
									goto next_target
								end
								first_damage = d
							end
							queue_damage(store, d)
							if ma.mod then
								local mod = E:create_entity(ma.mod)
								mod.modifier.target_id = e.id
								mod.modifier.source_id = this.id
								mod.modifier.damage_factor = this.unit.damage_factor
								simulation:queue_insert_entity(mod)
							end
							::next_target::
						end
						if (ma.side_effect and first_damage) then
							ma.side_effect(this, store, first_damage, target)
						end
					end
					if (ma.hit_fx and ((not ma.hit_fx_once) or (i == 1))) then
						local fx = E:create_entity(ma.hit_fx)
						fx.pos = V.vclone(hit_pos)
						if ma.hit_fx_offset then
							fx.pos.x = (fx.pos.x + ((((af and (- 1)) or 1)) * ma.hit_fx_offset.x))
							fx.pos.y = (fx.pos.y + ma.hit_fx_offset.y)
						end
						if ma.hit_fx_flip then
							fx.render.sprites[1].flip_x = af
						end
						fx.render.sprites[1].ts = store.tick_ts
						simulation:queue_insert_entity(fx)
					end
					if ma.hit_decal then
						local fx = E:create_entity(ma.hit_decal)
						fx.pos = V.vclone(hit_pos)
						fx.render.sprites[1].ts = store.tick_ts
						simulation:queue_insert_entity(fx)
					end
				end
				while (not U.animation_finished_default(this)) do
					if ((this.health.dead or (ma.ignore_stun and this.unit.is_stunned)) or ((this.dodge and this.dodge.active) and (not this.dodge.silent))) then
						return false
					end
					coroutine.yield()
				end
				__pc_helpers["__pc_enemy_bat_update_15"](this, "idle", nil, store.tick_ts, true)
				return true
			end
		end
	end
	return true
end
__pc_helpers["__pc_enemy_savage_bird_rider_update_39"] = function(entity, name, flip_x, ts, loop, idx, force_ts)
	local first, last
	do
		first, last = idx, idx
	end
	do
		local i = 2
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if (flip_x ~= nil) then
				a.flip_x = flip_x
			end
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or force_ts) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_soldier_amazona_insert_2"] = function(this, power_name)
	local pn = power_name
	local pow = (this.powers and this.powers[pn])
	if (not pow) then
		return
	end
	local level_inc = (pow.level - ((pow._last_level or 0)))
	if (level_inc <= 0) then
		return
	end
	pow._last_level = pow.level
	if ((this.health.power_name == pn) and this.health.hp_inc) then
		this.health.hp_max = (this.health.hp_max + (this.health.hp_inc * level_inc))
		this.health.hp = this.health.hp_max
	end
	if ((this.health.armor_power_name == pn) and this.health.armor_inc) then
		SU.armor_inc(this, (this.health.armor_inc * level_inc))
	end
	if ((this.health.magic_armor_power_name == pn) and this.health.magic_armor_inc) then
		SU.magic_armor_inc(this, (this.health.magic_armor_inc * level_inc))
	end
	do
		local min_cooldown = 1e+99
		local cooldown_changed = false
		for _, a in ipairs(this.melee.attacks) do
			if (a.power_name == pn) then
				a.level = pow.level
				if a.disabled then
					a.disabled = nil
				end
				if a.chance_inc then
					a.chance = (a.chance + (a.chance_inc * level_inc))
					this.melee.order = U.attack_order(this.melee.attacks)
				end
				if a.damage_inc then
					a.damage_min = (a.damage_min + (a.damage_inc * level_inc))
					a.damage_max = (a.damage_max + (a.damage_inc * level_inc))
				end
				if (a.damage_min_inc and a.damage_max_inc) then
					a.damage_min = (a.damage_min + (a.damage_min_inc * level_inc))
					a.damage_max = (a.damage_max + (a.damage_max_inc * level_inc))
				end
				if a.cooldown_inc then
					a.cooldown = (a.cooldown + (a.cooldown_inc * level_inc))
					cooldown_changed = true
				end
			end
			if a.cooldown then
				min_cooldown = math.min(a.cooldown, min_cooldown)
			end
		end
		if (this.melee.forced_cooldown and (min_cooldown < this.melee.forced_cooldown)) then
			this.melee.forced_cooldown = min_cooldown
		end
	end
	if this.timed_actions then
		for _, a in ipairs(this.timed_actions.list) do
			if (a.power_name == pn) then
				if a.level then
					a.level = pow.level
				end
				if a.disabled then
					a.disabled = nil
				end
			end
		end
	end
	if this.timed_attacks then
		for _, a in ipairs(this.timed_attacks.list) do
			if (a.power_name == pn) then
				if a.level then
					a.level = pow.level
				end
				if a.disabled then
					a.disabled = nil
				end
			end
		end
	end
	if (this.revive and (this.revive.power_name == pn)) then
		this.revive.disabled = nil
		if this.revive.chance_inc then
			this.revive.chance = (this.revive.chance + (this.revive.chance_inc * level_inc))
		end
		if this.revive.health_recover then
			this.revive.health_recover = (this.revive.health_recover + (this.revive.health_recover_inc * level_inc))
		end
	end
	if this.dodge then
		local d = this.dodge
		if (d.power_name == pn) then
			if d.chance_inc then
				d.chance = (d.chance + (d.chance_inc * level_inc))
			end
		end
		if (d.counter_attack and (d.counter_attack.power_name == pn)) then
			if d.counter_attack.damage_inc then
				d.counter_attack.damage_min = (d.counter_attack.damage_min + (d.counter_attack.damage_inc * level_inc))
				d.counter_attack.damage_max = (d.counter_attack.damage_max + (d.counter_attack.damage_inc * level_inc))
			end
		end
	end
	if (this.pickpocket and (this.pickpocket.power_name == pn)) then
		local pi = this.pickpocket
		if pi.chance_inc then
			pi.chance = (pi.chance + (pi.chance_inc * level_inc))
		end
	end
	local fn = (pow and pow.on_power_upgrade)
	if fn then
		fn(this, power_name, pow)
	end
end
__pc_helpers["__pc_soldier_amazona_update_21"] = function(store, this)
	U.unblock_target(store, this)
	local h = this.health
	if ((this.selfdestruct and (not this.selfdestruct.disabled)) and (band(h.last_damage_types, bor(DAMAGE_EAT, DAMAGE_HOST, DAMAGE_DISINTEGRATE)) == 0)) then
		local sd = this.selfdestruct
		this.unit.hide_after_death = true
		this.health_bar.hidden = true
		__pc_helpers["__pc_enemy_abomination_update_13"](this, sd.animation, nil, store.tick_ts)
		S:queue(this.sound_events.death, this.sound_events.death_args)
		S:queue(sd.sound, sd.sound_args)
		U.y_wait_unconditional(store, sd.hit_time)
		S:queue(sd.sound_hit)
		if sd.hit_fx then
			SU.insert_sprite(store, sd.hit_fx, this.pos)
		end
		local targets = U.find_enemies_in_range_filter_off(this.pos, sd.damage_radius, sd.vis_flags, sd.vis_bans)
		if targets then
			for _, t in ipairs(targets) do
				local d = E.assign_damage(sd.damage_type, ((((((sd.damage and sd.damage) or math.random(sd.damage_min, sd.damage_max))) + this.unit.damage_buff)) * this.unit.damage_factor), this.id, t.id)
				queue_damage(store, d)
				if sd.mod then
					local m = E:create_entity(sd.mod)
					m.modifier.target_id = t.id
					m.modifier.source_id = this.id
					m.modifier.damage_factor = this.unit.damage_factor
					simulation:queue_insert_entity(m)
				end
			end
		end
		U.y_animation_wait_default(this)
	elseif (band(h.last_damage_types, DAMAGE_DISINTEGRATE) ~= 0) then
		this.unit.hide_during_death = true
		local fx = E:create_entity("fx_soldier_desintegrate")
		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts
		simulation:queue_insert_entity(fx)
	elseif (band(h.last_damage_types, bor(DAMAGE_EAT)) ~= 0) then
		this.unit.hide_during_death = true
	elseif (band(h.last_damage_types, bor(DAMAGE_HOST)) ~= 0) then
		S:queue(this.sound_events.death_by_explosion)
		this.unit.hide_during_death = true
		local fx = E:create_entity("fx_unit_explode")
		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]
		simulation:queue_insert_entity(fx)
		if (this.unit.show_blood_pool and (this.unit.blood_color ~= BLOOD_NONE)) then
			local decal = E:create_entity("decal_blood_pool")
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			decal.render.sprites[1].name = this.unit.blood_color
			simulation:queue_insert_entity(decal)
		end
	elseif (this.reinforcement and (this.reinforcement.fade or this.reinforcement.fade_out)) then
		SU.y_reinforcement_fade_out(store, this)
		return
	else
		S:queue(this.sound_events.death, this.sound_events.death_args)
		__pc_helpers["__pc_enemy_abomination_update_9"](this, "death", nil, store.tick_ts, 1)
		this.ui.can_select = false
	end
	if this.ui then
		this.ui.can_click = (not this.unit.hide_after_death)
		this.ui.z = (- 1)
	end
	if (this.unit.hide_during_death or this.unit.hide_after_death) then
		for _, s in ipairs(this.render.sprites) do
			s.hidden = true
		end
	end
end
__pc_helpers["__pc_soldier_amazona_update_33"] = function(this, store)
	if (((not this.revive) or (not this.revive.resist)) or this.revive.disabled) then
		return
	end
	local r = this.revive.resist
	if (this.revive.protect < r.cost) then
		return
	end
	local mods = U.find_modifiers_with_flags(this, r.bans)
	if ((not mods) or ((# mods) == 0)) then
		return
	end
	if ((not this.soldier.target_id) or (store.entities[this.soldier.target_id] == nil)) then
		local block_target = SU.soldier_pick_melee_target(store, this)
		if block_target then
			U.block_enemy(store, this, block_target)
		end
	end
	this.revive.protect = (this.revive.protect - r.cost)
	local clear_stun = false
	this.health.ignore_damage = true
	for _, m in ipairs(mods) do
		if (band(m.modifier.vis_flags, F_STUN) ~= 0) then
			clear_stun = true
		end
		m.modifier.removed_by_ban = true
	end
	local mod_ban = E:create_entity("mod_ban")
	mod_ban.modifier.ban_vis = r.bans
	mod_ban.modifier.target_id = this.id
	mod_ban.modifier.duration = r.duration
	simulation:queue_insert_entity(mod_ban)
	if this.revive.animation then
		S:queue(this.revive.sound)
		__pc_helpers["__pc_enemy_abomination_update_13"](this, this.revive.animation, nil, store.tick_ts, false)
		this.revive.ts = store.tick_ts
	end
	for _, m in ipairs(mods) do
		while store.entities[m.id] do
			m.modifier.ts = (- 10000)
			m.modifier.duration = 0.01
			coroutine.yield()
		end
	end
	if this.revive.fx then
		local fx = E:create_entity(this.revive.fx)
		fx.pos = this.pos
		fx.render.sprites[1].ts = store.tick_ts
		simulation:queue_insert_entity(fx)
	end
	if this.revive.animation then
		while (not U.animation_finished_default(this)) do
			coroutine.yield()
		end
	end
	do
		this.unit.is_stunned = nil
	end
	this.health.ignore_damage = false
	if r.side_effect then
		r.side_effect(this, store)
	end
end
__pc_helpers["__pc_soldier_amazona_update_39"] = function(store, this, force_ts)
	__pc_helpers["__pc_soldier_amazona_update_40"](this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, force_ts)
	if this.unit.is_stunned then
		return
	end
	if ((store.tick_ts - this.idle_flip.ts) > (2 * store.tick_length)) then
		this.idle_flip.ts_counter = 0
	end
	this.idle_flip.ts = store.tick_ts
	this.idle_flip.ts_counter = (this.idle_flip.ts_counter + store.tick_length)
	if (this.idle_flip.ts_counter > this.idle_flip.cooldown) then
		this.idle_flip.ts_counter = 0
		if (math.random() < this.idle_flip.chance) then
			do
				local i = 1
				this.render.sprites[i].flip_x = (not this.render.sprites[i].flip_x)
			end
		end
		if this.idle_flip.animations then
			this.idle_flip.last_animation = table.random(this.idle_flip.animations)
		end
	end
end
__pc_helpers["__pc_soldier_amazona_update_40"] = function(entity, name, flip_x, ts, loop, idx, force_ts)
	local first, last
	do
		first, last = 1, (# entity.render.sprites)
	end
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or force_ts) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_soldier_amazona_update_43"] = function(store, this)
	local r = this.nav_rally
	local out = false
	local prev_immune = this.health.immune_to
	this.health.immune_to = r.immune_to
	U.bans_add(this.vis, F_ALL)
	if r.new then
		r.new = false
		U.unblock_target(store, this)
		U.set_destination(this, r.pos)
		local an, af = __pc_helpers["__pc_soldier_amazona_update_44"](this, "walk", this.motion.dest)
		__pc_helpers["__pc_soldier_amazona_update_45"](this, an, af, store.tick_ts, true, nil, true)
		while (not this.motion.arrived) do
			if (this.health.dead or this.unit.is_stunned) then
				out = true
				break
			end
			if r.new then
				out = false
				break
			end
			U.walk_off__accel__unsnapped(this, store.tick_length)
			coroutine.yield()
			this.motion.speed.x, this.motion.speed.y = 0, 0
		end
	end
	U.bans_remove(this.vis, F_ALL)
	this.health.immune_to = prev_immune
	return out
end
__pc_helpers["__pc_soldier_amazona_update_44"] = function(e, group, point, idx, offset, use_path)
	local dx, dy = point.x, point.y
	do
		dx, dy = (dx - e.pos.x), (dy - e.pos.y)
	end
	if offset then
		dx, dy = (dx - offset.x), (dy - offset.y)
	end
	return U.animation_name_with_direction(e.render.sprites[(idx or 1)], group, dx, dy)
end
__pc_helpers["__pc_soldier_amazona_update_45"] = function(entity, name, flip_x, ts, loop, idx, force_ts)
	local first, last
	do
		first, last = 1, (# entity.render.sprites)
	end
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if (flip_x ~= nil) then
				a.flip_x = flip_x
			end
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or true) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_soldier_amazona_update_52"] = function(store, this)
	local no_target = true
	for _, a in ipairs(this.timed_attacks.list) do
		if (a.disabled or ((store.tick_ts - a.ts) < (a.cooldown * this.unit.cooldown_factor))) then
		else
			local target = U.detect_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)
			if target then
				no_target = false
				if (math.random() < a.chance) then
					local attack_done = __pc_helpers["__pc_soldier_amazona_update_53"](store, this, target, a)
					if attack_done then
						return false, A_DONE
					else
						return true
					end
				else
					a.ts = store.tick_ts
				end
			end
		end
	end
	return false, A_IN_COOLDOWN
end
__pc_helpers["__pc_soldier_amazona_update_53"] = function(store, this, target, attack)
	local attack_done = false
	local start_ts = store.tick_ts
	local spell
	local an, af = __pc_helpers["__pc_soldier_amazona_update_44"](this, attack.animation, target.pos)
	U.animation_start_default(this, an, af, store.tick_ts)
	S:queue(attack.sound)
	while ((store.tick_ts - start_ts) < attack.cast_time) do
		if ((this.health.dead or this.unit.is_stunned) or (this.nav_rally and this.nav_rally.new)) then
			goto label_65_0
		end
		coroutine.yield()
	end
	attack.ts = start_ts
	spell = E:create_entity(attack.spell)
	if attack.level then
		spell.spell.level = attack.level
	end
	spell.spell.source_id = this.id
	spell.spell.target_id = target.id
	simulation:queue_insert_entity(spell)
	attack_done = true
	while (not U.animation_finished_default(this)) do
		if (this.health.dead or (this.nav_rally and this.nav_rally.new)) then
			break
		end
		coroutine.yield()
	end
	::label_65_0::
	S:stop(attack.sound)
	return attack_done
end
__pc_helpers["__pc_soldier_amazona_update_56"] = function(store, this)
	if ((store.tick_ts - this.soldier.last_block_ts) < 0.1) then
		return false, A_NO_TARGET
	end
	local target = SU.soldier_pick_melee_target(store, this)
	if (not target) then
		this.soldier.last_block_ts = store.tick_ts
		return false, A_NO_TARGET
	end
	if SU.soldier_move_to_slot_step(store, this, target) then
		return true
	end
	local attack = SU.soldier_pick_melee_attack(store, this, target)
	if (not attack) then
		return false, A_IN_COOLDOWN
	end
	if attack.xp_from_skill then
		SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
	end
	local attack_done
	if attack.loops then
		attack_done = SU.y_soldier_do_loopable_melee_attack(store, this, target, attack)
	elseif (attack.type == "area") then
		attack_done = SU.y_soldier_do_single_area_attack(store, this, target, attack)
	else
		attack_done = __pc_helpers["__pc_soldier_amazona_update_69"](store, this, target, attack)
	end
	if attack_done then
		return false, A_DONE
	else
		return true
	end
end
__pc_helpers["__pc_soldier_amazona_update_69"] = function(store, this, target, attack)
	local attack_done = false
	local start_ts = store.tick_ts
	local an, af = __pc_helpers["__pc_soldier_amazona_update_44"](this, attack.animation, target.pos)
	U.animation_start_default(this, an, af, store.tick_ts, false)
	S:queue(attack.sound, attack.sound_args)
	while ((store.tick_ts - start_ts) < attack.hit_time) do
		if (SU.attack_interrupted(this, attack) or (((not attack.ignore_rally_change) and this.nav_rally) and this.nav_rally.new)) then
			goto label_72_0
		elseif SU.dodge_active(this) then
			this.render.sprites[1].alpha = 128
		end
		coroutine.yield()
	end
	S:queue(attack.sound_hit, attack.sound_hit_args)
	attack.ts = start_ts
	if attack.shared_cooldown then
		for _, aa in ipairs(this.melee.attacks) do
			if ((aa ~= attack) and aa.shared_cooldown) then
				aa.ts = attack.ts
			end
		end
	end
	if attack.forced_cooldown then
		this.melee.forced_ts = attack.ts
	end
	if attack.cooldown_group then
		for _, aa in ipairs(this.melee.attacks) do
			if ((aa ~= attack) and (aa.cooldown_group == attack.cooldown_group)) then
				aa.ts = attack.ts
			end
		end
	end
	if attack.signal then
		signal.emit("soldier-attack", this, attack, attack.signal)
	end
	if ((not __pc_helpers["__pc_enemy_abomination_update_32"](store, target, false, attack, this)) and table.arraycontains(target.enemy.blockers, this.id)) then
		if (((attack.damage_type ~= DAMAGE_NONE) and attack.fn_damage) or attack.damage_min) then
			local d = E.assign_damage(attack.damage_type, ((((((attack.fn_damage and attack.fn_damage(this, store, attack, target)) or math.random(attack.damage_min, attack.damage_max))) + this.unit.damage_buff)) * this.unit.damage_factor), this.id, target.id)
			d.xp_gain_factor = attack.xp_gain_factor
			d.xp_dest_id = attack.xp_dest_id
			d.track_kills = (this.track_kills ~= nil)
			d.track_damage = attack.track_damage
			d.pop = attack.pop
			d.pop_chance = attack.pop_chance
			d.pop_conds = attack.pop_conds
			queue_damage(store, d)
			if attack.side_effect then
				attack.side_effect(this, store, d, target)
			end
		end
		if attack.mod then
			if ((not attack.mod_chance) or (math.random() < attack.mod_chance)) then
				local mod = E:create_entity(attack.mod)
				mod.modifier.ts = store.tick_ts
				mod.modifier.target_id = target.id
				mod.modifier.source_id = this.id
				mod.modifier.level = attack.level
				mod.modifier.damage_factor = this.unit.damage_factor
				simulation:queue_insert_entity(mod)
			end
		end
		if attack.mods then
			if ((not attack.mod_chance) or (math.random() < attack.mod_chance)) then
				for _, m in ipairs(attack.mods) do
					local mod = E:create_entity(m)
					mod.modifier.ts = store.tick_ts
					mod.modifier.target_id = target.id
					mod.modifier.source_id = this.id
					mod.modifier.level = attack.level
					mod.modifier.damage_factor = this.unit.damage_factor
					simulation:queue_insert_entity(mod)
				end
			end
		end
		local hit_pos = V.vclone(this.pos)
		if attack.hit_offset then
			hit_pos.x = (hit_pos.x + ((((af and (- 1)) or 1)) * attack.hit_offset.x))
			hit_pos.y = (hit_pos.y + attack.hit_offset.y)
		end
		if attack.hit_aura then
			local a = E:create_entity(attack.hit_aura)
			a.pos = V.vclone(hit_pos)
			a.aura.target_id = target.id
			a.aura.source_id = this.id
			simulation:queue_insert_entity(a)
		end
		if attack.hit_fx then
			local fx = E:create_entity(attack.hit_fx)
			fx.pos = V.vclone(hit_pos)
			for i = 1, (# fx.render.sprites) do
				fx.render.sprites[i].ts = store.tick_ts
			end
			simulation:queue_insert_entity(fx)
		end
		if attack.hit_decal then
			local fx = E:create_entity(attack.hit_decal)
			fx.pos = V.vclone(hit_pos)
			for i = 1, (# fx.render.sprites) do
				fx.render.sprites[i].ts = store.tick_ts
			end
			simulation:queue_insert_entity(fx)
		end
	end
	if ((this.pickpocket and ((not this.pickpocket.power_name) or (this.powers[this.pickpocket.power_name].level > 0))) and (math.random() < this.pickpocket.chance)) then
		local pi = this.pickpocket
		if (target.enemy and (target.enemy.gold_bag > 0)) then
			local q = km.clamp(0, target.enemy.gold_bag, math.floor((0.5 + U.frandom(pi.steal_min, pi.steal_max))))
			if (q > 0) then
				S:queue(this.pickpocket.sound)
				signal.emit("soldier-pickpocket", this, q)
			end
			target.enemy.gold_bag = (target.enemy.gold_bag - q)
			store.player_gold = (store.player_gold + q)
			if pi.fx then
				local fx = E:create_entity(pi.fx)
				fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
				fx.render.sprites[1].ts = store.tick_ts
				simulation:queue_insert_entity(fx)
			end
		end
	end
	attack_done = true
	while (not U.animation_finished_default(this)) do
		if (SU.attack_interrupted(this, attack) or (((not attack.ignore_rally_change) and this.nav_rally) and this.nav_rally.new)) then
			break
		elseif SU.dodge_active(this) then
			this.render.sprites[1].alpha = 128
		end
		coroutine.yield()
	end
	__pc_helpers["__pc_bolt_1_insert_1"](this, "idle", nil, store.tick_ts, true)
	::label_72_0::
	S:stop(attack.sound)
	if (SU.dodge_active(this) and (this.render.sprites[1].alpha == 128)) then
		this.render.sprites[1].alpha = 255
		this.dodge.active = false
	end
	return attack_done
end
__pc_helpers["__pc_soldier_amazona_update_9"] = function(store, this)
	if ((((not this.revive) or this.revive.disabled) or this.unit.is_stunned) or (band(this.health.last_damage_types, bor(DAMAGE_DISINTEGRATE, DAMAGE_EAT)) ~= 0)) then
		return false
	end
	local r = this.revive
	local chance = (r.chance + r.protect)
	if (math.random() < chance) then
		local r = this.revive
		r.protect = (r.protect * 0.5)
		if r.remove_modifiers then
			SU.remove_modifiers(store, this)
		end
		this.health.ignore_damage = true
		this.health.dead = false
		this.health_bar.hidden = false
		if this.soldier.target_id then
			local enemy = store.entities[this.soldier.target_id]
			if enemy then
				U.block_enemy(store, this, enemy)
			end
		end
		if r.fx then
			local fx = E:create_entity(r.fx)
			fx.pos = this.pos
			fx.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(fx)
		end
		if r.animation then
			S:queue(r.sound)
			__pc_helpers["__pc_enemy_abomination_update_13"](this, r.animation, nil, store.tick_ts, false)
			r.ts = store.tick_ts
			while ((store.tick_ts - r.ts) < r.hit_time) do
				coroutine.yield()
			end
		end
		r.revive_count = (((r.revive_count or 0)) + 1)
		signal.emit("entity-revived", this, r.revive_count)
		U.heal(this, (this.health.hp_max * r.health_recover))
		if r.animation then
			while (not U.animation_finished_default(this)) do
				coroutine.yield()
			end
		end
		this.health.ignore_damage = false
		return true
	end
	return false
end
__pc_helpers["__pc_soldier_arborean_sentinels_barkshield_update_50"] = function(store, this)
	if ((store.tick_ts - this.soldier.last_block_ts) < 0.1) then
		return false, A_NO_TARGET
	end
	local target = SU.soldier_pick_melee_target(store, this)
	if (not target) then
		this.soldier.last_block_ts = store.tick_ts
		return false, A_NO_TARGET
	end
	if SU.soldier_move_to_slot_step(store, this, target) then
		return true
	end
	local attack = SU.soldier_pick_melee_attack(store, this, target)
	if (not attack) then
		return false, A_IN_COOLDOWN
	end
	if attack.xp_from_skill then
		SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
	end
	local attack_done
	if attack.loops then
		attack_done = SU.y_soldier_do_loopable_melee_attack(store, this, target, attack)
	elseif (attack.type == "area") then
		attack_done = SU.y_soldier_do_single_area_attack(store, this, target, attack)
	else
		attack_done = __pc_helpers["__pc_soldier_arborean_sentinels_barkshield_update_63"](store, this, target, attack)
	end
	if attack_done then
		return false, A_DONE
	else
		return true
	end
end
__pc_helpers["__pc_soldier_arborean_sentinels_barkshield_update_63"] = function(store, this, target, attack)
	local attack_done = false
	local start_ts = store.tick_ts
	local an, af = __pc_helpers["__pc_soldier_amazona_update_44"](this, attack.animation, target.pos)
	U.animation_start_default(this, an, af, store.tick_ts, false)
	S:queue(attack.sound, attack.sound_args)
	while ((store.tick_ts - start_ts) < attack.hit_time) do
		if (SU.attack_interrupted(this, attack) or (((not attack.ignore_rally_change) and this.nav_rally) and this.nav_rally.new)) then
			goto label_72_0
		elseif SU.dodge_active(this) then
			this.render.sprites[1].alpha = 128
		end
		coroutine.yield()
	end
	S:queue(attack.sound_hit, attack.sound_hit_args)
	attack.ts = start_ts
	if attack.shared_cooldown then
		for _, aa in ipairs(this.melee.attacks) do
			if ((aa ~= attack) and aa.shared_cooldown) then
				aa.ts = attack.ts
			end
		end
	end
	if attack.forced_cooldown then
		this.melee.forced_ts = attack.ts
	end
	if attack.cooldown_group then
		for _, aa in ipairs(this.melee.attacks) do
			if ((aa ~= attack) and (aa.cooldown_group == attack.cooldown_group)) then
				aa.ts = attack.ts
			end
		end
	end
	if attack.signal then
		signal.emit("soldier-attack", this, attack, attack.signal)
	end
	if ((not __pc_helpers["__pc_enemy_abomination_update_32"](store, target, false, attack, this)) and table.arraycontains(target.enemy.blockers, this.id)) then
		if (((attack.damage_type ~= DAMAGE_NONE) and attack.fn_damage) or attack.damage_min) then
			local d = E.assign_damage(attack.damage_type, ((((((attack.fn_damage and attack.fn_damage(this, store, attack, target)) or math.random(attack.damage_min, attack.damage_max))) + this.unit.damage_buff)) * this.unit.damage_factor), this.id, target.id)
			d.xp_gain_factor = attack.xp_gain_factor
			d.xp_dest_id = attack.xp_dest_id
			d.track_kills = (this.track_kills ~= nil)
			d.track_damage = attack.track_damage
			d.pop = attack.pop
			d.pop_chance = attack.pop_chance
			d.pop_conds = attack.pop_conds
			queue_damage(store, d)
			if attack.side_effect then
				attack.side_effect(this, store, d, target)
			end
		end
		if attack.mod then
			if ((not attack.mod_chance) or (math.random() < attack.mod_chance)) then
				local mod = E:create_entity(attack.mod)
				mod.modifier.ts = store.tick_ts
				mod.modifier.target_id = target.id
				mod.modifier.source_id = this.id
				mod.modifier.level = attack.level
				mod.modifier.damage_factor = this.unit.damage_factor
				simulation:queue_insert_entity(mod)
			end
		end
		if attack.mods then
			if ((not attack.mod_chance) or (math.random() < attack.mod_chance)) then
				for _, m in ipairs(attack.mods) do
					local mod = E:create_entity(m)
					mod.modifier.ts = store.tick_ts
					mod.modifier.target_id = target.id
					mod.modifier.source_id = this.id
					mod.modifier.level = attack.level
					mod.modifier.damage_factor = this.unit.damage_factor
					simulation:queue_insert_entity(mod)
				end
			end
		end
		local hit_pos = V.vclone(this.pos)
		if attack.hit_offset then
			hit_pos.x = (hit_pos.x + ((((af and (- 1)) or 1)) * attack.hit_offset.x))
			hit_pos.y = (hit_pos.y + attack.hit_offset.y)
		end
		if attack.hit_aura then
			local a = E:create_entity(attack.hit_aura)
			a.pos = V.vclone(hit_pos)
			a.aura.target_id = target.id
			a.aura.source_id = this.id
			simulation:queue_insert_entity(a)
		end
		if attack.hit_fx then
			local fx = E:create_entity(attack.hit_fx)
			fx.pos = V.vclone(hit_pos)
			for i = 1, (# fx.render.sprites) do
				fx.render.sprites[i].ts = store.tick_ts
			end
			simulation:queue_insert_entity(fx)
		end
		if attack.hit_decal then
			local fx = E:create_entity(attack.hit_decal)
			fx.pos = V.vclone(hit_pos)
			for i = 1, (# fx.render.sprites) do
				fx.render.sprites[i].ts = store.tick_ts
			end
			simulation:queue_insert_entity(fx)
		end
	end
	if ((this.pickpocket and (not this.pickpocket.power_name)) and (math.random() < this.pickpocket.chance)) then
		local pi = this.pickpocket
		if (target.enemy and (target.enemy.gold_bag > 0)) then
			local q = km.clamp(0, target.enemy.gold_bag, math.floor((0.5 + U.frandom(pi.steal_min, pi.steal_max))))
			if (q > 0) then
				S:queue(this.pickpocket.sound)
				signal.emit("soldier-pickpocket", this, q)
			end
			target.enemy.gold_bag = (target.enemy.gold_bag - q)
			store.player_gold = (store.player_gold + q)
			if pi.fx then
				local fx = E:create_entity(pi.fx)
				fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
				fx.render.sprites[1].ts = store.tick_ts
				simulation:queue_insert_entity(fx)
			end
		end
	end
	attack_done = true
	while (not U.animation_finished_default(this)) do
		if (SU.attack_interrupted(this, attack) or (((not attack.ignore_rally_change) and this.nav_rally) and this.nav_rally.new)) then
			break
		elseif SU.dodge_active(this) then
			this.render.sprites[1].alpha = 128
		end
		coroutine.yield()
	end
	__pc_helpers["__pc_bolt_1_insert_1"](this, "idle", nil, store.tick_ts, true)
	::label_72_0::
	S:stop(attack.sound)
	if (SU.dodge_active(this) and (this.render.sprites[1].alpha == 128)) then
		this.render.sprites[1].alpha = 255
		this.dodge.active = false
	end
	return attack_done
end
__pc_helpers["__pc_soldier_arborean_sentinels_spearmen_insert_3"] = function(this, power_name)
	local pn = power_name
	local pow = (this.powers and this.powers[pn])
	if (not pow) then
		return
	end
	local level_inc = (pow.level - ((pow._last_level or 0)))
	if (level_inc <= 0) then
		return
	end
	pow._last_level = pow.level
	if ((this.health.power_name == pn) and this.health.hp_inc) then
		this.health.hp_max = (this.health.hp_max + (this.health.hp_inc * level_inc))
		this.health.hp = this.health.hp_max
	end
	if ((this.health.armor_power_name == pn) and this.health.armor_inc) then
		SU.armor_inc(this, (this.health.armor_inc * level_inc))
	end
	if ((this.health.magic_armor_power_name == pn) and this.health.magic_armor_inc) then
		SU.magic_armor_inc(this, (this.health.magic_armor_inc * level_inc))
	end
	do
		for _, a in ipairs(this.ranged.attacks) do
			if (a.power_name == pn) then
				a.level = pow.level
				if a.disabled then
					a.disabled = nil
				end
				if a.cooldown_inc then
					a.cooldown = (a.cooldown + (a.cooldown_inc * level_inc))
				end
				if a.range_inc then
					a.max_range = (a.max_range + (a.range_inc * level_inc))
				end
				if a.chance_inc then
					a.chance = (a.chance + (a.chance_inc * level_inc))
				end
			end
		end
	end
	do
		local min_cooldown = 1e+99
		local cooldown_changed = false
		for _, a in ipairs(this.melee.attacks) do
			if (a.power_name == pn) then
				a.level = pow.level
				if a.disabled then
					a.disabled = nil
				end
				if a.chance_inc then
					a.chance = (a.chance + (a.chance_inc * level_inc))
					this.melee.order = U.attack_order(this.melee.attacks)
				end
				if a.damage_inc then
					a.damage_min = (a.damage_min + (a.damage_inc * level_inc))
					a.damage_max = (a.damage_max + (a.damage_inc * level_inc))
				end
				if (a.damage_min_inc and a.damage_max_inc) then
					a.damage_min = (a.damage_min + (a.damage_min_inc * level_inc))
					a.damage_max = (a.damage_max + (a.damage_max_inc * level_inc))
				end
				if a.cooldown_inc then
					a.cooldown = (a.cooldown + (a.cooldown_inc * level_inc))
					cooldown_changed = true
				end
			end
			if a.cooldown then
				min_cooldown = math.min(a.cooldown, min_cooldown)
			end
		end
		if (this.melee.forced_cooldown and (min_cooldown < this.melee.forced_cooldown)) then
			this.melee.forced_cooldown = min_cooldown
		end
	end
	if this.timed_actions then
		for _, a in ipairs(this.timed_actions.list) do
			if (a.power_name == pn) then
				if a.level then
					a.level = pow.level
				end
				if a.disabled then
					a.disabled = nil
				end
			end
		end
	end
	if this.timed_attacks then
		for _, a in ipairs(this.timed_attacks.list) do
			if (a.power_name == pn) then
				if a.level then
					a.level = pow.level
				end
				if a.disabled then
					a.disabled = nil
				end
			end
		end
	end
	if (this.revive and (this.revive.power_name == pn)) then
		this.revive.disabled = nil
		if this.revive.chance_inc then
			this.revive.chance = (this.revive.chance + (this.revive.chance_inc * level_inc))
		end
		if this.revive.health_recover then
			this.revive.health_recover = (this.revive.health_recover + (this.revive.health_recover_inc * level_inc))
		end
	end
	if this.dodge then
		local d = this.dodge
		if (d.power_name == pn) then
			if d.chance_inc then
				d.chance = (d.chance + (d.chance_inc * level_inc))
			end
		end
		if (d.counter_attack and (d.counter_attack.power_name == pn)) then
			if d.counter_attack.damage_inc then
				d.counter_attack.damage_min = (d.counter_attack.damage_min + (d.counter_attack.damage_inc * level_inc))
				d.counter_attack.damage_max = (d.counter_attack.damage_max + (d.counter_attack.damage_inc * level_inc))
			end
		end
	end
	if (this.pickpocket and (this.pickpocket.power_name == pn)) then
		local pi = this.pickpocket
		if pi.chance_inc then
			pi.chance = (pi.chance + (pi.chance_inc * level_inc))
		end
	end
	local fn = (pow and pow.on_power_upgrade)
	if fn then
		fn(this, power_name, pow)
	end
end
__pc_helpers["__pc_soldier_arborean_sentinels_spearmen_update_56"] = function(store, this)
	local target, attack, pred_pos = SU.soldier_pick_ranged_target_and_attack(store, this)
	if (not target) then
		return false, A_NO_TARGET
	end
	if (not attack) then
		return false, A_IN_COOLDOWN
	end
	local start_ts = store.tick_ts
	local attack_done
	if attack.loops then
		attack_done = __pc_helpers["__pc_soldier_arborean_sentinels_spearmen_update_58"](store, this, target, attack)
	else
		attack_done = SU.y_soldier_do_ranged_attack(store, this, target, attack, pred_pos)
	end
	if attack_done then
		attack.ts = start_ts
		if attack.shared_cooldown then
			for _, aa in ipairs(this.ranged.attacks) do
				if ((aa ~= attack) and aa.shared_cooldown) then
					aa.ts = attack.ts
				end
			end
		end
		if this.ranged.forced_cooldown then
			this.ranged.forced_ts = start_ts
		end
	end
	if attack_done then
		return false, A_DONE
	else
		return true
	end
end
__pc_helpers["__pc_soldier_arborean_sentinels_spearmen_update_58"] = function(store, this, target, attack)
	local attack_done = false
	local b, an, af, ai
	S:queue(attack.sound, attack.sound_args)
	if attack.animations[1] then
		an, af, ai = __pc_helpers["__pc_soldier_amazona_update_44"](this, attack.animations[1], target.pos)
		__pc_helpers["__pc_soldier_arborean_sentinels_spearmen_update_59"](this, an, af, store.tick_ts, 1, attack.sprite_group)
	end
	for i = 1, attack.loops do
		an, af, ai = __pc_helpers["__pc_soldier_amazona_update_44"](this, attack.animations[2], target.pos)
		__pc_helpers["__pc_soldier_arborean_sentinels_spearmen_update_62"](this, an, af, store.tick_ts, false, attack.sprite_group)
		for si, st in ipairs(attack.shoot_times) do
			while (st > (store.tick_ts - U.get_animation_ts(this, attack.sprite_group))) do
				if this.unit.is_stunned then
					goto label_59_0
				end
				if (this.health.dead or (this.nav_rally and this.nav_rally.new)) then
					goto label_59_1
				end
				coroutine.yield()
			end
			b = E:create_entity(attack.bullet)
			b.pos:copy(this.pos)
			if attack.bullet_start_offset then
				local offset = attack.bullet_start_offset[ai]
				b.pos.x, b.pos.y = (b.pos.x + ((((af and (- 1)) or 1)) * offset.x)), (b.pos.y + offset.y)
			end
			if attack.bullet_shot_start_offset then
				local offset = attack.bullet_shot_start_offset[si]
				b.pos.x, b.pos.y = (b.pos.x + ((((af and (- 1)) or 1)) * offset.x)), (b.pos.y + offset.y)
			end
			b.bullet.from:copy(b.pos)
			b.bullet.to:set((target.pos.x + target.unit.hit_offset.x), (target.pos.y + target.unit.hit_offset.y))
			b.bullet.target_id = target.id
			b.bullet.shot_index = si
			b.bullet.loop_index = i
			b.bullet.source_id = this.id
			b.bullet.xp_dest_id = this.id
			b.bullet.damage_factor = this.unit.damage_factor
			b.bullet.damage_max = (b.bullet.damage_max + this.unit.damage_buff)
			b.bullet.damage_min = (b.bullet.damage_min + this.unit.damage_buff)
			b.bullet.level = attack.level
			simulation:queue_insert_entity(b)
			if attack.xp_from_skill then
				SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
			end
			if attack.check_target_before_shot then
				if (target.health.dead or ((target.health.hp - U.predict_damage(target, SU.create_bullet_damage_without_pops(b.bullet, target.id, b.id))) < 0)) then
					local new_target = U.detect_foremost_enemy_between_range_filter_on(target.pos, attack.min_range, attack.max_range, attack.vis_flags, attack.vis_bans, function(e)
	return ((e.id ~= target.id) and (((not attack.filter_fn) or attack.filter_fn(e))))
end)
					if new_target then
						target = new_target
					end
				end
			end
			attack_done = true
		end
		while (not U.animation_finished_group(this, attack.sprite_group)) do
			if this.unit.is_stunned then
				goto label_59_0
			end
			if (this.health.dead or (this.nav_rally and this.nav_rally.new)) then
				goto label_59_1
			end
			coroutine.yield()
		end
	end
	::label_59_0::
	if attack.animations[3] then
		an, af, ai = __pc_helpers["__pc_soldier_amazona_update_44"](this, attack.animations[3], target.pos)
		__pc_helpers["__pc_soldier_arborean_sentinels_spearmen_update_62"](this, an, af, store.tick_ts, false, attack.sprite_group)
		while (not U.animation_finished_group(this, attack.sprite_group)) do
			if (this.health.dead or (this.nav_rally and this.nav_rally.new)) then
				break
			end
			coroutine.yield()
		end
	end
	::label_59_1::
	if attack.xp_from_skill_once then
		SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill_once])
	end
	return attack_done
end
__pc_helpers["__pc_soldier_arborean_sentinels_spearmen_update_59"] = function(entity, name, flip_x, ts, times, group)
	if (not group) then
		U.y_animation_play(entity, name, flip_x, ts, times)
		return
	end
	__pc_helpers["__pc_soldier_arborean_sentinels_spearmen_update_62"](entity, name, flip_x, ts, (times and (times > 1)), group)
	local idx
	local sprites = entity.render.sprites
	for i = 1, (# sprites) do
		if (sprites[i].group == group) then
			idx = i
			break
		end
	end
	if idx then
		while (not U.animation_finished(entity, idx, times)) do
			coroutine.yield()
		end
	end
end
__pc_helpers["__pc_soldier_arborean_sentinels_spearmen_update_62"] = function(entity, name, flip_x, ts, loop, group)
	if (not group) then
		U.animation_start(entity, name, flip_x, ts, loop)
		return
	end
	local sprites = entity.render.sprites
	do
		local i = 1
		local s = sprites[i]
		if (s.group == group) then
			__pc_helpers["__pc_enemy_abomination_update_31"](entity, name, flip_x, ts, loop, i)
		end
	end
end
__pc_helpers["__pc_soldier_bone_golem_update_15"] = function(store, this)
	U.unblock_target(store, this)
	local h = this.health
	if ((this.selfdestruct and (not this.selfdestruct.disabled)) and (band(h.last_damage_types, bor(DAMAGE_EAT, DAMAGE_HOST, DAMAGE_DISINTEGRATE)) == 0)) then
		local sd = this.selfdestruct
		this.unit.hide_after_death = true
		this.health_bar.hidden = true
		__pc_helpers["__pc_enemy_bat_update_13"](this, sd.animation, nil, store.tick_ts)
		S:queue(this.sound_events.death, this.sound_events.death_args)
		S:queue(sd.sound, sd.sound_args)
		U.y_wait_unconditional(store, sd.hit_time)
		S:queue(sd.sound_hit)
		if sd.hit_fx then
			SU.insert_sprite(store, sd.hit_fx, this.pos)
		end
		local targets = U.find_enemies_in_range_filter_off(this.pos, sd.damage_radius, sd.vis_flags, sd.vis_bans)
		if targets then
			for _, t in ipairs(targets) do
				local d = E.assign_damage(sd.damage_type, ((((((sd.damage and sd.damage) or math.random(sd.damage_min, sd.damage_max))) + this.unit.damage_buff)) * this.unit.damage_factor), this.id, t.id)
				queue_damage(store, d)
				if sd.mod then
					local m = E:create_entity(sd.mod)
					m.modifier.target_id = t.id
					m.modifier.source_id = this.id
					m.modifier.damage_factor = this.unit.damage_factor
					simulation:queue_insert_entity(m)
				end
			end
		end
		U.y_animation_wait_default(this)
	elseif (band(h.last_damage_types, DAMAGE_DISINTEGRATE) ~= 0) then
		this.unit.hide_during_death = true
		local fx = E:create_entity("fx_soldier_desintegrate")
		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts
		simulation:queue_insert_entity(fx)
	elseif (band(h.last_damage_types, bor(DAMAGE_EAT)) ~= 0) then
		this.unit.hide_during_death = true
	elseif (band(h.last_damage_types, bor(DAMAGE_HOST)) ~= 0) then
		S:queue(this.sound_events.death_by_explosion)
		this.unit.hide_during_death = true
		local fx = E:create_entity("fx_unit_explode")
		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]
		simulation:queue_insert_entity(fx)
		if (this.unit.show_blood_pool and (this.unit.blood_color ~= BLOOD_NONE)) then
			local decal = E:create_entity("decal_blood_pool")
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			decal.render.sprites[1].name = this.unit.blood_color
			simulation:queue_insert_entity(decal)
		end
	elseif (this.reinforcement and (this.reinforcement.fade or this.reinforcement.fade_out)) then
		SU.y_reinforcement_fade_out(store, this)
		return
	else
		S:queue(this.sound_events.death, this.sound_events.death_args)
		__pc_helpers["__pc_enemy_bat_update_9"](this, "death", nil, store.tick_ts, 1)
		this.ui.can_select = false
	end
	if this.ui then
		this.ui.can_click = (not this.unit.hide_after_death)
		this.ui.z = (- 1)
	end
	if (this.unit.hide_during_death or this.unit.hide_after_death) then
		for _, s in ipairs(this.render.sprites) do
			s.hidden = true
		end
	end
end
__pc_helpers["__pc_soldier_bone_golem_update_27"] = function(this, store)
	if (((not this.revive) or (not this.revive.resist)) or this.revive.disabled) then
		return
	end
	local r = this.revive.resist
	if (this.revive.protect < r.cost) then
		return
	end
	local mods = U.find_modifiers_with_flags(this, r.bans)
	if ((not mods) or ((# mods) == 0)) then
		return
	end
	if ((not this.soldier.target_id) or (store.entities[this.soldier.target_id] == nil)) then
		local block_target = SU.soldier_pick_melee_target(store, this)
		if block_target then
			U.block_enemy(store, this, block_target)
		end
	end
	this.revive.protect = (this.revive.protect - r.cost)
	local clear_stun = false
	this.health.ignore_damage = true
	for _, m in ipairs(mods) do
		if (band(m.modifier.vis_flags, F_STUN) ~= 0) then
			clear_stun = true
		end
		m.modifier.removed_by_ban = true
	end
	local mod_ban = E:create_entity("mod_ban")
	mod_ban.modifier.ban_vis = r.bans
	mod_ban.modifier.target_id = this.id
	mod_ban.modifier.duration = r.duration
	simulation:queue_insert_entity(mod_ban)
	if this.revive.animation then
		S:queue(this.revive.sound)
		__pc_helpers["__pc_enemy_bat_update_13"](this, this.revive.animation, nil, store.tick_ts, false)
		this.revive.ts = store.tick_ts
	end
	for _, m in ipairs(mods) do
		while store.entities[m.id] do
			m.modifier.ts = (- 10000)
			m.modifier.duration = 0.01
			coroutine.yield()
		end
	end
	if this.revive.fx then
		local fx = E:create_entity(this.revive.fx)
		fx.pos = this.pos
		fx.render.sprites[1].ts = store.tick_ts
		simulation:queue_insert_entity(fx)
	end
	if this.revive.animation then
		while (not U.animation_finished_default(this)) do
			coroutine.yield()
		end
	end
	do
		this.unit.is_stunned = nil
	end
	this.health.ignore_damage = false
	if r.side_effect then
		r.side_effect(this, store)
	end
end
__pc_helpers["__pc_soldier_bone_golem_update_3"] = function(store, this)
	if ((((not this.revive) or this.revive.disabled) or this.unit.is_stunned) or (band(this.health.last_damage_types, bor(DAMAGE_DISINTEGRATE, DAMAGE_EAT)) ~= 0)) then
		return false
	end
	local r = this.revive
	local chance = (r.chance + r.protect)
	if (math.random() < chance) then
		local r = this.revive
		r.protect = (r.protect * 0.5)
		if r.remove_modifiers then
			SU.remove_modifiers(store, this)
		end
		this.health.ignore_damage = true
		this.health.dead = false
		this.health_bar.hidden = false
		if this.soldier.target_id then
			local enemy = store.entities[this.soldier.target_id]
			if enemy then
				U.block_enemy(store, this, enemy)
			end
		end
		if r.fx then
			local fx = E:create_entity(r.fx)
			fx.pos = this.pos
			fx.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(fx)
		end
		if r.animation then
			S:queue(r.sound)
			__pc_helpers["__pc_enemy_bat_update_13"](this, r.animation, nil, store.tick_ts, false)
			r.ts = store.tick_ts
			while ((store.tick_ts - r.ts) < r.hit_time) do
				coroutine.yield()
			end
		end
		r.revive_count = (((r.revive_count or 0)) + 1)
		signal.emit("entity-revived", this, r.revive_count)
		U.heal(this, (this.health.hp_max * r.health_recover))
		if r.animation then
			while (not U.animation_finished_default(this)) do
				coroutine.yield()
			end
		end
		this.health.ignore_damage = false
		return true
	end
	return false
end
__pc_helpers["__pc_soldier_bone_golem_update_33"] = function(store, this, force_ts)
	__pc_helpers["__pc_soldier_bone_golem_update_34"](this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, force_ts)
	if this.unit.is_stunned then
		return
	end
	if ((store.tick_ts - this.idle_flip.ts) > (2 * store.tick_length)) then
		this.idle_flip.ts_counter = 0
	end
	this.idle_flip.ts = store.tick_ts
	this.idle_flip.ts_counter = (this.idle_flip.ts_counter + store.tick_length)
	if (this.idle_flip.ts_counter > this.idle_flip.cooldown) then
		this.idle_flip.ts_counter = 0
		if (math.random() < this.idle_flip.chance) then
			do
				local i = 1
				this.render.sprites[i].flip_x = (not this.render.sprites[i].flip_x)
			end
			do
				local i = 2
				this.render.sprites[i].flip_x = (not this.render.sprites[i].flip_x)
			end
		end
		if this.idle_flip.animations then
			this.idle_flip.last_animation = table.random(this.idle_flip.animations)
		end
	end
end
__pc_helpers["__pc_soldier_bone_golem_update_34"] = function(entity, name, flip_x, ts, loop, idx, force_ts)
	local first, last
	do
		first, last = 1, (# entity.render.sprites)
	end
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or force_ts) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
	do
		local i = 2
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or force_ts) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_soldier_bone_golem_update_37"] = function(store, this)
	local r = this.nav_rally
	local out = false
	local prev_immune = this.health.immune_to
	this.health.immune_to = r.immune_to
	U.bans_add(this.vis, F_ALL)
	if r.new then
		r.new = false
		U.unblock_target(store, this)
		U.set_destination(this, r.pos)
		local an, af = __pc_helpers["__pc_soldier_amazona_update_44"](this, "walk", this.motion.dest)
		__pc_helpers["__pc_soldier_bone_golem_update_39"](this, an, af, store.tick_ts, true, nil, true)
		while (not this.motion.arrived) do
			if (this.health.dead or this.unit.is_stunned) then
				out = true
				break
			end
			if r.new then
				out = false
				break
			end
			U.walk_off__accel__unsnapped(this, store.tick_length)
			coroutine.yield()
			this.motion.speed.x, this.motion.speed.y = 0, 0
		end
	end
	U.bans_remove(this.vis, F_ALL)
	this.health.immune_to = prev_immune
	return out
end
__pc_helpers["__pc_soldier_bone_golem_update_39"] = function(entity, name, flip_x, ts, loop, idx, force_ts)
	local first, last
	do
		first, last = 1, (# entity.render.sprites)
	end
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if (flip_x ~= nil) then
				a.flip_x = flip_x
			end
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or true) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
	do
		local i = 2
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if (flip_x ~= nil) then
				a.flip_x = flip_x
			end
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or true) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_soldier_bone_golem_update_50"] = function(store, this)
	local target, attack, pred_pos = SU.soldier_pick_ranged_target_and_attack(store, this)
	if (not target) then
		return false, A_NO_TARGET
	end
	if (not attack) then
		return false, A_IN_COOLDOWN
	end
	local start_ts = store.tick_ts
	local attack_done
	if attack.loops then
		attack_done = __pc_helpers["__pc_soldier_bone_golem_update_52"](store, this, target, attack)
	else
		attack_done = SU.y_soldier_do_ranged_attack(store, this, target, attack, pred_pos)
	end
	if attack_done then
		attack.ts = start_ts
		if attack.shared_cooldown then
			for _, aa in ipairs(this.ranged.attacks) do
				if ((aa ~= attack) and aa.shared_cooldown) then
					aa.ts = attack.ts
				end
			end
		end
		if this.ranged.forced_cooldown then
			this.ranged.forced_ts = start_ts
		end
	end
	if attack_done then
		return false, A_DONE
	else
		return true
	end
end
__pc_helpers["__pc_soldier_bone_golem_update_52"] = function(store, this, target, attack)
	local attack_done = false
	local b, an, af, ai
	S:queue(attack.sound, attack.sound_args)
	if attack.animations[1] then
		an, af, ai = __pc_helpers["__pc_soldier_amazona_update_44"](this, attack.animations[1], target.pos)
		__pc_helpers["__pc_soldier_bone_golem_update_53"](this, an, af, store.tick_ts, 1, attack.sprite_group)
	end
	for i = 1, attack.loops do
		an, af, ai = __pc_helpers["__pc_soldier_amazona_update_44"](this, attack.animations[2], target.pos)
		__pc_helpers["__pc_soldier_bone_golem_update_56"](this, an, af, store.tick_ts, false, attack.sprite_group)
		for si, st in ipairs(attack.shoot_times) do
			while (st > (store.tick_ts - U.get_animation_ts(this, attack.sprite_group))) do
				if this.unit.is_stunned then
					goto label_59_0
				end
				if (this.health.dead or (this.nav_rally and this.nav_rally.new)) then
					goto label_59_1
				end
				coroutine.yield()
			end
			b = E:create_entity(attack.bullet)
			b.pos:copy(this.pos)
			if attack.bullet_start_offset then
				local offset = attack.bullet_start_offset[ai]
				b.pos.x, b.pos.y = (b.pos.x + ((((af and (- 1)) or 1)) * offset.x)), (b.pos.y + offset.y)
			end
			if attack.bullet_shot_start_offset then
				local offset = attack.bullet_shot_start_offset[si]
				b.pos.x, b.pos.y = (b.pos.x + ((((af and (- 1)) or 1)) * offset.x)), (b.pos.y + offset.y)
			end
			b.bullet.from:copy(b.pos)
			b.bullet.to:set((target.pos.x + target.unit.hit_offset.x), (target.pos.y + target.unit.hit_offset.y))
			b.bullet.target_id = target.id
			b.bullet.shot_index = si
			b.bullet.loop_index = i
			b.bullet.source_id = this.id
			b.bullet.xp_dest_id = this.id
			b.bullet.damage_factor = this.unit.damage_factor
			b.bullet.damage_max = (b.bullet.damage_max + this.unit.damage_buff)
			b.bullet.damage_min = (b.bullet.damage_min + this.unit.damage_buff)
			b.bullet.level = attack.level
			simulation:queue_insert_entity(b)
			if attack.xp_from_skill then
				SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
			end
			if attack.check_target_before_shot then
				if (target.health.dead or ((target.health.hp - U.predict_damage(target, SU.create_bullet_damage_without_pops(b.bullet, target.id, b.id))) < 0)) then
					local new_target = U.detect_foremost_enemy_between_range_filter_on(target.pos, attack.min_range, attack.max_range, attack.vis_flags, attack.vis_bans, function(e)
	return ((e.id ~= target.id) and (((not attack.filter_fn) or attack.filter_fn(e))))
end)
					if new_target then
						target = new_target
					end
				end
			end
			attack_done = true
		end
		while (not U.animation_finished_group(this, attack.sprite_group)) do
			if this.unit.is_stunned then
				goto label_59_0
			end
			if (this.health.dead or (this.nav_rally and this.nav_rally.new)) then
				goto label_59_1
			end
			coroutine.yield()
		end
	end
	::label_59_0::
	if attack.animations[3] then
		an, af, ai = __pc_helpers["__pc_soldier_amazona_update_44"](this, attack.animations[3], target.pos)
		__pc_helpers["__pc_soldier_bone_golem_update_56"](this, an, af, store.tick_ts, false, attack.sprite_group)
		while (not U.animation_finished_group(this, attack.sprite_group)) do
			if (this.health.dead or (this.nav_rally and this.nav_rally.new)) then
				break
			end
			coroutine.yield()
		end
	end
	::label_59_1::
	if attack.xp_from_skill_once then
		SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill_once])
	end
	return attack_done
end
__pc_helpers["__pc_soldier_bone_golem_update_53"] = function(entity, name, flip_x, ts, times, group)
	if (not group) then
		U.y_animation_play(entity, name, flip_x, ts, times)
		return
	end
	__pc_helpers["__pc_soldier_bone_golem_update_56"](entity, name, flip_x, ts, (times and (times > 1)), group)
	local idx
	local sprites = entity.render.sprites
	for i = 1, (# sprites) do
		if (sprites[i].group == group) then
			idx = i
			break
		end
	end
	if idx then
		while (not U.animation_finished(entity, idx, times)) do
			coroutine.yield()
		end
	end
end
__pc_helpers["__pc_soldier_bone_golem_update_56"] = function(entity, name, flip_x, ts, loop, group)
	if (not group) then
		U.animation_start(entity, name, flip_x, ts, loop)
		return
	end
	local sprites = entity.render.sprites
	do
		local i = 1
		local s = sprites[i]
		if (s.group == group) then
			__pc_helpers["__pc_enemy_abomination_update_31"](entity, name, flip_x, ts, loop, i)
		end
	end
	do
		local i = 2
		local s = sprites[i]
		if (s.group == group) then
			__pc_helpers["__pc_enemy_savage_bird_rider_update_39"](entity, name, flip_x, ts, loop, i)
		end
	end
end
__pc_helpers["__pc_soldier_bone_golem_update_73"] = function(store, this)
	if ((store.tick_ts - this.soldier.last_block_ts) < 0.1) then
		return false, A_NO_TARGET
	end
	local target = SU.soldier_pick_melee_target(store, this)
	if (not target) then
		this.soldier.last_block_ts = store.tick_ts
		return false, A_NO_TARGET
	end
	if SU.soldier_move_to_slot_step(store, this, target) then
		return true
	end
	local attack = SU.soldier_pick_melee_attack(store, this, target)
	if (not attack) then
		return false, A_IN_COOLDOWN
	end
	if attack.xp_from_skill then
		SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
	end
	local attack_done
	if attack.loops then
		attack_done = SU.y_soldier_do_loopable_melee_attack(store, this, target, attack)
	elseif (attack.type == "area") then
		attack_done = SU.y_soldier_do_single_area_attack(store, this, target, attack)
	else
		attack_done = __pc_helpers["__pc_soldier_bone_golem_update_82"](store, this, target, attack)
	end
	if attack_done then
		return false, A_DONE
	else
		return true
	end
end
__pc_helpers["__pc_soldier_bone_golem_update_82"] = function(store, this, target, attack)
	local attack_done = false
	local start_ts = store.tick_ts
	local an, af = __pc_helpers["__pc_soldier_amazona_update_44"](this, attack.animation, target.pos)
	U.animation_start_default(this, an, af, store.tick_ts, false)
	S:queue(attack.sound, attack.sound_args)
	while ((store.tick_ts - start_ts) < attack.hit_time) do
		if (SU.attack_interrupted(this, attack) or (((not attack.ignore_rally_change) and this.nav_rally) and this.nav_rally.new)) then
			goto label_72_0
		elseif SU.dodge_active(this) then
			this.render.sprites[1].alpha = 128
		end
		coroutine.yield()
	end
	S:queue(attack.sound_hit, attack.sound_hit_args)
	attack.ts = start_ts
	if attack.shared_cooldown then
		for _, aa in ipairs(this.melee.attacks) do
			if ((aa ~= attack) and aa.shared_cooldown) then
				aa.ts = attack.ts
			end
		end
	end
	if attack.forced_cooldown then
		this.melee.forced_ts = attack.ts
	end
	if attack.cooldown_group then
		for _, aa in ipairs(this.melee.attacks) do
			if ((aa ~= attack) and (aa.cooldown_group == attack.cooldown_group)) then
				aa.ts = attack.ts
			end
		end
	end
	if attack.signal then
		signal.emit("soldier-attack", this, attack, attack.signal)
	end
	if ((not __pc_helpers["__pc_enemy_abomination_update_32"](store, target, false, attack, this)) and table.arraycontains(target.enemy.blockers, this.id)) then
		if (((attack.damage_type ~= DAMAGE_NONE) and attack.fn_damage) or attack.damage_min) then
			local d = E.assign_damage(attack.damage_type, ((((((attack.fn_damage and attack.fn_damage(this, store, attack, target)) or math.random(attack.damage_min, attack.damage_max))) + this.unit.damage_buff)) * this.unit.damage_factor), this.id, target.id)
			d.xp_gain_factor = attack.xp_gain_factor
			d.xp_dest_id = attack.xp_dest_id
			d.track_kills = (this.track_kills ~= nil)
			d.track_damage = attack.track_damage
			d.pop = attack.pop
			d.pop_chance = attack.pop_chance
			d.pop_conds = attack.pop_conds
			queue_damage(store, d)
			if attack.side_effect then
				attack.side_effect(this, store, d, target)
			end
		end
		if attack.mod then
			if ((not attack.mod_chance) or (math.random() < attack.mod_chance)) then
				local mod = E:create_entity(attack.mod)
				mod.modifier.ts = store.tick_ts
				mod.modifier.target_id = target.id
				mod.modifier.source_id = this.id
				mod.modifier.level = attack.level
				mod.modifier.damage_factor = this.unit.damage_factor
				simulation:queue_insert_entity(mod)
			end
		end
		if attack.mods then
			if ((not attack.mod_chance) or (math.random() < attack.mod_chance)) then
				for _, m in ipairs(attack.mods) do
					local mod = E:create_entity(m)
					mod.modifier.ts = store.tick_ts
					mod.modifier.target_id = target.id
					mod.modifier.source_id = this.id
					mod.modifier.level = attack.level
					mod.modifier.damage_factor = this.unit.damage_factor
					simulation:queue_insert_entity(mod)
				end
			end
		end
		local hit_pos = V.vclone(this.pos)
		if attack.hit_offset then
			hit_pos.x = (hit_pos.x + ((((af and (- 1)) or 1)) * attack.hit_offset.x))
			hit_pos.y = (hit_pos.y + attack.hit_offset.y)
		end
		if attack.hit_aura then
			local a = E:create_entity(attack.hit_aura)
			a.pos = V.vclone(hit_pos)
			a.aura.target_id = target.id
			a.aura.source_id = this.id
			simulation:queue_insert_entity(a)
		end
		if attack.hit_fx then
			local fx = E:create_entity(attack.hit_fx)
			fx.pos = V.vclone(hit_pos)
			for i = 1, (# fx.render.sprites) do
				fx.render.sprites[i].ts = store.tick_ts
			end
			simulation:queue_insert_entity(fx)
		end
		if attack.hit_decal then
			local fx = E:create_entity(attack.hit_decal)
			fx.pos = V.vclone(hit_pos)
			for i = 1, (# fx.render.sprites) do
				fx.render.sprites[i].ts = store.tick_ts
			end
			simulation:queue_insert_entity(fx)
		end
	end
	if ((this.pickpocket and (not this.pickpocket.power_name)) and (math.random() < this.pickpocket.chance)) then
		local pi = this.pickpocket
		if (target.enemy and (target.enemy.gold_bag > 0)) then
			local q = km.clamp(0, target.enemy.gold_bag, math.floor((0.5 + U.frandom(pi.steal_min, pi.steal_max))))
			if (q > 0) then
				S:queue(this.pickpocket.sound)
				signal.emit("soldier-pickpocket", this, q)
			end
			target.enemy.gold_bag = (target.enemy.gold_bag - q)
			store.player_gold = (store.player_gold + q)
			if pi.fx then
				local fx = E:create_entity(pi.fx)
				fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
				fx.render.sprites[1].ts = store.tick_ts
				simulation:queue_insert_entity(fx)
			end
		end
	end
	attack_done = true
	while (not U.animation_finished_default(this)) do
		if (SU.attack_interrupted(this, attack) or (((not attack.ignore_rally_change) and this.nav_rally) and this.nav_rally.new)) then
			break
		elseif SU.dodge_active(this) then
			this.render.sprites[1].alpha = 128
		end
		coroutine.yield()
	end
	__pc_helpers["__pc_enemy_bat_update_15"](this, "idle", nil, store.tick_ts, true)
	::label_72_0::
	S:stop(attack.sound)
	if (SU.dodge_active(this) and (this.render.sprites[1].alpha == 128)) then
		this.render.sprites[1].alpha = 255
		this.dodge.active = false
	end
	return attack_done
end
__pc_helpers["__pc_soldier_deep_devils_chosen_update_1"] = function(entity, name, flip_x, ts, loop)
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if (not a.loop) then
					a.ts = ts
					a.runs = 0
				end
				do
					a.name = name
				end
			end
		end
	end
	do
		local i = 2
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if (not a.loop) then
					a.ts = ts
					a.runs = 0
				end
				do
					a.name = name
				end
			end
		end
	end
	do
		local i = 3
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if (not a.loop) then
					a.ts = ts
					a.runs = 0
				end
				do
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_soldier_deep_devils_chosen_update_17"] = function(entity, name, flip_x, ts, loop)
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if (not a.loop) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
	do
		local i = 2
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if (not a.loop) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
	do
		local i = 3
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if (not a.loop) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_soldier_deep_devils_chosen_update_21"] = function(store, this)
	U.unblock_target(store, this)
	local h = this.health
	if ((this.selfdestruct and (not this.selfdestruct.disabled)) and (band(h.last_damage_types, bor(DAMAGE_EAT, DAMAGE_HOST, DAMAGE_DISINTEGRATE)) == 0)) then
		local sd = this.selfdestruct
		this.unit.hide_after_death = true
		this.health_bar.hidden = true
		__pc_helpers["__pc_soldier_deep_devils_chosen_update_17"](this, sd.animation, nil, store.tick_ts)
		S:queue(this.sound_events.death, this.sound_events.death_args)
		S:queue(sd.sound, sd.sound_args)
		U.y_wait_unconditional(store, sd.hit_time)
		S:queue(sd.sound_hit)
		if sd.hit_fx then
			SU.insert_sprite(store, sd.hit_fx, this.pos)
		end
		local targets = U.find_enemies_in_range_filter_off(this.pos, sd.damage_radius, sd.vis_flags, sd.vis_bans)
		if targets then
			for _, t in ipairs(targets) do
				local d = E.assign_damage(sd.damage_type, ((((((sd.damage and sd.damage) or math.random(sd.damage_min, sd.damage_max))) + this.unit.damage_buff)) * this.unit.damage_factor), this.id, t.id)
				queue_damage(store, d)
				if sd.mod then
					local m = E:create_entity(sd.mod)
					m.modifier.target_id = t.id
					m.modifier.source_id = this.id
					m.modifier.damage_factor = this.unit.damage_factor
					simulation:queue_insert_entity(m)
				end
			end
		end
		U.y_animation_wait_default(this)
	elseif (band(h.last_damage_types, DAMAGE_DISINTEGRATE) ~= 0) then
		this.unit.hide_during_death = true
		local fx = E:create_entity("fx_soldier_desintegrate")
		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts
		simulation:queue_insert_entity(fx)
	elseif (band(h.last_damage_types, bor(DAMAGE_EAT)) ~= 0) then
		this.unit.hide_during_death = true
	elseif (band(h.last_damage_types, bor(DAMAGE_HOST)) ~= 0) then
		S:queue(this.sound_events.death_by_explosion)
		this.unit.hide_during_death = true
		local fx = E:create_entity("fx_unit_explode")
		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]
		simulation:queue_insert_entity(fx)
		if (this.unit.show_blood_pool and (this.unit.blood_color ~= BLOOD_NONE)) then
			local decal = E:create_entity("decal_blood_pool")
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			decal.render.sprites[1].name = this.unit.blood_color
			simulation:queue_insert_entity(decal)
		end
	elseif (this.reinforcement and (this.reinforcement.fade or this.reinforcement.fade_out)) then
		SU.y_reinforcement_fade_out(store, this)
		return
	else
		S:queue(this.sound_events.death, this.sound_events.death_args)
		__pc_helpers["__pc_soldier_deep_devils_chosen_update_31"](this, "death", nil, store.tick_ts, 1)
		this.ui.can_select = false
	end
	if this.ui then
		this.ui.can_click = (not this.unit.hide_after_death)
		this.ui.z = (- 1)
	end
	if (this.unit.hide_during_death or this.unit.hide_after_death) then
		for _, s in ipairs(this.render.sprites) do
			s.hidden = true
		end
	end
end
__pc_helpers["__pc_soldier_deep_devils_chosen_update_31"] = function(entity, name, flip_x, ts, times, idx)
	__pc_helpers["__pc_soldier_deep_devils_chosen_update_32"](entity, name, flip_x, ts, (times and (times > 1)), idx, true)
	local a = entity.render.sprites[(idx or 1)]
	times = ((a.loop and ((times or 1))) or 0)
	while (a.runs <= times) do
		coroutine.yield()
	end
end
__pc_helpers["__pc_soldier_deep_devils_chosen_update_32"] = function(entity, name, flip_x, ts, loop, idx, force_ts)
	local first, last
	if idx then
		first, last = idx, idx
	else
		first, last = 1, (# entity.render.sprites)
	end
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or true) then
					a.ts = ts
					a.runs = 0
				end
				do
					a.name = name
				end
			end
		end
	end
	do
		local i = 2
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or true) then
					a.ts = ts
					a.runs = 0
				end
				do
					a.name = name
				end
			end
		end
	end
	do
		local i = 3
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or true) then
					a.ts = ts
					a.runs = 0
				end
				do
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_soldier_deep_devils_chosen_update_33"] = function(this, store)
	if (((not this.revive) or (not this.revive.resist)) or this.revive.disabled) then
		return
	end
	local r = this.revive.resist
	if (this.revive.protect < r.cost) then
		return
	end
	local mods = U.find_modifiers_with_flags(this, r.bans)
	if ((not mods) or ((# mods) == 0)) then
		return
	end
	if ((not this.soldier.target_id) or (store.entities[this.soldier.target_id] == nil)) then
		local block_target = SU.soldier_pick_melee_target(store, this)
		if block_target then
			U.block_enemy(store, this, block_target)
		end
	end
	this.revive.protect = (this.revive.protect - r.cost)
	local clear_stun = false
	this.health.ignore_damage = true
	for _, m in ipairs(mods) do
		if (band(m.modifier.vis_flags, F_STUN) ~= 0) then
			clear_stun = true
		end
		m.modifier.removed_by_ban = true
	end
	local mod_ban = E:create_entity("mod_ban")
	mod_ban.modifier.ban_vis = r.bans
	mod_ban.modifier.target_id = this.id
	mod_ban.modifier.duration = r.duration
	simulation:queue_insert_entity(mod_ban)
	if this.revive.animation then
		S:queue(this.revive.sound)
		__pc_helpers["__pc_soldier_deep_devils_chosen_update_17"](this, this.revive.animation, nil, store.tick_ts, false)
		this.revive.ts = store.tick_ts
	end
	for _, m in ipairs(mods) do
		while store.entities[m.id] do
			m.modifier.ts = (- 10000)
			m.modifier.duration = 0.01
			coroutine.yield()
		end
	end
	if this.revive.fx then
		local fx = E:create_entity(this.revive.fx)
		fx.pos = this.pos
		fx.render.sprites[1].ts = store.tick_ts
		simulation:queue_insert_entity(fx)
	end
	if this.revive.animation then
		while (not U.animation_finished_default(this)) do
			coroutine.yield()
		end
	end
	do
		this.unit.is_stunned = nil
	end
	this.health.ignore_damage = false
	if r.side_effect then
		r.side_effect(this, store)
	end
end
__pc_helpers["__pc_soldier_deep_devils_chosen_update_39"] = function(store, this, force_ts)
	__pc_helpers["__pc_soldier_deep_devils_chosen_update_40"](this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, force_ts)
	if this.unit.is_stunned then
		return
	end
	if ((store.tick_ts - this.idle_flip.ts) > (2 * store.tick_length)) then
		this.idle_flip.ts_counter = 0
	end
	this.idle_flip.ts = store.tick_ts
	this.idle_flip.ts_counter = (this.idle_flip.ts_counter + store.tick_length)
	if (this.idle_flip.ts_counter > this.idle_flip.cooldown) then
		this.idle_flip.ts_counter = 0
		if (math.random() < this.idle_flip.chance) then
			do
				local i = 1
				this.render.sprites[i].flip_x = (not this.render.sprites[i].flip_x)
			end
			do
				local i = 2
				this.render.sprites[i].flip_x = (not this.render.sprites[i].flip_x)
			end
			do
				local i = 3
				this.render.sprites[i].flip_x = (not this.render.sprites[i].flip_x)
			end
		end
		if this.idle_flip.animations then
			this.idle_flip.last_animation = table.random(this.idle_flip.animations)
		end
	end
end
__pc_helpers["__pc_soldier_deep_devils_chosen_update_40"] = function(entity, name, flip_x, ts, loop, idx, force_ts)
	local first, last
	do
		first, last = 1, (# entity.render.sprites)
	end
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or force_ts) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
	do
		local i = 2
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or force_ts) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
	do
		local i = 3
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or force_ts) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_soldier_deep_devils_chosen_update_43"] = function(store, this)
	local r = this.nav_rally
	local out = false
	local prev_immune = this.health.immune_to
	this.health.immune_to = r.immune_to
	U.bans_add(this.vis, F_ALL)
	if r.new then
		r.new = false
		U.unblock_target(store, this)
		U.set_destination(this, r.pos)
		local an, af = __pc_helpers["__pc_soldier_amazona_update_44"](this, "walk", this.motion.dest)
		__pc_helpers["__pc_soldier_deep_devils_chosen_update_45"](this, an, af, store.tick_ts, true, nil, true)
		while (not this.motion.arrived) do
			if (this.health.dead or this.unit.is_stunned) then
				out = true
				break
			end
			if r.new then
				out = false
				break
			end
			U.walk_off__accel__unsnapped(this, store.tick_length)
			coroutine.yield()
			this.motion.speed.x, this.motion.speed.y = 0, 0
		end
	end
	U.bans_remove(this.vis, F_ALL)
	this.health.immune_to = prev_immune
	return out
end
__pc_helpers["__pc_soldier_deep_devils_chosen_update_45"] = function(entity, name, flip_x, ts, loop, idx, force_ts)
	local first, last
	do
		first, last = 1, (# entity.render.sprites)
	end
	do
		local i = 1
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if (flip_x ~= nil) then
				a.flip_x = flip_x
			end
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or true) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
	do
		local i = 2
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if (flip_x ~= nil) then
				a.flip_x = flip_x
			end
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or true) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
	do
		local i = 3
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if (flip_x ~= nil) then
				a.flip_x = flip_x
			end
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or true) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_soldier_deep_devils_chosen_update_56"] = function(store, this)
	local target, attack, pred_pos = SU.soldier_pick_ranged_target_and_attack(store, this)
	if (not target) then
		return false, A_NO_TARGET
	end
	if (not attack) then
		return false, A_IN_COOLDOWN
	end
	local start_ts = store.tick_ts
	local attack_done
	if attack.loops then
		attack_done = __pc_helpers["__pc_soldier_deep_devils_chosen_update_58"](store, this, target, attack)
	else
		attack_done = SU.y_soldier_do_ranged_attack(store, this, target, attack, pred_pos)
	end
	if attack_done then
		attack.ts = start_ts
		if attack.shared_cooldown then
			for _, aa in ipairs(this.ranged.attacks) do
				if ((aa ~= attack) and aa.shared_cooldown) then
					aa.ts = attack.ts
				end
			end
		end
		if this.ranged.forced_cooldown then
			this.ranged.forced_ts = start_ts
		end
	end
	if attack_done then
		return false, A_DONE
	else
		return true
	end
end
__pc_helpers["__pc_soldier_deep_devils_chosen_update_58"] = function(store, this, target, attack)
	local attack_done = false
	local b, an, af, ai
	S:queue(attack.sound, attack.sound_args)
	if attack.animations[1] then
		an, af, ai = __pc_helpers["__pc_soldier_amazona_update_44"](this, attack.animations[1], target.pos)
		__pc_helpers["__pc_soldier_deep_devils_chosen_update_59"](this, an, af, store.tick_ts, 1, attack.sprite_group)
	end
	for i = 1, attack.loops do
		an, af, ai = __pc_helpers["__pc_soldier_amazona_update_44"](this, attack.animations[2], target.pos)
		__pc_helpers["__pc_soldier_deep_devils_chosen_update_62"](this, an, af, store.tick_ts, false, attack.sprite_group)
		for si, st in ipairs(attack.shoot_times) do
			while (st > (store.tick_ts - U.get_animation_ts(this, attack.sprite_group))) do
				if this.unit.is_stunned then
					goto label_59_0
				end
				if (this.health.dead or (this.nav_rally and this.nav_rally.new)) then
					goto label_59_1
				end
				coroutine.yield()
			end
			b = E:create_entity(attack.bullet)
			b.pos:copy(this.pos)
			if attack.bullet_start_offset then
				local offset = attack.bullet_start_offset[ai]
				b.pos.x, b.pos.y = (b.pos.x + ((((af and (- 1)) or 1)) * offset.x)), (b.pos.y + offset.y)
			end
			if attack.bullet_shot_start_offset then
				local offset = attack.bullet_shot_start_offset[si]
				b.pos.x, b.pos.y = (b.pos.x + ((((af and (- 1)) or 1)) * offset.x)), (b.pos.y + offset.y)
			end
			b.bullet.from:copy(b.pos)
			b.bullet.to:set((target.pos.x + target.unit.hit_offset.x), (target.pos.y + target.unit.hit_offset.y))
			b.bullet.target_id = target.id
			b.bullet.shot_index = si
			b.bullet.loop_index = i
			b.bullet.source_id = this.id
			b.bullet.xp_dest_id = this.id
			b.bullet.damage_factor = this.unit.damage_factor
			b.bullet.damage_max = (b.bullet.damage_max + this.unit.damage_buff)
			b.bullet.damage_min = (b.bullet.damage_min + this.unit.damage_buff)
			b.bullet.level = attack.level
			simulation:queue_insert_entity(b)
			if attack.xp_from_skill then
				SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
			end
			if attack.check_target_before_shot then
				if (target.health.dead or ((target.health.hp - U.predict_damage(target, SU.create_bullet_damage_without_pops(b.bullet, target.id, b.id))) < 0)) then
					local new_target = U.detect_foremost_enemy_between_range_filter_on(target.pos, attack.min_range, attack.max_range, attack.vis_flags, attack.vis_bans, function(e)
	return ((e.id ~= target.id) and (((not attack.filter_fn) or attack.filter_fn(e))))
end)
					if new_target then
						target = new_target
					end
				end
			end
			attack_done = true
		end
		while (not U.animation_finished_group(this, attack.sprite_group)) do
			if this.unit.is_stunned then
				goto label_59_0
			end
			if (this.health.dead or (this.nav_rally and this.nav_rally.new)) then
				goto label_59_1
			end
			coroutine.yield()
		end
	end
	::label_59_0::
	if attack.animations[3] then
		an, af, ai = __pc_helpers["__pc_soldier_amazona_update_44"](this, attack.animations[3], target.pos)
		__pc_helpers["__pc_soldier_deep_devils_chosen_update_62"](this, an, af, store.tick_ts, false, attack.sprite_group)
		while (not U.animation_finished_group(this, attack.sprite_group)) do
			if (this.health.dead or (this.nav_rally and this.nav_rally.new)) then
				break
			end
			coroutine.yield()
		end
	end
	::label_59_1::
	if attack.xp_from_skill_once then
		SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill_once])
	end
	return attack_done
end
__pc_helpers["__pc_soldier_deep_devils_chosen_update_59"] = function(entity, name, flip_x, ts, times, group)
	if (not group) then
		U.y_animation_play(entity, name, flip_x, ts, times)
		return
	end
	__pc_helpers["__pc_soldier_deep_devils_chosen_update_62"](entity, name, flip_x, ts, (times and (times > 1)), group)
	local idx
	local sprites = entity.render.sprites
	for i = 1, (# sprites) do
		if (sprites[i].group == group) then
			idx = i
			break
		end
	end
	if idx then
		while (not U.animation_finished(entity, idx, times)) do
			coroutine.yield()
		end
	end
end
__pc_helpers["__pc_soldier_deep_devils_chosen_update_62"] = function(entity, name, flip_x, ts, loop, group)
	if (not group) then
		U.animation_start(entity, name, flip_x, ts, loop)
		return
	end
	local sprites = entity.render.sprites
	do
		local i = 1
		local s = sprites[i]
		if (s.group == group) then
			__pc_helpers["__pc_enemy_abomination_update_31"](entity, name, flip_x, ts, loop, i)
		end
	end
	do
		local i = 2
		local s = sprites[i]
		if (s.group == group) then
			__pc_helpers["__pc_enemy_savage_bird_rider_update_39"](entity, name, flip_x, ts, loop, i)
		end
	end
	do
		local i = 3
		local s = sprites[i]
		if (s.group == group) then
			__pc_helpers["__pc_soldier_deep_devils_chosen_update_66"](entity, name, flip_x, ts, loop, i)
		end
	end
end
__pc_helpers["__pc_soldier_deep_devils_chosen_update_66"] = function(entity, name, flip_x, ts, loop, idx, force_ts)
	local first, last
	do
		first, last = idx, idx
	end
	do
		local i = 3
		local a = entity.render.sprites[i]
		if (not a.ignore_start) then
			if (flip_x ~= nil) then
				a.flip_x = flip_x
			end
			if a.animated then
				a.loop = (loop or (a.loop_forced == true))
				if ((not a.loop) or force_ts) then
					a.ts = ts
					a.runs = 0
				end
				if name then
					a.name = name
				end
			end
		end
	end
end
__pc_helpers["__pc_soldier_deep_devils_chosen_update_81"] = function(store, this)
	if ((store.tick_ts - this.soldier.last_block_ts) < 0.1) then
		return false, A_NO_TARGET
	end
	local target = SU.soldier_pick_melee_target(store, this)
	if (not target) then
		this.soldier.last_block_ts = store.tick_ts
		return false, A_NO_TARGET
	end
	if SU.soldier_move_to_slot_step(store, this, target) then
		return true
	end
	local attack = SU.soldier_pick_melee_attack(store, this, target)
	if (not attack) then
		return false, A_IN_COOLDOWN
	end
	if attack.xp_from_skill then
		SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
	end
	local attack_done
	if attack.loops then
		attack_done = SU.y_soldier_do_loopable_melee_attack(store, this, target, attack)
	elseif (attack.type == "area") then
		attack_done = SU.y_soldier_do_single_area_attack(store, this, target, attack)
	else
		attack_done = __pc_helpers["__pc_soldier_deep_devils_chosen_update_90"](store, this, target, attack)
	end
	if attack_done then
		return false, A_DONE
	else
		return true
	end
end
__pc_helpers["__pc_soldier_deep_devils_chosen_update_9"] = function(store, this)
	if ((((not this.revive) or this.revive.disabled) or this.unit.is_stunned) or (band(this.health.last_damage_types, bor(DAMAGE_DISINTEGRATE, DAMAGE_EAT)) ~= 0)) then
		return false
	end
	local r = this.revive
	local chance = (r.chance + r.protect)
	if (math.random() < chance) then
		local r = this.revive
		r.protect = (r.protect * 0.5)
		if r.remove_modifiers then
			SU.remove_modifiers(store, this)
		end
		this.health.ignore_damage = true
		this.health.dead = false
		this.health_bar.hidden = false
		if this.soldier.target_id then
			local enemy = store.entities[this.soldier.target_id]
			if enemy then
				U.block_enemy(store, this, enemy)
			end
		end
		if r.fx then
			local fx = E:create_entity(r.fx)
			fx.pos = this.pos
			fx.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(fx)
		end
		if r.animation then
			S:queue(r.sound)
			__pc_helpers["__pc_soldier_deep_devils_chosen_update_17"](this, r.animation, nil, store.tick_ts, false)
			r.ts = store.tick_ts
			while ((store.tick_ts - r.ts) < r.hit_time) do
				coroutine.yield()
			end
		end
		r.revive_count = (((r.revive_count or 0)) + 1)
		signal.emit("entity-revived", this, r.revive_count)
		U.heal(this, (this.health.hp_max * r.health_recover))
		if r.animation then
			while (not U.animation_finished_default(this)) do
				coroutine.yield()
			end
		end
		this.health.ignore_damage = false
		return true
	end
	return false
end
__pc_helpers["__pc_soldier_deep_devils_chosen_update_90"] = function(store, this, target, attack)
	local attack_done = false
	local start_ts = store.tick_ts
	local an, af = __pc_helpers["__pc_soldier_amazona_update_44"](this, attack.animation, target.pos)
	U.animation_start_default(this, an, af, store.tick_ts, false)
	S:queue(attack.sound, attack.sound_args)
	while ((store.tick_ts - start_ts) < attack.hit_time) do
		if (SU.attack_interrupted(this, attack) or (((not attack.ignore_rally_change) and this.nav_rally) and this.nav_rally.new)) then
			goto label_72_0
		elseif SU.dodge_active(this) then
			this.render.sprites[1].alpha = 128
		end
		coroutine.yield()
	end
	S:queue(attack.sound_hit, attack.sound_hit_args)
	attack.ts = start_ts
	if attack.shared_cooldown then
		for _, aa in ipairs(this.melee.attacks) do
			if ((aa ~= attack) and aa.shared_cooldown) then
				aa.ts = attack.ts
			end
		end
	end
	if attack.forced_cooldown then
		this.melee.forced_ts = attack.ts
	end
	if attack.cooldown_group then
		for _, aa in ipairs(this.melee.attacks) do
			if ((aa ~= attack) and (aa.cooldown_group == attack.cooldown_group)) then
				aa.ts = attack.ts
			end
		end
	end
	if attack.signal then
		signal.emit("soldier-attack", this, attack, attack.signal)
	end
	if ((not __pc_helpers["__pc_enemy_abomination_update_32"](store, target, false, attack, this)) and table.arraycontains(target.enemy.blockers, this.id)) then
		if (((attack.damage_type ~= DAMAGE_NONE) and attack.fn_damage) or attack.damage_min) then
			local d = E.assign_damage(attack.damage_type, ((((((attack.fn_damage and attack.fn_damage(this, store, attack, target)) or math.random(attack.damage_min, attack.damage_max))) + this.unit.damage_buff)) * this.unit.damage_factor), this.id, target.id)
			d.xp_gain_factor = attack.xp_gain_factor
			d.xp_dest_id = attack.xp_dest_id
			d.track_kills = (this.track_kills ~= nil)
			d.track_damage = attack.track_damage
			d.pop = attack.pop
			d.pop_chance = attack.pop_chance
			d.pop_conds = attack.pop_conds
			queue_damage(store, d)
			if attack.side_effect then
				attack.side_effect(this, store, d, target)
			end
		end
		if attack.mod then
			if ((not attack.mod_chance) or (math.random() < attack.mod_chance)) then
				local mod = E:create_entity(attack.mod)
				mod.modifier.ts = store.tick_ts
				mod.modifier.target_id = target.id
				mod.modifier.source_id = this.id
				mod.modifier.level = attack.level
				mod.modifier.damage_factor = this.unit.damage_factor
				simulation:queue_insert_entity(mod)
			end
		end
		if attack.mods then
			if ((not attack.mod_chance) or (math.random() < attack.mod_chance)) then
				for _, m in ipairs(attack.mods) do
					local mod = E:create_entity(m)
					mod.modifier.ts = store.tick_ts
					mod.modifier.target_id = target.id
					mod.modifier.source_id = this.id
					mod.modifier.level = attack.level
					mod.modifier.damage_factor = this.unit.damage_factor
					simulation:queue_insert_entity(mod)
				end
			end
		end
		local hit_pos = V.vclone(this.pos)
		if attack.hit_offset then
			hit_pos.x = (hit_pos.x + ((((af and (- 1)) or 1)) * attack.hit_offset.x))
			hit_pos.y = (hit_pos.y + attack.hit_offset.y)
		end
		if attack.hit_aura then
			local a = E:create_entity(attack.hit_aura)
			a.pos = V.vclone(hit_pos)
			a.aura.target_id = target.id
			a.aura.source_id = this.id
			simulation:queue_insert_entity(a)
		end
		if attack.hit_fx then
			local fx = E:create_entity(attack.hit_fx)
			fx.pos = V.vclone(hit_pos)
			for i = 1, (# fx.render.sprites) do
				fx.render.sprites[i].ts = store.tick_ts
			end
			simulation:queue_insert_entity(fx)
		end
		if attack.hit_decal then
			local fx = E:create_entity(attack.hit_decal)
			fx.pos = V.vclone(hit_pos)
			for i = 1, (# fx.render.sprites) do
				fx.render.sprites[i].ts = store.tick_ts
			end
			simulation:queue_insert_entity(fx)
		end
	end
	if ((this.pickpocket and ((not this.pickpocket.power_name) or (this.powers[this.pickpocket.power_name].level > 0))) and (math.random() < this.pickpocket.chance)) then
		local pi = this.pickpocket
		if (target.enemy and (target.enemy.gold_bag > 0)) then
			local q = km.clamp(0, target.enemy.gold_bag, math.floor((0.5 + U.frandom(pi.steal_min, pi.steal_max))))
			if (q > 0) then
				S:queue(this.pickpocket.sound)
				signal.emit("soldier-pickpocket", this, q)
			end
			target.enemy.gold_bag = (target.enemy.gold_bag - q)
			store.player_gold = (store.player_gold + q)
			if pi.fx then
				local fx = E:create_entity(pi.fx)
				fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
				fx.render.sprites[1].ts = store.tick_ts
				simulation:queue_insert_entity(fx)
			end
		end
	end
	attack_done = true
	while (not U.animation_finished_default(this)) do
		if (SU.attack_interrupted(this, attack) or (((not attack.ignore_rally_change) and this.nav_rally) and this.nav_rally.new)) then
			break
		elseif SU.dodge_active(this) then
			this.render.sprites[1].alpha = 128
		end
		coroutine.yield()
	end
	__pc_helpers["__pc_soldier_deep_devils_chosen_update_1"](this, "idle", nil, store.tick_ts, true)
	::label_72_0::
	S:stop(attack.sound)
	if (SU.dodge_active(this) and (this.render.sprites[1].alpha == 128)) then
		this.render.sprites[1].alpha = 255
		this.dodge.active = false
	end
	return attack_done
end
__pc_helpers["__pc_soldier_swamp_monster_update_56"] = function(store, this)
	if ((store.tick_ts - this.soldier.last_block_ts) < 0.1) then
		return false, A_NO_TARGET
	end
	local target = SU.soldier_pick_melee_target(store, this)
	if (not target) then
		this.soldier.last_block_ts = store.tick_ts
		return false, A_NO_TARGET
	end
	if SU.soldier_move_to_slot_step(store, this, target) then
		return true
	end
	local attack = SU.soldier_pick_melee_attack(store, this, target)
	if (not attack) then
		return false, A_IN_COOLDOWN
	end
	if attack.xp_from_skill then
		SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
	end
	local attack_done
	if attack.loops then
		attack_done = SU.y_soldier_do_loopable_melee_attack(store, this, target, attack)
	elseif (attack.type == "area") then
		attack_done = SU.y_soldier_do_single_area_attack(store, this, target, attack)
	else
		attack_done = __pc_helpers["__pc_soldier_swamp_monster_update_69"](store, this, target, attack)
	end
	if attack_done then
		return false, A_DONE
	else
		return true
	end
end
__pc_helpers["__pc_soldier_swamp_monster_update_69"] = function(store, this, target, attack)
	local attack_done = false
	local start_ts = store.tick_ts
	local an, af = __pc_helpers["__pc_soldier_amazona_update_44"](this, attack.animation, target.pos)
	U.animation_start_default(this, an, af, store.tick_ts, false)
	S:queue(attack.sound, attack.sound_args)
	while ((store.tick_ts - start_ts) < attack.hit_time) do
		if (SU.attack_interrupted(this, attack) or (((not attack.ignore_rally_change) and this.nav_rally) and this.nav_rally.new)) then
			goto label_72_0
		elseif SU.dodge_active(this) then
			this.render.sprites[1].alpha = 128
		end
		coroutine.yield()
	end
	S:queue(attack.sound_hit, attack.sound_hit_args)
	attack.ts = start_ts
	if attack.shared_cooldown then
		for _, aa in ipairs(this.melee.attacks) do
			if ((aa ~= attack) and aa.shared_cooldown) then
				aa.ts = attack.ts
			end
		end
	end
	if attack.forced_cooldown then
		this.melee.forced_ts = attack.ts
	end
	if attack.cooldown_group then
		for _, aa in ipairs(this.melee.attacks) do
			if ((aa ~= attack) and (aa.cooldown_group == attack.cooldown_group)) then
				aa.ts = attack.ts
			end
		end
	end
	if attack.signal then
		signal.emit("soldier-attack", this, attack, attack.signal)
	end
	if ((not __pc_helpers["__pc_enemy_abomination_update_32"](store, target, false, attack, this)) and table.arraycontains(target.enemy.blockers, this.id)) then
		if (((attack.damage_type ~= DAMAGE_NONE) and attack.fn_damage) or attack.damage_min) then
			local d = E.assign_damage(attack.damage_type, ((((((attack.fn_damage and attack.fn_damage(this, store, attack, target)) or math.random(attack.damage_min, attack.damage_max))) + this.unit.damage_buff)) * this.unit.damage_factor), this.id, target.id)
			d.xp_gain_factor = attack.xp_gain_factor
			d.xp_dest_id = attack.xp_dest_id
			d.track_kills = (this.track_kills ~= nil)
			d.track_damage = attack.track_damage
			d.pop = attack.pop
			d.pop_chance = attack.pop_chance
			d.pop_conds = attack.pop_conds
			queue_damage(store, d)
			if attack.side_effect then
				attack.side_effect(this, store, d, target)
			end
		end
		if attack.mod then
			if ((not attack.mod_chance) or (math.random() < attack.mod_chance)) then
				local mod = E:create_entity(attack.mod)
				mod.modifier.ts = store.tick_ts
				mod.modifier.target_id = target.id
				mod.modifier.source_id = this.id
				mod.modifier.level = attack.level
				mod.modifier.damage_factor = this.unit.damage_factor
				simulation:queue_insert_entity(mod)
			end
		end
		if attack.mods then
			if ((not attack.mod_chance) or (math.random() < attack.mod_chance)) then
				for _, m in ipairs(attack.mods) do
					local mod = E:create_entity(m)
					mod.modifier.ts = store.tick_ts
					mod.modifier.target_id = target.id
					mod.modifier.source_id = this.id
					mod.modifier.level = attack.level
					mod.modifier.damage_factor = this.unit.damage_factor
					simulation:queue_insert_entity(mod)
				end
			end
		end
		local hit_pos = V.vclone(this.pos)
		if attack.hit_offset then
			hit_pos.x = (hit_pos.x + ((((af and (- 1)) or 1)) * attack.hit_offset.x))
			hit_pos.y = (hit_pos.y + attack.hit_offset.y)
		end
		if attack.hit_aura then
			local a = E:create_entity(attack.hit_aura)
			a.pos = V.vclone(hit_pos)
			a.aura.target_id = target.id
			a.aura.source_id = this.id
			simulation:queue_insert_entity(a)
		end
		if attack.hit_fx then
			local fx = E:create_entity(attack.hit_fx)
			fx.pos = V.vclone(hit_pos)
			for i = 1, (# fx.render.sprites) do
				fx.render.sprites[i].ts = store.tick_ts
			end
			simulation:queue_insert_entity(fx)
		end
		if attack.hit_decal then
			local fx = E:create_entity(attack.hit_decal)
			fx.pos = V.vclone(hit_pos)
			for i = 1, (# fx.render.sprites) do
				fx.render.sprites[i].ts = store.tick_ts
			end
			simulation:queue_insert_entity(fx)
		end
	end
	if ((this.pickpocket and ((not this.pickpocket.power_name) or (this.powers[this.pickpocket.power_name].level > 0))) and (math.random() < this.pickpocket.chance)) then
		local pi = this.pickpocket
		if (target.enemy and (target.enemy.gold_bag > 0)) then
			local q = km.clamp(0, target.enemy.gold_bag, math.floor((0.5 + U.frandom(pi.steal_min, pi.steal_max))))
			if (q > 0) then
				S:queue(this.pickpocket.sound)
				signal.emit("soldier-pickpocket", this, q)
			end
			target.enemy.gold_bag = (target.enemy.gold_bag - q)
			store.player_gold = (store.player_gold + q)
			if pi.fx then
				local fx = E:create_entity(pi.fx)
				fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
				fx.render.sprites[1].ts = store.tick_ts
				simulation:queue_insert_entity(fx)
			end
		end
	end
	attack_done = true
	while (not U.animation_finished_default(this)) do
		if (SU.attack_interrupted(this, attack) or (((not attack.ignore_rally_change) and this.nav_rally) and this.nav_rally.new)) then
			break
		elseif SU.dodge_active(this) then
			this.render.sprites[1].alpha = 128
		end
		coroutine.yield()
	end
	__pc_helpers["__pc_enemy_bat_update_15"](this, "idle", nil, store.tick_ts, true)
	::label_72_0::
	S:stop(attack.sound)
	if (SU.dodge_active(this) and (this.render.sprites[1].alpha == 128)) then
		this.render.sprites[1].alpha = 255
		this.dodge.active = false
	end
	return attack_done
end
return {
	[1] = function(this, store)
	do
		this.melee.order = U.attack_order(this.melee.attacks)
	end
	do
		do
			local i = 1
			local a = this.auras.list[i]
			if (a.cooldown == 0) then
				local e = E:create_entity(a.name)
				e.pos.x = this.pos.x
				e.pos.y = this.pos.y
				e.aura.level = this.unit.level
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts
				simulation:queue_insert_entity(e)
			end
		end
	end
	if (this.info and this.info.random_name_format) then
		this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""), math.random(this.info.random_name_count))
	end
	U.bans_add(this.vis, F_ALL)
	this.vis._bans_added = true
	do
		do
			local i = 1
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
	end
	return true
end
,
	[2] = function(this, store)
	do
		this.melee.order = U.attack_order(this.melee.attacks)
	end
	do
		for pn, p in pairs(this.powers) do
			__pc_helpers["__pc_soldier_amazona_insert_2"](this, pn)
		end
	end
	if (this.info and this.info.random_name_format) then
		this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""), math.random(this.info.random_name_count))
	end
	U.bans_add(this.vis, F_ALL)
	this.vis._bans_added = true
	do
		do
			local i = 1
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
		do
			local i = 2
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
		do
			local i = 3
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
	end
	return true
end
,
	[3] = function(this, store)
	do
		this.melee.order = U.attack_order(this.melee.attacks)
	end
	do
		for pn, p in pairs(this.powers) do
			__pc_helpers["__pc_soldier_amazona_insert_2"](this, pn)
		end
	end
	if (this.info and this.info.random_name_format) then
		this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""), math.random(this.info.random_name_count))
	end
	U.bans_add(this.vis, F_ALL)
	this.vis._bans_added = true
	do
		do
			local i = 1
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
	end
	return true
end
,
	[4] = function(this, store)
	do
		this.melee.order = U.attack_order(this.melee.attacks)
	end
	do
		this.ranged.order = U.attack_order(this.ranged.attacks)
	end
	do
		do
			local i = 1
			local a = this.auras.list[i]
			if (a.cooldown == 0) then
				local e = E:create_entity(a.name)
				e.pos.x = this.pos.x
				e.pos.y = this.pos.y
				e.aura.level = this.unit.level
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts
				simulation:queue_insert_entity(e)
			end
		end
	end
	if (this.info and this.info.random_name_format) then
		this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""), math.random(this.info.random_name_count))
	end
	U.bans_add(this.vis, F_ALL)
	this.vis._bans_added = true
	do
		do
			local i = 1
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
	end
	return true
end
,
	[5] = function(this, store)
	do
		this.melee.order = U.attack_order(this.melee.attacks)
	end
	do
		this.ranged.order = U.attack_order(this.ranged.attacks)
	end
	do
		for pn, p in pairs(this.powers) do
			__pc_helpers["__pc_soldier_arborean_sentinels_spearmen_insert_3"](this, pn)
		end
	end
	if (this.info and this.info.random_name_format) then
		this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""), math.random(this.info.random_name_count))
	end
	U.bans_add(this.vis, F_ALL)
	this.vis._bans_added = true
	do
		do
			local i = 1
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
		do
			local i = 2
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
		do
			local i = 3
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
	end
	return true
end
,
	[6] = function(this, store)
	do
		this.melee.order = U.attack_order(this.melee.attacks)
	end
	do
		this.ranged.order = U.attack_order(this.ranged.attacks)
	end
	do
		for pn, p in pairs(this.powers) do
			__pc_helpers["__pc_soldier_arborean_sentinels_spearmen_insert_3"](this, pn)
		end
	end
	if (this.info and this.info.random_name_format) then
		this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""), math.random(this.info.random_name_count))
	end
	U.bans_add(this.vis, F_ALL)
	this.vis._bans_added = true
	do
		do
			local i = 1
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
		do
			local i = 2
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
	end
	return true
end
,
	[7] = function(this, store)
	do
		this.melee.order = U.attack_order(this.melee.attacks)
	end
	do
		this.ranged.order = U.attack_order(this.ranged.attacks)
	end
	do
		for pn, p in pairs(this.powers) do
			__pc_helpers["__pc_soldier_arborean_sentinels_spearmen_insert_3"](this, pn)
		end
	end
	if (this.info and this.info.random_name_format) then
		this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""), math.random(this.info.random_name_count))
	end
	U.bans_add(this.vis, F_ALL)
	this.vis._bans_added = true
	do
		do
			local i = 1
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
	end
	return true
end
,
	[8] = function(this, store)
	do
		this.melee.order = U.attack_order(this.melee.attacks)
	end
	do
		this.ranged.order = U.attack_order(this.ranged.attacks)
	end
	if (this.info and this.info.random_name_format) then
		this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""), math.random(this.info.random_name_count))
	end
	U.bans_add(this.vis, F_ALL)
	this.vis._bans_added = true
	do
		do
			local i = 1
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
		do
			local i = 2
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
	end
	return true
end
,
	[9] = function(this, store)
	do
		this.melee.order = U.attack_order(this.melee.attacks)
	end
	do
		this.ranged.order = U.attack_order(this.ranged.attacks)
	end
	if (this.info and this.info.random_name_format) then
		this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""), math.random(this.info.random_name_count))
	end
	U.bans_add(this.vis, F_ALL)
	this.vis._bans_added = true
	do
		do
			local i = 1
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
	end
	return true
end
,
	[10] = function(this, store)
	do
		this.melee.order = U.attack_order(this.melee.attacks)
	end
	do
	end
	if this.track_kills.mod then
		local mod_name = this.track_kills.mod
		local m = E:create_entity(mod_name)
		m.modifier.target_id = this.id
		m.modifier.source_id = this.id
		m.pos.x = this.pos.x
		m.pos.y = this.pos.y
		simulation:queue_insert_entity(m)
	end
	do
		for pn, p in pairs(this.powers) do
			__pc_helpers["__pc_soldier_amazona_insert_2"](this, pn)
		end
	end
	if (this.info and this.info.random_name_format) then
		this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""), math.random(this.info.random_name_count))
	end
	U.bans_add(this.vis, F_ALL)
	this.vis._bans_added = true
	do
		do
			local i = 1
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
	end
	return true
end
,
	[11] = function(this, store)
	do
		this.melee.order = U.attack_order(this.melee.attacks)
	end
	if (this.info and this.info.random_name_format) then
		this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""), math.random(this.info.random_name_count))
	end
	U.bans_add(this.vis, F_ALL)
	this.vis._bans_added = true
	do
		do
			local i = 1
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
		do
			local i = 2
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
	end
	return true
end
,
	[12] = function(this, store)
	do
		this.melee.order = U.attack_order(this.melee.attacks)
	end
	if (this.info and this.info.random_name_format) then
		this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""), math.random(this.info.random_name_count))
	end
	U.bans_add(this.vis, F_ALL)
	this.vis._bans_added = true
	do
		do
			local i = 1
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
	end
	return true
end
,
	[13] = function(this, store)
	do
		this.melee.order = U.attack_order(this.melee.attacks)
	end
	if this.track_kills.mod then
		local mod_name = this.track_kills.mod
		local m = E:create_entity(mod_name)
		m.modifier.target_id = this.id
		m.modifier.source_id = this.id
		m.pos.x = this.pos.x
		m.pos.y = this.pos.y
		simulation:queue_insert_entity(m)
	end
	do
		for pn, p in pairs(this.powers) do
			__pc_helpers["__pc_soldier_amazona_insert_2"](this, pn)
		end
	end
	if (this.info and this.info.random_name_format) then
		this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""), math.random(this.info.random_name_count))
	end
	U.bans_add(this.vis, F_ALL)
	this.vis._bans_added = true
	do
		do
			local i = 1
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
		do
			local i = 2
			this.render.sprites[i].ts = (store.tick_ts - U.frandom(0, 1))
		end
	end
	return true
end
,
	[14] = function(this, store)
	if (this.render.sprites[1].name == "raise") then
		if this.sound_events.raise then
			S:queue(this.sound_events.raise, this.sound_events.raise_args)
		end
		this.health_bar.hidden = true
		local an, af = U.animation_name_facing_point(this, "raise", this.motion.dest)
		U.y_animation_play(this, an, af, store.tick_ts, 1)
		if (not this.health.dead) then
			this.health_bar.hidden = nil
		end
	end
	::label_25_0::
	while true do
		if this.health.dead then
			__pc_helpers["__pc_enemy_abomination_update_4"](store, this)
			return
		end
		if this.unit.is_stunned then
			__pc_helpers["__pc_enemy_abomination_update_15"](store, this)
		else
			local cont, blocker = __pc_helpers["__pc_enemy_abomination_update_17"](store, this)
			if cont then
				if blocker then
					if (not SU.y_wait_for_blocker(store, this, blocker)) then
						goto label_25_0
					end
					while SU.can_melee_blocker(store, this, blocker) do
						if (not __pc_helpers["__pc_enemy_abomination_update_29"](store, this, blocker)) then
							goto label_25_0
						end
						coroutine.yield()
					end
				end
				coroutine.yield()
			end
		end
	end
end
,
	[15] = function(this, store)
	if (this.render.sprites[1].name == "raise") then
		if this.sound_events.raise then
			S:queue(this.sound_events.raise, this.sound_events.raise_args)
		end
		this.health_bar.hidden = true
		local an, af = U.animation_name_facing_point(this, "raise", this.motion.dest)
		U.y_animation_play(this, an, af, store.tick_ts, 1)
		if (not this.health.dead) then
			this.health_bar.hidden = nil
		end
	end
	::label_25_0::
	while true do
		if this.health.dead then
			__pc_helpers["__pc_enemy_abomination_update_4"](store, this)
			return
		end
		if this.unit.is_stunned then
			__pc_helpers["__pc_enemy_abomination_update_15"](store, this)
		else
			local cont, blocker, ranged = __pc_helpers["__pc_enemy_blazefang_update_17"](store, this)
			if cont then
				if blocker then
					if (not SU.y_wait_for_blocker(store, this, blocker)) then
						goto label_25_0
					end
					while SU.can_melee_blocker(store, this, blocker) do
						if (this.ranged.range_while_blocking and ranged) then
							SU.y_enemy_range_attacks(store, this, ranged)
						end
						if (not __pc_helpers["__pc_enemy_abomination_update_29"](store, this, blocker)) then
							goto label_25_0
						end
						coroutine.yield()
					end
				elseif ranged then
					while (SU.can_range_soldier(store, this, ranged) and ((# this.enemy.blockers) == 0)) do
						if (not SU.y_enemy_range_attacks(store, this, ranged)) then
							goto label_25_0
						end
						coroutine.yield()
					end
				end
				coroutine.yield()
			end
		end
	end
end
,
	[16] = function(this, store)
	if (this.render.sprites[1].name == "raise") then
		if this.sound_events.raise then
			S:queue(this.sound_events.raise, this.sound_events.raise_args)
		end
		this.health_bar.hidden = true
		local an, af = U.animation_name_facing_point(this, "raise", this.motion.dest)
		U.y_animation_play(this, an, af, store.tick_ts, 1)
		if (not this.health.dead) then
			this.health_bar.hidden = nil
		end
	end
	::label_25_0::
	while true do
		if this.health.dead then
			__pc_helpers["__pc_enemy_bat_update_4"](store, this)
			return
		end
		if this.unit.is_stunned then
			__pc_helpers["__pc_enemy_savage_bird_rider_update_15"](store, this)
		else
			local cont, blocker, ranged = __pc_helpers["__pc_enemy_savage_bird_rider_update_17"](store, this)
			if cont then
				if blocker then
					if (not SU.y_wait_for_blocker(store, this, blocker)) then
						goto label_25_0
					end
					while SU.can_melee_blocker(store, this, blocker) do
						if (this.ranged.range_while_blocking and ranged) then
							SU.y_enemy_range_attacks(store, this, ranged)
						end
						if (not __pc_helpers["__pc_enemy_savage_bird_rider_update_37"](store, this, blocker)) then
							goto label_25_0
						end
						coroutine.yield()
					end
				elseif ranged then
					while (SU.can_range_soldier(store, this, ranged) and ((# this.enemy.blockers) == 0)) do
						if (not SU.y_enemy_range_attacks(store, this, ranged)) then
							goto label_25_0
						end
						coroutine.yield()
					end
				end
				coroutine.yield()
			end
		end
	end
end
,
	[17] = function(this, store)
	if (this.render.sprites[1].name == "raise") then
		local next_pos
		if this.motion.forced_waypoint then
			next_pos = this.motion.forced_waypoint
		else
			next_pos = P:next_entity_node(this, store.tick_length)
		end
		local an, af = U.animation_name_facing_point(this, "raise", next_pos)
		U.y_animation_play(this, an, af, store.tick_ts, 1)
	end
	while true do
		do
			SU.enemy_cliff_change(store, this)
		end
		if this.health.dead then
			__pc_helpers["__pc_enemy_razorwing_update_14"](store, this)
			return
		end
		if this.unit.is_stunned then
			__pc_helpers["__pc_enemy_bat_update_15"](this, "idle", nil, store.tick_ts, true)
			coroutine.yield()
		else
			__pc_helpers["__pc_enemy_bat_update_16"](store, this)
		end
	end
end
,
	[18] = function(this, store)
	if (this.render.sprites[1].name == "raise") then
		local next_pos
		if this.motion.forced_waypoint then
			next_pos = this.motion.forced_waypoint
		else
			next_pos = P:next_entity_node(this, store.tick_length)
		end
		local an, af = U.animation_name_facing_point(this, "raise", next_pos)
		U.y_animation_play(this, an, af, store.tick_ts, 1)
	end
	while true do
		if this.health.dead then
			__pc_helpers["__pc_enemy_abomination_update_4"](store, this)
			return
		end
		if this.unit.is_stunned then
			__pc_helpers["__pc_bolt_1_insert_1"](this, "idle", nil, store.tick_ts, true)
			coroutine.yield()
		else
			__pc_helpers["__pc_enemy_abomination_update_17"](store, this)
		end
	end
end
,
	[19] = function(this, store)
	if (this.render.sprites[1].name == "raise") then
		local next_pos
		if this.motion.forced_waypoint then
			next_pos = this.motion.forced_waypoint
		else
			next_pos = P:next_entity_node(this, store.tick_length)
		end
		local an, af = U.animation_name_facing_point(this, "raise", next_pos)
		U.y_animation_play(this, an, af, store.tick_ts, 1)
	end
	while true do
		if this.health.dead then
			__pc_helpers["__pc_enemy_bat_update_4"](store, this)
			return
		end
		if this.unit.is_stunned then
			__pc_helpers["__pc_enemy_bat_update_15"](this, "idle", nil, store.tick_ts, true)
			coroutine.yield()
		else
			__pc_helpers["__pc_enemy_bat_update_16"](store, this)
		end
	end
end
,
	[20] = function(this, store)
	local b = this.bullet
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)
	do
		this.render.sprites[1].hidden = true
	end
	return true
end
,
	[21] = function(this, store)
	local b = this.bullet
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)
	do
		this.render.sprites[1].r = (((math.random() - 0.5)) * math.pi)
		b.rotation_speed = (b.rotation_speed * ((((b.to.x > b.from.x) and (- 1)) or 1)))
	end
	do
		this.render.sprites[1].hidden = true
	end
	return true
end
,
	[22] = function(this, store)
	local b = this.bullet
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)
	do
		this.render.sprites[1].r = (((math.random() - 0.5)) * math.pi)
		b.rotation_speed = (b.rotation_speed * ((((b.to.x > b.from.x) and (- 1)) or 1)))
	end
	return true
end
,
	[23] = function(this, store)
	local b = this.bullet
	if b.target_id then
		local target = store.entities[b.target_id]
		if ((not target) or (target.vis and (band(target.vis.bans, F_RANGED) ~= 0))) then
			return false
		end
	end
	b.speed.x, b.speed.y = V.normalize((b.to.x - b.from.x), (b.to.y - b.from.y))
	local s = this.render.sprites[1]
	__pc_helpers["__pc_bolt_1_insert_1"](this, "flying", nil, store.tick_ts, s.loop)
	return true
end
,
	[24] = function(this, store)
	local b = this.bullet
	if b.target_id then
		local target = store.entities[b.target_id]
		if ((not target) or (target.vis and (band(target.vis.bans, F_RANGED) ~= 0))) then
			return false
		end
	end
	b.speed.x, b.speed.y = V.normalize((b.to.x - b.from.x), (b.to.y - b.from.y))
	local s = this.render.sprites[1]
	do
		s.r = V.angleTo((b.to.x - this.pos.x), (b.to.y - this.pos.y))
	end
	__pc_helpers["__pc_bolt_1_insert_1"](this, "flying", nil, store.tick_ts, s.loop)
	return true
end
,
	[25] = function(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]
	if (not target) then
		return false
	end
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	return true
end
,
	[26] = function(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]
	if (not target) then
		return false
	end
	do
		b.to.x = (b.to.x + (target.motion.speed.x * b.flight_time))
		b.to.y = (b.to.y + (target.motion.speed.y * b.flight_time))
	end
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	do
		b.rotation_speed = (b.rotation_speed * ((((b.to.x > this.pos.x) and (- 1)) or 1)))
		do
			this.render.sprites[1].flip_x = (not this.render.sprites[1].flip_x)
		end
	end
	return true
end
,
	[27] = function(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]
	if (not target) then
		return false
	end
	do
		b.to.x = (b.to.x + (target.motion.speed.x * b.flight_time))
		b.to.y = (b.to.y + (target.motion.speed.y * b.flight_time))
	end
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	do
		this.render.sprites[1].hidden = true
	end
	return true
end
,
	[28] = function(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]
	if (not target) then
		return false
	end
	do
		b.to.x, b.to.y = target.pos.x, target.pos.y
		if (target.unit and target.unit.hit_offset) then
			b.to.x, b.to.y = (b.to.x + target.unit.hit_offset.x), (b.to.y + target.unit.hit_offset.y)
		end
	end
	do
		b.to.x = (b.to.x + (target.motion.speed.x * b.flight_time))
		b.to.y = (b.to.y + (target.motion.speed.y * b.flight_time))
	end
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	do
		this.render.sprites[1].hidden = true
	end
	return true
end
,
	[29] = function(this, store)
	local brk, sta
	if this.vis._bans_added then
		U.bans_remove(this.vis, F_ALL)
		this.vis._bans_added = nil
	end
	if (this.render.sprites[1].name == "raise") then
		this.health_bar.hidden = true
		__pc_helpers["__pc_bolt_1_insert_1"](this, "raise", nil, store.tick_ts, false)
		while ((not U.animation_finished_default(this)) and (not this.health.dead)) do
			coroutine.yield()
		end
		if (not this.health.dead) then
			this.health_bar.hidden = nil
		end
	end
	while true do
		do
			for pn, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil
					__pc_helpers["__pc_soldier_amazona_insert_2"](this, pn)
				end
			end
		end
		if (this.cloak and this.soldier.target_id) then
			if this._cloak_enabled then
				U.flags_remove(this.vis, this.cloak.flags)
				U.bans_remove(this.vis, this.cloak.bans)
				this._cloak_enabled = nil
			end
			this.render.sprites[1].alpha = 255
		end
		if ((not this.health.dead) or __pc_helpers["__pc_soldier_amazona_update_9"](store, this)) then
		else
			__pc_helpers["__pc_soldier_amazona_update_21"](store, this)
			return
		end
		__pc_helpers["__pc_soldier_amazona_update_33"](this, store)
		if this.unit.is_stunned then
			__pc_helpers["__pc_soldier_amazona_update_39"](store, this)
		else
			if (this.dodge and this.dodge.active) then
				this.dodge.active = false
				if (this.dodge.counter_attack and (this.powers[this.dodge.counter_attack.power_name].level > 0)) then
					this.dodge.counter_attack_pending = true
				elseif this.dodge.animation then
					__pc_helpers["__pc_enemy_abomination_update_13"](this, this.dodge.animation, nil, store.tick_ts, false)
					while (not U.animation_finished_default(this)) do
						coroutine.yield()
					end
				end
				signal.emit("soldier-dodge", this)
			end
			while this.nav_rally.new do
				if __pc_helpers["__pc_soldier_amazona_update_43"](store, this) then
					goto label_39_1
				end
			end
			if this.timed_actions then
				brk, sta = SU.y_soldier_timed_actions(store, this)
				if brk then
					goto label_39_1
				end
			end
			if this.timed_attacks then
				brk, sta = __pc_helpers["__pc_soldier_amazona_update_52"](store, this)
				if brk then
					goto label_39_1
				end
			end
			do
				brk, sta = __pc_helpers["__pc_soldier_amazona_update_56"](store, this)
				if (brk or (sta ~= A_NO_TARGET)) then
					goto label_39_1
				end
			end
			if SU.soldier_go_back_step(store, this) then
				goto label_39_1
			end
			::label_39_0::
			__pc_helpers["__pc_soldier_amazona_update_39"](store, this)
			if this.cloak then
				if (not this._cloak_enabled) then
					U.flags_add(this.vis, this.cloak.flags)
					U.bans_add(this.vis, this.cloak.bans)
					this._cloak_enabled = true
				end
				if this.cloak.alpha then
					this.render.sprites[1].alpha = this.cloak.alpha
				end
			end
			SU.soldier_regen(store, this)
		end
		::label_39_1::
		coroutine.yield()
	end
end
,
	[30] = function(this, store)
	local brk, sta
	if this.vis._bans_added then
		U.bans_remove(this.vis, F_ALL)
		this.vis._bans_added = nil
	end
	if (this.render.sprites[1].name == "raise") then
		this.health_bar.hidden = true
		__pc_helpers["__pc_bolt_1_insert_1"](this, "raise", nil, store.tick_ts, false)
		while ((not U.animation_finished_default(this)) and (not this.health.dead)) do
			coroutine.yield()
		end
		if (not this.health.dead) then
			this.health_bar.hidden = nil
		end
	end
	while true do
		do
			for pn, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil
					__pc_helpers["__pc_soldier_arborean_sentinels_spearmen_insert_3"](this, pn)
				end
			end
		end
		if (this.cloak and this.soldier.target_id) then
			if this._cloak_enabled then
				U.flags_remove(this.vis, this.cloak.flags)
				U.bans_remove(this.vis, this.cloak.bans)
				this._cloak_enabled = nil
			end
			this.render.sprites[1].alpha = 255
		end
		if ((not this.health.dead) or __pc_helpers["__pc_soldier_amazona_update_9"](store, this)) then
		else
			__pc_helpers["__pc_soldier_amazona_update_21"](store, this)
			return
		end
		__pc_helpers["__pc_soldier_amazona_update_33"](this, store)
		if this.unit.is_stunned then
			__pc_helpers["__pc_soldier_amazona_update_39"](store, this)
		else
			if (this.dodge and this.dodge.active) then
				this.dodge.active = false
				if (this.dodge.counter_attack and (this.powers[this.dodge.counter_attack.power_name].level > 0)) then
					this.dodge.counter_attack_pending = true
				elseif this.dodge.animation then
					__pc_helpers["__pc_enemy_abomination_update_13"](this, this.dodge.animation, nil, store.tick_ts, false)
					while (not U.animation_finished_default(this)) do
						coroutine.yield()
					end
				end
				signal.emit("soldier-dodge", this)
			end
			while this.nav_rally.new do
				if __pc_helpers["__pc_soldier_amazona_update_43"](store, this) then
					goto label_39_1
				end
			end
			if this.timed_actions then
				brk, sta = SU.y_soldier_timed_actions(store, this)
				if brk then
					goto label_39_1
				end
			end
			if this.timed_attacks then
				brk, sta = __pc_helpers["__pc_soldier_amazona_update_52"](store, this)
				if brk then
					goto label_39_1
				end
			end
			if this.ranged.range_while_blocking then
				brk, sta = __pc_helpers["__pc_soldier_arborean_sentinels_spearmen_update_56"](store, this)
				if brk then
					goto label_39_1
				end
			end
			do
				brk, sta = __pc_helpers["__pc_soldier_amazona_update_56"](store, this)
				if (brk or (sta ~= A_NO_TARGET)) then
					goto label_39_1
				end
			end
			if (not this.ranged.range_while_blocking) then
				brk, sta = __pc_helpers["__pc_soldier_arborean_sentinels_spearmen_update_56"](store, this)
				if (brk or (sta == A_DONE)) then
					goto label_39_1
				elseif ((sta == A_IN_COOLDOWN) and (not this.ranged.go_back_during_cooldown)) then
					goto label_39_0
				end
			end
			if SU.soldier_go_back_step(store, this) then
				goto label_39_1
			end
			::label_39_0::
			__pc_helpers["__pc_soldier_amazona_update_39"](store, this)
			if this.cloak then
				if (not this._cloak_enabled) then
					U.flags_add(this.vis, this.cloak.flags)
					U.bans_add(this.vis, this.cloak.bans)
					this._cloak_enabled = true
				end
				if this.cloak.alpha then
					this.render.sprites[1].alpha = this.cloak.alpha
				end
			end
			SU.soldier_regen(store, this)
		end
		::label_39_1::
		coroutine.yield()
	end
end
,
	[31] = function(this, store)
	local brk, sta
	if this.vis._bans_added then
		U.bans_remove(this.vis, F_ALL)
		this.vis._bans_added = nil
	end
	if (this.render.sprites[1].name == "raise") then
		this.health_bar.hidden = true
		__pc_helpers["__pc_bolt_1_insert_1"](this, "raise", nil, store.tick_ts, false)
		while ((not U.animation_finished_default(this)) and (not this.health.dead)) do
			coroutine.yield()
		end
		if (not this.health.dead) then
			this.health_bar.hidden = nil
		end
	end
	while true do
		if (this.cloak and this.soldier.target_id) then
			if this._cloak_enabled then
				U.flags_remove(this.vis, this.cloak.flags)
				U.bans_remove(this.vis, this.cloak.bans)
				this._cloak_enabled = nil
			end
			this.render.sprites[1].alpha = 255
		end
		if ((not this.health.dead) or __pc_helpers["__pc_soldier_amazona_update_9"](store, this)) then
		else
			__pc_helpers["__pc_soldier_amazona_update_21"](store, this)
			return
		end
		__pc_helpers["__pc_soldier_amazona_update_33"](this, store)
		if this.unit.is_stunned then
			__pc_helpers["__pc_soldier_amazona_update_39"](store, this)
		else
			if (this.dodge and this.dodge.active) then
				this.dodge.active = false
				if (this.dodge.counter_attack and (this.powers[this.dodge.counter_attack.power_name].level > 0)) then
					this.dodge.counter_attack_pending = true
				elseif this.dodge.animation then
					__pc_helpers["__pc_enemy_abomination_update_13"](this, this.dodge.animation, nil, store.tick_ts, false)
					while (not U.animation_finished_default(this)) do
						coroutine.yield()
					end
				end
				signal.emit("soldier-dodge", this)
			end
			while this.nav_rally.new do
				if __pc_helpers["__pc_soldier_amazona_update_43"](store, this) then
					goto label_39_1
				end
			end
			if this.timed_actions then
				brk, sta = SU.y_soldier_timed_actions(store, this)
				if brk then
					goto label_39_1
				end
			end
			if this.timed_attacks then
				brk, sta = __pc_helpers["__pc_soldier_amazona_update_52"](store, this)
				if brk then
					goto label_39_1
				end
			end
			do
				brk, sta = __pc_helpers["__pc_soldier_arborean_sentinels_barkshield_update_50"](store, this)
				if (brk or (sta ~= A_NO_TARGET)) then
					goto label_39_1
				end
			end
			if SU.soldier_go_back_step(store, this) then
				goto label_39_1
			end
			::label_39_0::
			__pc_helpers["__pc_soldier_amazona_update_39"](store, this)
			if this.cloak then
				if (not this._cloak_enabled) then
					U.flags_add(this.vis, this.cloak.flags)
					U.bans_add(this.vis, this.cloak.bans)
					this._cloak_enabled = true
				end
				if this.cloak.alpha then
					this.render.sprites[1].alpha = this.cloak.alpha
				end
			end
			SU.soldier_regen(store, this)
		end
		::label_39_1::
		coroutine.yield()
	end
end
,
	[32] = function(this, store)
	local brk, sta
	if this.vis._bans_added then
		U.bans_remove(this.vis, F_ALL)
		this.vis._bans_added = nil
	end
	if (this.render.sprites[1].name == "raise") then
		this.health_bar.hidden = true
		__pc_helpers["__pc_bolt_1_insert_1"](this, "raise", nil, store.tick_ts, false)
		while ((not U.animation_finished_default(this)) and (not this.health.dead)) do
			coroutine.yield()
		end
		if (not this.health.dead) then
			this.health_bar.hidden = nil
		end
	end
	while true do
		if (this.cloak and this.soldier.target_id) then
			if this._cloak_enabled then
				U.flags_remove(this.vis, this.cloak.flags)
				U.bans_remove(this.vis, this.cloak.bans)
				this._cloak_enabled = nil
			end
			this.render.sprites[1].alpha = 255
		end
		if ((not this.health.dead) or __pc_helpers["__pc_soldier_amazona_update_9"](store, this)) then
		else
			__pc_helpers["__pc_soldier_amazona_update_21"](store, this)
			return
		end
		__pc_helpers["__pc_soldier_amazona_update_33"](this, store)
		if this.unit.is_stunned then
			__pc_helpers["__pc_soldier_amazona_update_39"](store, this)
		else
			if (this.dodge and this.dodge.active) then
				this.dodge.active = false
				if (this.dodge.counter_attack and (this.powers[this.dodge.counter_attack.power_name].level > 0)) then
					this.dodge.counter_attack_pending = true
				elseif this.dodge.animation then
					__pc_helpers["__pc_enemy_abomination_update_13"](this, this.dodge.animation, nil, store.tick_ts, false)
					while (not U.animation_finished_default(this)) do
						coroutine.yield()
					end
				end
				signal.emit("soldier-dodge", this)
			end
			while this.nav_rally.new do
				if __pc_helpers["__pc_soldier_amazona_update_43"](store, this) then
					goto label_39_1
				end
			end
			if this.timed_actions then
				brk, sta = SU.y_soldier_timed_actions(store, this)
				if brk then
					goto label_39_1
				end
			end
			if this.timed_attacks then
				brk, sta = __pc_helpers["__pc_soldier_amazona_update_52"](store, this)
				if brk then
					goto label_39_1
				end
			end
			if this.ranged.range_while_blocking then
				brk, sta = __pc_helpers["__pc_soldier_arborean_sentinels_spearmen_update_56"](store, this)
				if brk then
					goto label_39_1
				end
			end
			do
				brk, sta = __pc_helpers["__pc_soldier_arborean_sentinels_barkshield_update_50"](store, this)
				if (brk or (sta ~= A_NO_TARGET)) then
					goto label_39_1
				end
			end
			if (not this.ranged.range_while_blocking) then
				brk, sta = __pc_helpers["__pc_soldier_arborean_sentinels_spearmen_update_56"](store, this)
				if (brk or (sta == A_DONE)) then
					goto label_39_1
				elseif ((sta == A_IN_COOLDOWN) and (not this.ranged.go_back_during_cooldown)) then
					goto label_39_0
				end
			end
			if SU.soldier_go_back_step(store, this) then
				goto label_39_1
			end
			::label_39_0::
			__pc_helpers["__pc_soldier_amazona_update_39"](store, this)
			if this.cloak then
				if (not this._cloak_enabled) then
					U.flags_add(this.vis, this.cloak.flags)
					U.bans_add(this.vis, this.cloak.bans)
					this._cloak_enabled = true
				end
				if this.cloak.alpha then
					this.render.sprites[1].alpha = this.cloak.alpha
				end
			end
			SU.soldier_regen(store, this)
		end
		::label_39_1::
		coroutine.yield()
	end
end
,
	[33] = function(this, store)
	local brk, sta
	if this.vis._bans_added then
		U.bans_remove(this.vis, F_ALL)
		this.vis._bans_added = nil
	end
	if (this.render.sprites[1].name == "raise") then
		this.health_bar.hidden = true
		__pc_helpers["__pc_enemy_bat_update_15"](this, "raise", nil, store.tick_ts, false)
		while ((not U.animation_finished_default(this)) and (not this.health.dead)) do
			coroutine.yield()
		end
		if (not this.health.dead) then
			this.health_bar.hidden = nil
		end
	end
	while true do
		do
			for pn, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil
					__pc_helpers["__pc_soldier_amazona_insert_2"](this, pn)
				end
			end
		end
		if (this.cloak and this.soldier.target_id) then
			if this._cloak_enabled then
				U.flags_remove(this.vis, this.cloak.flags)
				U.bans_remove(this.vis, this.cloak.bans)
				this._cloak_enabled = nil
			end
			this.render.sprites[1].alpha = 255
		end
		if ((not this.health.dead) or __pc_helpers["__pc_soldier_bone_golem_update_3"](store, this)) then
		else
			__pc_helpers["__pc_soldier_bone_golem_update_15"](store, this)
			return
		end
		__pc_helpers["__pc_soldier_bone_golem_update_27"](this, store)
		if this.unit.is_stunned then
			__pc_helpers["__pc_soldier_bone_golem_update_33"](store, this)
		else
			if (this.dodge and this.dodge.active) then
				this.dodge.active = false
				if (this.dodge.counter_attack and (this.powers[this.dodge.counter_attack.power_name].level > 0)) then
					this.dodge.counter_attack_pending = true
				elseif this.dodge.animation then
					__pc_helpers["__pc_enemy_bat_update_13"](this, this.dodge.animation, nil, store.tick_ts, false)
					while (not U.animation_finished_default(this)) do
						coroutine.yield()
					end
				end
				signal.emit("soldier-dodge", this)
			end
			while this.nav_rally.new do
				if __pc_helpers["__pc_soldier_bone_golem_update_37"](store, this) then
					goto label_39_1
				end
			end
			if this.timed_actions then
				brk, sta = SU.y_soldier_timed_actions(store, this)
				if brk then
					goto label_39_1
				end
			end
			if this.timed_attacks then
				brk, sta = __pc_helpers["__pc_soldier_amazona_update_52"](store, this)
				if brk then
					goto label_39_1
				end
			end
			do
				brk, sta = __pc_helpers["__pc_soldier_swamp_monster_update_56"](store, this)
				if (brk or (sta ~= A_NO_TARGET)) then
					goto label_39_1
				end
			end
			if SU.soldier_go_back_step(store, this) then
				goto label_39_1
			end
			::label_39_0::
			__pc_helpers["__pc_soldier_bone_golem_update_33"](store, this)
			if this.cloak then
				if (not this._cloak_enabled) then
					U.flags_add(this.vis, this.cloak.flags)
					U.bans_add(this.vis, this.cloak.bans)
					this._cloak_enabled = true
				end
				if this.cloak.alpha then
					this.render.sprites[1].alpha = this.cloak.alpha
				end
			end
			SU.soldier_regen(store, this)
		end
		::label_39_1::
		coroutine.yield()
	end
end
,
	[34] = function(this, store)
	local brk, sta
	if this.vis._bans_added then
		U.bans_remove(this.vis, F_ALL)
		this.vis._bans_added = nil
	end
	if (this.render.sprites[1].name == "raise") then
		this.health_bar.hidden = true
		__pc_helpers["__pc_enemy_bat_update_15"](this, "raise", nil, store.tick_ts, false)
		while ((not U.animation_finished_default(this)) and (not this.health.dead)) do
			coroutine.yield()
		end
		if (not this.health.dead) then
			this.health_bar.hidden = nil
		end
	end
	while true do
		if (this.cloak and this.soldier.target_id) then
			if this._cloak_enabled then
				U.flags_remove(this.vis, this.cloak.flags)
				U.bans_remove(this.vis, this.cloak.bans)
				this._cloak_enabled = nil
			end
			this.render.sprites[1].alpha = 255
		end
		if ((not this.health.dead) or __pc_helpers["__pc_soldier_bone_golem_update_3"](store, this)) then
		else
			__pc_helpers["__pc_soldier_bone_golem_update_15"](store, this)
			return
		end
		__pc_helpers["__pc_soldier_bone_golem_update_27"](this, store)
		if this.unit.is_stunned then
			__pc_helpers["__pc_soldier_bone_golem_update_33"](store, this)
		else
			if (this.dodge and this.dodge.active) then
				this.dodge.active = false
				if (this.dodge.counter_attack and (this.powers[this.dodge.counter_attack.power_name].level > 0)) then
					this.dodge.counter_attack_pending = true
				elseif this.dodge.animation then
					__pc_helpers["__pc_enemy_bat_update_13"](this, this.dodge.animation, nil, store.tick_ts, false)
					while (not U.animation_finished_default(this)) do
						coroutine.yield()
					end
				end
				signal.emit("soldier-dodge", this)
			end
			while this.nav_rally.new do
				if __pc_helpers["__pc_soldier_bone_golem_update_37"](store, this) then
					goto label_39_1
				end
			end
			if this.timed_actions then
				brk, sta = SU.y_soldier_timed_actions(store, this)
				if brk then
					goto label_39_1
				end
			end
			if this.timed_attacks then
				brk, sta = __pc_helpers["__pc_soldier_amazona_update_52"](store, this)
				if brk then
					goto label_39_1
				end
			end
			do
				brk, sta = __pc_helpers["__pc_soldier_bone_golem_update_73"](store, this)
				if (brk or (sta ~= A_NO_TARGET)) then
					goto label_39_1
				end
			end
			if SU.soldier_go_back_step(store, this) then
				goto label_39_1
			end
			::label_39_0::
			__pc_helpers["__pc_soldier_bone_golem_update_33"](store, this)
			if this.cloak then
				if (not this._cloak_enabled) then
					U.flags_add(this.vis, this.cloak.flags)
					U.bans_add(this.vis, this.cloak.bans)
					this._cloak_enabled = true
				end
				if this.cloak.alpha then
					this.render.sprites[1].alpha = this.cloak.alpha
				end
			end
			SU.soldier_regen(store, this)
		end
		::label_39_1::
		coroutine.yield()
	end
end
,
	[35] = function(this, store)
	local brk, sta
	if this.vis._bans_added then
		U.bans_remove(this.vis, F_ALL)
		this.vis._bans_added = nil
	end
	if (this.render.sprites[1].name == "raise") then
		this.health_bar.hidden = true
		__pc_helpers["__pc_enemy_bat_update_15"](this, "raise", nil, store.tick_ts, false)
		while ((not U.animation_finished_default(this)) and (not this.health.dead)) do
			coroutine.yield()
		end
		if (not this.health.dead) then
			this.health_bar.hidden = nil
		end
	end
	while true do
		if (this.cloak and this.soldier.target_id) then
			if this._cloak_enabled then
				U.flags_remove(this.vis, this.cloak.flags)
				U.bans_remove(this.vis, this.cloak.bans)
				this._cloak_enabled = nil
			end
			this.render.sprites[1].alpha = 255
		end
		if ((not this.health.dead) or __pc_helpers["__pc_soldier_bone_golem_update_3"](store, this)) then
		else
			__pc_helpers["__pc_soldier_bone_golem_update_15"](store, this)
			return
		end
		__pc_helpers["__pc_soldier_bone_golem_update_27"](this, store)
		if this.unit.is_stunned then
			__pc_helpers["__pc_soldier_bone_golem_update_33"](store, this)
		else
			if (this.dodge and this.dodge.active) then
				this.dodge.active = false
				if (this.dodge.counter_attack and (this.powers[this.dodge.counter_attack.power_name].level > 0)) then
					this.dodge.counter_attack_pending = true
				elseif this.dodge.animation then
					__pc_helpers["__pc_enemy_bat_update_13"](this, this.dodge.animation, nil, store.tick_ts, false)
					while (not U.animation_finished_default(this)) do
						coroutine.yield()
					end
				end
				signal.emit("soldier-dodge", this)
			end
			while this.nav_rally.new do
				if __pc_helpers["__pc_soldier_bone_golem_update_37"](store, this) then
					goto label_39_1
				end
			end
			if this.timed_actions then
				brk, sta = SU.y_soldier_timed_actions(store, this)
				if brk then
					goto label_39_1
				end
			end
			if this.timed_attacks then
				brk, sta = __pc_helpers["__pc_soldier_amazona_update_52"](store, this)
				if brk then
					goto label_39_1
				end
			end
			if this.ranged.range_while_blocking then
				brk, sta = __pc_helpers["__pc_soldier_bone_golem_update_50"](store, this)
				if brk then
					goto label_39_1
				end
			end
			do
				brk, sta = __pc_helpers["__pc_soldier_bone_golem_update_73"](store, this)
				if (brk or (sta ~= A_NO_TARGET)) then
					goto label_39_1
				end
			end
			if (not this.ranged.range_while_blocking) then
				brk, sta = __pc_helpers["__pc_soldier_bone_golem_update_50"](store, this)
				if (brk or (sta == A_DONE)) then
					goto label_39_1
				elseif ((sta == A_IN_COOLDOWN) and (not this.ranged.go_back_during_cooldown)) then
					goto label_39_0
				end
			end
			if SU.soldier_go_back_step(store, this) then
				goto label_39_1
			end
			::label_39_0::
			__pc_helpers["__pc_soldier_bone_golem_update_33"](store, this)
			if this.cloak then
				if (not this._cloak_enabled) then
					U.flags_add(this.vis, this.cloak.flags)
					U.bans_add(this.vis, this.cloak.bans)
					this._cloak_enabled = true
				end
				if this.cloak.alpha then
					this.render.sprites[1].alpha = this.cloak.alpha
				end
			end
			SU.soldier_regen(store, this)
		end
		::label_39_1::
		coroutine.yield()
	end
end
,
	[36] = function(this, store)
	local brk, sta
	if this.vis._bans_added then
		U.bans_remove(this.vis, F_ALL)
		this.vis._bans_added = nil
	end
	if (this.render.sprites[1].name == "raise") then
		this.health_bar.hidden = true
		__pc_helpers["__pc_soldier_deep_devils_chosen_update_1"](this, "raise", nil, store.tick_ts, false)
		while ((not U.animation_finished_default(this)) and (not this.health.dead)) do
			coroutine.yield()
		end
		if (not this.health.dead) then
			this.health_bar.hidden = nil
		end
	end
	while true do
		do
			for pn, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil
					__pc_helpers["__pc_soldier_arborean_sentinels_spearmen_insert_3"](this, pn)
				end
			end
		end
		if (this.cloak and this.soldier.target_id) then
			if this._cloak_enabled then
				U.flags_remove(this.vis, this.cloak.flags)
				U.bans_remove(this.vis, this.cloak.bans)
				this._cloak_enabled = nil
			end
			this.render.sprites[1].alpha = 255
		end
		if ((not this.health.dead) or __pc_helpers["__pc_soldier_deep_devils_chosen_update_9"](store, this)) then
		else
			__pc_helpers["__pc_soldier_deep_devils_chosen_update_21"](store, this)
			return
		end
		__pc_helpers["__pc_soldier_deep_devils_chosen_update_33"](this, store)
		if this.unit.is_stunned then
			__pc_helpers["__pc_soldier_deep_devils_chosen_update_39"](store, this)
		else
			if (this.dodge and this.dodge.active) then
				this.dodge.active = false
				if (this.dodge.counter_attack and (this.powers[this.dodge.counter_attack.power_name].level > 0)) then
					this.dodge.counter_attack_pending = true
				elseif this.dodge.animation then
					__pc_helpers["__pc_soldier_deep_devils_chosen_update_17"](this, this.dodge.animation, nil, store.tick_ts, false)
					while (not U.animation_finished_default(this)) do
						coroutine.yield()
					end
				end
				signal.emit("soldier-dodge", this)
			end
			while this.nav_rally.new do
				if __pc_helpers["__pc_soldier_deep_devils_chosen_update_43"](store, this) then
					goto label_39_1
				end
			end
			if this.timed_actions then
				brk, sta = SU.y_soldier_timed_actions(store, this)
				if brk then
					goto label_39_1
				end
			end
			if this.timed_attacks then
				brk, sta = __pc_helpers["__pc_soldier_amazona_update_52"](store, this)
				if brk then
					goto label_39_1
				end
			end
			if this.ranged.range_while_blocking then
				brk, sta = __pc_helpers["__pc_soldier_deep_devils_chosen_update_56"](store, this)
				if brk then
					goto label_39_1
				end
			end
			do
				brk, sta = __pc_helpers["__pc_soldier_deep_devils_chosen_update_81"](store, this)
				if (brk or (sta ~= A_NO_TARGET)) then
					goto label_39_1
				end
			end
			if (not this.ranged.range_while_blocking) then
				brk, sta = __pc_helpers["__pc_soldier_deep_devils_chosen_update_56"](store, this)
				if (brk or (sta == A_DONE)) then
					goto label_39_1
				elseif ((sta == A_IN_COOLDOWN) and (not this.ranged.go_back_during_cooldown)) then
					goto label_39_0
				end
			end
			if SU.soldier_go_back_step(store, this) then
				goto label_39_1
			end
			::label_39_0::
			__pc_helpers["__pc_soldier_deep_devils_chosen_update_39"](store, this)
			if this.cloak then
				if (not this._cloak_enabled) then
					U.flags_add(this.vis, this.cloak.flags)
					U.bans_add(this.vis, this.cloak.bans)
					this._cloak_enabled = true
				end
				if this.cloak.alpha then
					this.render.sprites[1].alpha = this.cloak.alpha
				end
			end
			SU.soldier_regen(store, this)
		end
		::label_39_1::
		coroutine.yield()
	end
end
,
	[37] = function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if (((target and target.unit) and false) and target.render) then
		for i = 1, (# this.render.sprites) do
			local s = this.render.sprites[i]
			s.flip_x = target.render.sprites[1].flip_x
			s.ts = store.tick_ts
			if s.size_names then
				s.name = s.size_names[target.unit.size]
			end
		end
	end
	return true
end
,
	[38] = function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if ((target and target.unit) and target.render) then
		do
			local i = 1
			local s = this.render.sprites[i]
			s.flip_x = target.render.sprites[1].flip_x
			s.ts = store.tick_ts
			do
				s.name = s.size_names[target.unit.size]
			end
		end
	end
	return true
end
,
	[39] = function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if ((target and target.unit) and target.render) then
		do
			local i = 1
			local s = this.render.sprites[i]
			s.flip_x = target.render.sprites[1].flip_x
			s.ts = store.tick_ts
		end
		do
			local i = 2
			local s = this.render.sprites[i]
			s.flip_x = target.render.sprites[1].flip_x
			s.ts = store.tick_ts
			if s.size_names then
				s.name = s.size_names[target.unit.size]
			end
		end
	end
	return true
end
,
	[40] = function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if ((target and target.unit) and target.render) then
		do
			local i = 1
			local s = this.render.sprites[i]
			s.flip_x = target.render.sprites[1].flip_x
			s.ts = store.tick_ts
		end
	end
	return true
end
,
	[41] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
		do
			local i = 2
			this.render.sprites[i].ts = store.tick_ts
		end
		do
			local i = 3
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.melee.order = U.attack_order(this.melee.attacks)
		do
			local i = 1
			this.melee.attacks[i].ts = store.tick_ts
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[42] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
		do
			local i = 2
			this.render.sprites[i].ts = store.tick_ts
		end
		do
			local i = 3
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.ranged.order = U.attack_order(this.ranged.attacks)
		do
			local i = 1
			this.ranged.attacks[i].ts = store.tick_ts
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[43] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
		do
			local i = 2
			this.render.sprites[i].ts = store.tick_ts
		end
		do
			local i = 3
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[44] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
		do
			local i = 2
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		do
			local i = 1
			local a = this.auras.list[i]
			a.ts = store.tick_ts
			if (a.cooldown == 0) then
				local e = E:create_entity(a.name)
				e.pos.x = this.pos.x
				e.pos.y = this.pos.y
				e.aura.level = this.unit.level
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts
				simulation:queue_insert_entity(e)
			end
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[45] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
		do
			local i = 2
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.melee.order = U.attack_order(this.melee.attacks)
		do
			local i = 1
			this.melee.attacks[i].ts = store.tick_ts
		end
		do
			local i = 2
			this.melee.attacks[i].ts = store.tick_ts
		end
		do
			local i = 3
			this.melee.attacks[i].ts = store.tick_ts
		end
		do
			local i = 4
			this.melee.attacks[i].ts = store.tick_ts
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[46] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
		do
			local i = 2
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.melee.order = U.attack_order(this.melee.attacks)
		do
			local i = 1
			this.melee.attacks[i].ts = store.tick_ts
		end
	end
	do
		this.ranged.order = U.attack_order(this.ranged.attacks)
		do
			local i = 1
			this.ranged.attacks[i].ts = store.tick_ts
		end
	end
	do
		do
			local i = 1
			local a = this.auras.list[i]
			a.ts = store.tick_ts
			if (a.cooldown == 0) then
				local e = E:create_entity(a.name)
				e.pos.x = this.pos.x
				e.pos.y = this.pos.y
				e.aura.level = this.unit.level
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts
				simulation:queue_insert_entity(e)
			end
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[47] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
		do
			local i = 2
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.melee.order = U.attack_order(this.melee.attacks)
		do
			local i = 1
			this.melee.attacks[i].ts = store.tick_ts
		end
	end
	do
		this.ranged.order = U.attack_order(this.ranged.attacks)
		do
			local i = 1
			this.ranged.attacks[i].ts = store.tick_ts
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[48] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
		do
			local i = 2
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.melee.order = U.attack_order(this.melee.attacks)
		do
			local i = 1
			this.melee.attacks[i].ts = store.tick_ts
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[49] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
		do
			local i = 2
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.ranged.order = U.attack_order(this.ranged.attacks)
		do
			local i = 1
			this.ranged.attacks[i].ts = store.tick_ts
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[50] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
		do
			local i = 2
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[51] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		do
			local i = 1
			local a = this.auras.list[i]
			a.ts = store.tick_ts
			if (a.cooldown == 0) then
				local e = E:create_entity(a.name)
				e.pos.x = this.pos.x
				e.pos.y = this.pos.y
				e.aura.level = this.unit.level
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts
				simulation:queue_insert_entity(e)
			end
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[52] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.melee.order = U.attack_order(this.melee.attacks)
		do
			local i = 1
			this.melee.attacks[i].ts = store.tick_ts
		end
		do
			local i = 2
			this.melee.attacks[i].ts = store.tick_ts
		end
		do
			local i = 3
			this.melee.attacks[i].ts = store.tick_ts
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[53] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.melee.order = U.attack_order(this.melee.attacks)
		do
			local i = 1
			this.melee.attacks[i].ts = store.tick_ts
		end
		do
			local i = 2
			this.melee.attacks[i].ts = store.tick_ts
		end
	end
	do
		do
			local i = 1
			local a = this.auras.list[i]
			a.ts = store.tick_ts
			if (a.cooldown == 0) then
				local e = E:create_entity(a.name)
				e.pos.x = this.pos.x
				e.pos.y = this.pos.y
				e.aura.level = this.unit.level
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts
				simulation:queue_insert_entity(e)
			end
		end
		do
			local i = 2
			local a = this.auras.list[i]
			a.ts = store.tick_ts
			if (a.cooldown == 0) then
				local e = E:create_entity(a.name)
				e.pos.x = this.pos.x
				e.pos.y = this.pos.y
				e.aura.level = this.unit.level
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts
				simulation:queue_insert_entity(e)
			end
		end
		do
			local i = 3
			local a = this.auras.list[i]
			a.ts = store.tick_ts
			if (a.cooldown == 0) then
				local e = E:create_entity(a.name)
				e.pos.x = this.pos.x
				e.pos.y = this.pos.y
				e.aura.level = this.unit.level
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts
				simulation:queue_insert_entity(e)
			end
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[54] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.melee.order = U.attack_order(this.melee.attacks)
		do
			local i = 1
			this.melee.attacks[i].ts = store.tick_ts
		end
		do
			local i = 2
			this.melee.attacks[i].ts = store.tick_ts
		end
	end
	do
		do
			local i = 1
			local a = this.auras.list[i]
			a.ts = store.tick_ts
			if (a.cooldown == 0) then
				local e = E:create_entity(a.name)
				e.pos.x = this.pos.x
				e.pos.y = this.pos.y
				e.aura.level = this.unit.level
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts
				simulation:queue_insert_entity(e)
			end
		end
		do
			local i = 2
			local a = this.auras.list[i]
			a.ts = store.tick_ts
			if (a.cooldown == 0) then
				local e = E:create_entity(a.name)
				e.pos.x = this.pos.x
				e.pos.y = this.pos.y
				e.aura.level = this.unit.level
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts
				simulation:queue_insert_entity(e)
			end
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[55] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.melee.order = U.attack_order(this.melee.attacks)
		do
			local i = 1
			this.melee.attacks[i].ts = store.tick_ts
		end
		do
			local i = 2
			this.melee.attacks[i].ts = store.tick_ts
		end
	end
	do
		this.ranged.order = U.attack_order(this.ranged.attacks)
		do
			local i = 1
			this.ranged.attacks[i].ts = store.tick_ts
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[56] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.melee.order = U.attack_order(this.melee.attacks)
		do
			local i = 1
			this.melee.attacks[i].ts = store.tick_ts
		end
		do
			local i = 2
			this.melee.attacks[i].ts = store.tick_ts
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[57] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.melee.order = U.attack_order(this.melee.attacks)
		do
			local i = 1
			this.melee.attacks[i].ts = store.tick_ts
		end
	end
	do
		do
			local i = 1
			local a = this.auras.list[i]
			a.ts = store.tick_ts
			if (a.cooldown == 0) then
				local e = E:create_entity(a.name)
				e.pos.x = this.pos.x
				e.pos.y = this.pos.y
				e.aura.level = this.unit.level
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts
				simulation:queue_insert_entity(e)
			end
		end
		do
			local i = 2
			local a = this.auras.list[i]
			a.ts = store.tick_ts
			if (a.cooldown == 0) then
				local e = E:create_entity(a.name)
				e.pos.x = this.pos.x
				e.pos.y = this.pos.y
				e.aura.level = this.unit.level
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts
				simulation:queue_insert_entity(e)
			end
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[58] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.melee.order = U.attack_order(this.melee.attacks)
		do
			local i = 1
			this.melee.attacks[i].ts = store.tick_ts
		end
	end
	do
		do
			local i = 1
			local a = this.auras.list[i]
			a.ts = store.tick_ts
			if (a.cooldown == 0) then
				local e = E:create_entity(a.name)
				e.pos.x = this.pos.x
				e.pos.y = this.pos.y
				e.aura.level = this.unit.level
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts
				simulation:queue_insert_entity(e)
			end
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[59] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.melee.order = U.attack_order(this.melee.attacks)
		do
			local i = 1
			this.melee.attacks[i].ts = store.tick_ts
		end
	end
	do
		this.ranged.order = U.attack_order(this.ranged.attacks)
		do
			local i = 1
			this.ranged.attacks[i].ts = store.tick_ts
		end
		do
			local i = 2
			this.ranged.attacks[i].ts = store.tick_ts
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[60] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.melee.order = U.attack_order(this.melee.attacks)
		do
			local i = 1
			this.melee.attacks[i].ts = store.tick_ts
		end
	end
	do
		this.ranged.order = U.attack_order(this.ranged.attacks)
		do
			local i = 1
			this.ranged.attacks[i].ts = store.tick_ts
		end
	end
	do
		do
			local i = 1
			local a = this.auras.list[i]
			a.ts = store.tick_ts
			if (a.cooldown == 0) then
				local e = E:create_entity(a.name)
				e.pos.x = this.pos.x
				e.pos.y = this.pos.y
				e.aura.level = this.unit.level
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts
				simulation:queue_insert_entity(e)
			end
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[61] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.melee.order = U.attack_order(this.melee.attacks)
		do
			local i = 1
			this.melee.attacks[i].ts = store.tick_ts
		end
	end
	do
		this.ranged.order = U.attack_order(this.ranged.attacks)
		do
			local i = 1
			this.ranged.attacks[i].ts = store.tick_ts
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[62] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.melee.order = U.attack_order(this.melee.attacks)
		do
			local i = 1
			this.melee.attacks[i].ts = store.tick_ts
		end
	end
	do
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[63] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.melee.order = U.attack_order(this.melee.attacks)
		do
			local i = 1
			this.melee.attacks[i].ts = store.tick_ts
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[64] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.ranged.order = U.attack_order(this.ranged.attacks)
		do
			local i = 1
			this.ranged.attacks[i].ts = store.tick_ts
		end
	end
	do
		do
			local i = 1
			local a = this.auras.list[i]
			a.ts = store.tick_ts
			if (a.cooldown == 0) then
				local e = E:create_entity(a.name)
				e.pos.x = this.pos.x
				e.pos.y = this.pos.y
				e.aura.level = this.unit.level
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts
				simulation:queue_insert_entity(e)
			end
		end
		do
			local i = 2
			local a = this.auras.list[i]
			a.ts = store.tick_ts
			if (a.cooldown == 0) then
				local e = E:create_entity(a.name)
				e.pos.x = this.pos.x
				e.pos.y = this.pos.y
				e.aura.level = this.unit.level
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts
				simulation:queue_insert_entity(e)
			end
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[65] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	do
		this.ranged.order = U.attack_order(this.ranged.attacks)
		do
			local i = 1
			this.ranged.attacks[i].ts = store.tick_ts
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[66] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	do
		do
			local i = 1
			this.render.sprites[i].ts = store.tick_ts
		end
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[67] = function(this, store)
	local next = P:next_entity_node(this, store.tick_length)
	if (not next) then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)
		return false
	end
	U.set_destination(this, next)
	U.set_heading(this, next)
	if ((this.pos.x == 0) and (this.pos.y == 0)) then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[68] = function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if ((target and target.unit) and false) then
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
	this.dps.ts = (store.tick_ts - this.dps.damage_every)
	this.modifier.ts = store.tick_ts
	signal.emit("mod-applied", this, target)
	return true
end
,
	[69] = function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if (target and target.unit) then
		local s = this.render.sprites[1]
		s.ts = store.tick_ts
		do
			s.name = s.size_names[target.unit.size]
		end
		if target.render then
			s.z = target.render.sprites[1].z
		end
	end
	this.dps.ts = (store.tick_ts - this.dps.damage_every)
	this.modifier.ts = store.tick_ts
	signal.emit("mod-applied", this, target)
	return true
end
,
	[70] = function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if (target and target.unit) then
		local s = this.render.sprites[1]
		s.ts = store.tick_ts
		if target.render then
			s.z = target.render.sprites[1].z
		end
	end
	this.dps.ts = (store.tick_ts - this.dps.damage_every)
	this.modifier.ts = store.tick_ts
	signal.emit("mod-applied", this, target)
	return true
end
,
	[71] = function(this, store)
	this.aura.ts = store.tick_ts
	do
		for _, s in ipairs(this.render.sprites) do
			s.ts = store.tick_ts
		end
	end
	if this.aura.source_id then
		local target = store.entities[this.aura.source_id]
		if (((target and false) and target.unit) and target.unit.mod_offset) then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end
	end
	this.actual_duration = this.aura.duration
	do
		this.actual_duration = (this.actual_duration + (this.aura.level * this.aura.duration_inc))
	end
	return true
end
,
	[72] = function(this, store)
	this.aura.ts = store.tick_ts
	do
		for _, s in ipairs(this.render.sprites) do
			s.ts = store.tick_ts
		end
	end
	if this.aura.source_id then
		local target = store.entities[this.aura.source_id]
		if ((target and target.unit) and target.unit.mod_offset) then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end
	end
	this.actual_duration = this.aura.duration
	do
		this.actual_duration = (this.actual_duration + (this.aura.level * this.aura.duration_inc))
	end
	return true
end
,
	[73] = function(this, store)
	this.aura.ts = store.tick_ts
	do
		for _, s in ipairs(this.render.sprites) do
			s.ts = store.tick_ts
		end
	end
	if this.aura.source_id then
		local target = store.entities[this.aura.source_id]
		if ((target and target.unit) and target.unit.mod_offset) then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end
	end
	this.actual_duration = this.aura.duration
	return true
end
,
	[74] = function(this, store)
	this.aura.ts = store.tick_ts
	if this.aura.source_id then
		local target = store.entities[this.aura.source_id]
		if ((((target and false) and false) and target.unit) and target.unit.mod_offset) then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end
	end
	this.actual_duration = this.aura.duration
	do
		this.actual_duration = (this.actual_duration + (this.aura.level * this.aura.duration_inc))
	end
	return true
end
,
	[75] = function(this, store)
	this.aura.ts = store.tick_ts
	if this.aura.source_id then
		local target = store.entities[this.aura.source_id]
		if (((target and false) and target.unit) and target.unit.mod_offset) then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end
	end
	this.actual_duration = this.aura.duration
	do
		this.actual_duration = (this.actual_duration + (this.aura.level * this.aura.duration_inc))
	end
	return true
end
,
	[76] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			__pc_helpers["__pc_aura_bullet_zeppelin_hero_tank_update_1"](this, "in", false, store.tick_ts, false)
			context.state = 2
		end
	end
	do
		if (context.state == 2) then
			if U.animation_finished_default(this) then
				context.state = 1
				do
					context.last_hit_ts = (store.tick_ts - a.cycle_time)
				end
				context.mods = (a.mods or {a.mod})
				__pc_helpers["__pc_aura_bullet_zeppelin_hero_tank_update_1"](this, "run", false, store.tick_ts, true)
			else
				return
			end
		elseif (context.state == 3) then
			if U.animation_finished_default(this) then
				simulation:queue_remove_entity(this)
			end
			return
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	if ((store.tick_ts - a.ts) > this.actual_duration) then
		do
			context.state = 3
			__pc_helpers["__pc_aura_bullet_zeppelin_hero_tank_update_1"](this, "out", false, store.tick_ts, false)
		end
		return
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		do
			targets = U.find_enemies_in_range_filter_off(this.pos, a.radius, a.vis_flags, a.vis_bans)
		end
	end
	if (not targets) then
		return
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[77] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				context.cycles_count = 0
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	if (context.cycles_count >= a.cycles) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	if ((store.tick_ts - a.ts) > this.actual_duration) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	do
		context.cycles_count = (context.cycles_count + 1)
	end
	local targets
	do
		do
			aura_filter_current = a
			targets = U.find_enemies_in_range_filter_on(this.pos, a.radius, a.vis_flags, a.vis_bans, aura_filter)
			aura_filter_current = nil
		end
	end
	if (not targets) then
		return
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[78] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				context.cycles_count = 0
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	if (context.cycles_count >= a.cycles) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	if ((store.tick_ts - a.ts) > this.actual_duration) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	do
		context.cycles_count = (context.cycles_count + 1)
	end
	local targets
	do
		do
			targets = U.find_enemies_in_range_filter_off(this.pos, a.radius, a.vis_flags, a.vis_bans)
		end
	end
	if (not targets) then
		return
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[79] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				context.cycles_count = 0
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	if (context.cycles_count >= a.cycles) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	if ((store.tick_ts - a.ts) > this.actual_duration) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	do
		context.cycles_count = (context.cycles_count + 1)
	end
	local targets
	do
		targets = {}
		for _, v in pairs(store.soldiers) do
			if ((((not v.health.dead) and (band(v.vis.flags, a.vis_bans) == 0)) and (band(v.vis.bans, a.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, a.radius)) then
				targets[((# targets) + 1)] = v
			end
		end
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[80] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				context.cycles_count = 0
			end
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	if (context.cycles_count >= a.cycles) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	if ((store.tick_ts - a.ts) > this.actual_duration) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	do
		local source = store.entities[a.source_id]
		if ((not source) or (source.health and source.health.dead)) then
			do
				simulation:queue_remove_entity(this)
			end
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	do
		context.cycles_count = (context.cycles_count + 1)
	end
	local targets
	do
		targets = {}
		for _, v in pairs(store.soldiers) do
			if ((((not v.health.dead) and (band(v.vis.flags, a.vis_bans) == 0)) and (band(v.vis.bans, a.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, a.radius)) then
				targets[((# targets) + 1)] = v
			end
		end
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[81] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				context.first_hit_ts = store.tick_ts
			end
			do
				context.victims_count = 0
			end
			do
				context.last_hit_ts = ((store.tick_ts - a.apply_delay) - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	if ((store.tick_ts - a.ts) > this.actual_duration) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	do
		apply = (apply and ((store.tick_ts - context.first_hit_ts) <= a.apply_duration))
	end
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		do
			targets = U.find_enemies_in_range_filter_off(this.pos, a.radius, a.vis_flags, a.vis_bans)
		end
	end
	if (not targets) then
		return
	end
	for i = 1, (# targets) do
		do
			if (context.victims_count >= a.max_count) then
				break
			end
			context.victims_count = (context.victims_count + 1)
		end
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[82] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	if ((store.tick_ts - a.ts) > this.actual_duration) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		do
			aura_filter_current = a
			targets = U.find_enemies_in_range_filter_on(this.pos, a.radius, a.vis_flags, a.vis_bans, aura_filter)
			aura_filter_current = nil
		end
	end
	if (not targets) then
		return
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[83] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	if ((store.tick_ts - a.ts) > this.actual_duration) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		do
			targets = U.find_enemies_in_range_filter_off(this.pos, a.radius, a.vis_flags, a.vis_bans)
		end
	end
	if (not targets) then
		return
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[84] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	if ((store.tick_ts - a.ts) > this.actual_duration) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		targets = {}
		for _, v in pairs(store.soldiers) do
			if (((((not v.health.dead) and (band(v.vis.flags, a.vis_bans) == 0)) and (band(v.vis.bans, a.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, a.radius)) and (not table.arraycontains(a.excluded_templates, v.template_name))) then
				targets[((# targets) + 1)] = v
			end
		end
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[85] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	if ((store.tick_ts - a.ts) > this.actual_duration) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		targets = {}
		for _, v in pairs(store.soldiers) do
			if ((((not v.health.dead) and (band(v.vis.flags, a.vis_bans) == 0)) and (band(v.vis.bans, a.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, a.radius)) then
				targets[((# targets) + 1)] = v
			end
		end
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[86] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		do
			targets = U.find_enemies_in_range_filter_off(this.pos, a.radius, a.vis_flags, a.vis_bans)
		end
	end
	if (not targets) then
		return
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[87] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		targets = {}
		for _, v in pairs(store.entities) do
			if (((((((v.unit and v.vis) and v.health) and (not v.health.dead)) and (band(v.vis.flags, a.vis_bans) == 0)) and (band(v.vis.bans, a.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, a.radius)) and table.arraycontains(a.allowed_templates, v.template_name)) then
				targets[((# targets) + 1)] = v
			end
		end
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[88] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		targets = {}
		for _, v in pairs(store.entities) do
			if ((((((v.unit and v.vis) and v.health) and (not v.health.dead)) and (band(v.vis.flags, a.vis_bans) == 0)) and (band(v.vis.bans, a.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, a.radius)) then
				targets[((# targets) + 1)] = v
			end
		end
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[89] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		targets = {}
		for _, v in pairs(store.soldiers) do
			if ((((not v.health.dead) and (band(v.vis.flags, a.vis_bans) == 0)) and (band(v.vis.bans, a.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, a.radius)) then
				targets[((# targets) + 1)] = v
			end
		end
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[90] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				context.ps_instances = {}
				do
					local i = 1
					local ps = E:create_entity(this.ps_names[i])
					do
						ps.particle_system.emit_area_spread = V.vv(a.radius)
					end
					ps.particle_system.track_id = this.id
					simulation:queue_insert_entity(ps)
					context.ps_instances[i] = ps
				end
				do
					local i = 2
					local ps = E:create_entity(this.ps_names[i])
					do
						ps.particle_system.emit_area_spread = V.vv(a.radius)
					end
					ps.particle_system.track_id = this.id
					simulation:queue_insert_entity(ps)
					context.ps_instances[i] = ps
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	if ((store.tick_ts - a.ts) > this.actual_duration) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		do
			targets = U.find_enemies_in_range_filter_off(this.pos, a.radius, a.vis_flags, a.vis_bans)
		end
	end
	if (not targets) then
		return
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[91] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	do
		local source = store.entities[a.source_id]
		if ((not source) or (source.health and source.health.dead)) then
			do
				simulation:queue_remove_entity(this)
			end
			return
		end
		if ((source and source.enemy) and (not source.enemy.can_do_magic)) then
			this.render.sprites[1].hidden = (not source.enemy.can_do_magic)
			return
		end
		if ((source and source.vis) and (band(source.vis.bans, a.source_vis_flags) ~= 0)) then
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	do
		this.render.sprites[a.cast_resets_sprite_id].ts = store.tick_ts
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		do
			aura_filter_current = a
			targets = U.find_enemies_in_range_filter_on(this.pos, a.radius, a.vis_flags, a.vis_bans, aura_filter)
			aura_filter_current = nil
		end
	end
	if (not targets) then
		return
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[92] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	do
		local source = store.entities[a.source_id]
		if ((not source) or (source.health and source.health.dead)) then
			do
				simulation:queue_remove_entity(this)
			end
			return
		end
		if ((source and source.enemy) and (not source.enemy.can_do_magic)) then
			this.render.sprites[1].hidden = (not source.enemy.can_do_magic)
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		do
			aura_filter_current = a
			targets = U.find_enemies_in_range_filter_on(this.pos, a.radius, a.vis_flags, a.vis_bans, aura_filter)
			aura_filter_current = nil
		end
	end
	if (not targets) then
		return
	end
	for i = 1, (# targets) do
		if (i > a.targets_per_cycle) then
			break
		end
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[93] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	do
		local source = store.entities[a.source_id]
		if ((not source) or (source.health and source.health.dead)) then
			do
				simulation:queue_remove_entity(this)
			end
			return
		end
		if ((source and source.enemy) and (not source.enemy.can_do_magic)) then
			this.render.sprites[1].hidden = (not source.enemy.can_do_magic)
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		do
			aura_filter_current = a
			targets = U.find_enemies_in_range_filter_on(this.pos, a.radius, a.vis_flags, a.vis_bans, aura_filter)
			aura_filter_current = nil
		end
	end
	if (not targets) then
		return
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[94] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	do
		local source = store.entities[a.source_id]
		if ((not source) or (source.health and source.health.dead)) then
			do
				simulation:queue_remove_entity(this)
			end
			return
		end
		if ((source and source.enemy) and (not source.enemy.can_do_magic)) then
			this.render.sprites[1].hidden = (not source.enemy.can_do_magic)
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		do
			targets = U.find_enemies_in_range_filter_off(this.pos, a.radius, a.vis_flags, a.vis_bans)
		end
	end
	if (not targets) then
		return
	end
	for i = 1, (# targets) do
		if (i > a.targets_per_cycle) then
			break
		end
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			if (target.id == a.source_id) then
				new_mod.render = nil
			end
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[95] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	do
		local source = store.entities[a.source_id]
		if ((not source) or (source.health and source.health.dead)) then
			do
				simulation:queue_remove_entity(this)
			end
			return
		end
		if ((source and source.enemy) and (not source.enemy.can_do_magic)) then
			this.render.sprites[1].hidden = (not source.enemy.can_do_magic)
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		do
			targets = U.find_enemies_in_range_filter_off(this.pos, a.radius, a.vis_flags, a.vis_bans)
		end
	end
	if (not targets) then
		return
	end
	for i = 1, (# targets) do
		if (i > a.targets_per_cycle) then
			break
		end
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[96] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	do
		local source = store.entities[a.source_id]
		if ((not source) or (source.health and source.health.dead)) then
			do
				simulation:queue_remove_entity(this)
			end
			return
		end
		if ((source and source.enemy) and (not source.enemy.can_do_magic)) then
			this.render.sprites[1].hidden = (not source.enemy.can_do_magic)
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		targets = {}
		for _, v in pairs(store.soldiers) do
			if (((((not v.health.dead) and (band(v.vis.flags, a.vis_bans) == 0)) and (band(v.vis.bans, a.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, a.radius)) and table.arraycontains(a.allowed_templates, v.template_name)) then
				targets[((# targets) + 1)] = v
			end
		end
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[97] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	do
		local source = store.entities[a.source_id]
		if ((not source) or (source.health and source.health.dead)) then
			do
				simulation:queue_remove_entity(this)
			end
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		targets = {}
		for _, v in pairs(store.entities) do
			if (((((((v.unit and v.vis) and v.health) and (not v.health.dead)) and (band(v.vis.flags, a.vis_bans) == 0)) and (band(v.vis.bans, a.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, a.radius)) and table.arraycontains(a.allowed_templates, v.template_name)) then
				targets[((# targets) + 1)] = v
			end
		end
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[98] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	do
		local source = store.entities[a.source_id]
		if ((not source) or (source.health and source.health.dead)) then
			do
				simulation:queue_remove_entity(this)
			end
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		targets = {}
		for _, v in pairs(store.soldiers) do
			if (((((not v.health.dead) and (band(v.vis.flags, a.vis_bans) == 0)) and (band(v.vis.bans, a.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, a.radius)) and (not table.arraycontains(a.excluded_templates, v.template_name))) then
				targets[((# targets) + 1)] = v
			end
		end
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[99] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	do
		local source = store.entities[a.source_id]
		if ((not source) or (source.health and source.health.dead)) then
			do
				simulation:queue_remove_entity(this)
			end
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		targets = {}
		for _, v in pairs(store.soldiers) do
			if ((((not v.health.dead) and (band(v.vis.flags, a.vis_bans) == 0)) and (band(v.vis.bans, a.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, a.radius)) then
				targets[((# targets) + 1)] = v
			end
		end
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[100] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	do
		local source = store.entities[a.source_id]
		if ((source and source.health) and source.health.dead) then
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		do
			aura_filter_current = a
			targets = U.find_enemies_in_range_filter_on(this.pos, a.radius, a.vis_flags, a.vis_bans, aura_filter)
			aura_filter_current = nil
		end
	end
	if (not targets) then
		return
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[101] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	do
		local source = store.entities[a.source_id]
		if ((source and source.health) and source.health.dead) then
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		do
			targets = U.find_enemies_in_range_filter_off(this.pos, a.radius, a.vis_flags, a.vis_bans)
		end
	end
	if (not targets) then
		return
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[102] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	if ((store.tick_ts - a.ts) > this.actual_duration) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	do
		local source = store.entities[a.source_id]
		if ((not source) or (source.health and source.health.dead)) then
			do
				simulation:queue_remove_entity(this)
			end
			return
		end
		if ((source and source.enemy) and (not source.enemy.can_do_magic)) then
			this.render.sprites[1].hidden = (not source.enemy.can_do_magic)
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		do
			targets = U.find_enemies_in_range_filter_off(this.pos, a.radius, a.vis_flags, a.vis_bans)
		end
	end
	if (not targets) then
		return
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[103] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	if ((store.tick_ts - a.ts) > this.actual_duration) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	do
		local source = store.entities[a.source_id]
		if ((not source) or (source.health and source.health.dead)) then
			do
				simulation:queue_remove_entity(this)
			end
			return
		end
		if ((source and source.enemy) and (not source.enemy.can_do_magic)) then
			this.render.sprites[1].hidden = (not source.enemy.can_do_magic)
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		targets = {}
		for _, v in pairs(store.entities) do
			if ((((((v.unit and v.vis) and v.health) and (not v.health.dead)) and (band(v.vis.flags, a.vis_bans) == 0)) and (band(v.vis.bans, a.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, a.radius)) then
				targets[((# targets) + 1)] = v
			end
		end
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[104] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	if ((store.tick_ts - a.ts) > this.actual_duration) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	do
		local source = store.entities[a.source_id]
		if ((not source) or (source.health and source.health.dead)) then
			do
				simulation:queue_remove_entity(this)
			end
			return
		end
		if ((source and source.enemy) and (not source.enemy.can_do_magic)) then
			this.render.sprites[1].hidden = (not source.enemy.can_do_magic)
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		targets = {}
		for _, v in pairs(store.soldiers) do
			if ((((not v.health.dead) and (band(v.vis.flags, a.vis_bans) == 0)) and (band(v.vis.bans, a.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, a.radius)) then
				targets[((# targets) + 1)] = v
			end
		end
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[105] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	if ((store.tick_ts - a.ts) > this.actual_duration) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	do
		local source = store.entities[a.source_id]
		if ((not source) or (source.health and source.health.dead)) then
			do
				simulation:queue_remove_entity(this)
			end
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		do
			aura_filter_current = a
			targets = U.find_enemies_in_range_filter_on(this.pos, a.radius, a.vis_flags, a.vis_bans, aura_filter)
			aura_filter_current = nil
		end
	end
	if (not targets) then
		return
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[106] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	if ((store.tick_ts - a.ts) > this.actual_duration) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	do
		local source = store.entities[a.source_id]
		if ((not source) or (source.health and source.health.dead)) then
			do
				simulation:queue_remove_entity(this)
			end
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		do
			targets = U.find_enemies_in_range_filter_off(this.pos, a.radius, a.vis_flags, a.vis_bans)
		end
	end
	if (not targets) then
		return
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[107] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	if ((store.tick_ts - a.ts) > this.actual_duration) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	do
		local source = store.entities[a.source_id]
		if ((not source) or (source.health and source.health.dead)) then
			do
				simulation:queue_remove_entity(this)
			end
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		targets = {}
		for _, v in pairs(store.entities) do
			if ((((((v.unit and v.vis) and v.health) and (not v.health.dead)) and (band(v.vis.flags, a.vis_bans) == 0)) and (band(v.vis.bans, a.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, a.radius)) then
				targets[((# targets) + 1)] = v
			end
		end
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[108] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	if ((store.tick_ts - a.ts) > this.actual_duration) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	do
		local source = store.entities[a.source_id]
		if ((not source) or (source.health and source.health.dead)) then
			do
				simulation:queue_remove_entity(this)
			end
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		targets = {}
		for _, v in pairs(store.soldiers) do
			if ((((not v.health.dead) and (band(v.vis.flags, a.vis_bans) == 0)) and (band(v.vis.bans, a.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, a.radius)) then
				targets[((# targets) + 1)] = v
			end
		end
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[109] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		do
			targets = U.find_enemies_in_range_filter_off(this.pos, a.radius, a.vis_flags, a.vis_bans)
		end
	end
	if (not targets) then
		return
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[110] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local source = store.entities[a.source_id]
				if (source and source.pos) then
					this.pos = source.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		targets = {}
		for _, v in pairs(store.soldiers) do
			if ((((not v.health.dead) and (band(v.vis.flags, a.vis_bans) == 0)) and (band(v.vis.bans, a.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, a.radius)) then
				targets[((# targets) + 1)] = v
			end
		end
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[111] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.state = 1
			do
				local target = store.entities[a.target_id]
				if (target and target.pos) then
					this.pos = target.pos
				end
			end
			do
				context.last_hit_ts = (store.tick_ts - a.cycle_time)
			end
			context.mods = (a.mods or {a.mod})
		end
	end
	if this.interrupt then
		context.last_hit_ts = 1e+99
	end
	if ((store.tick_ts - a.ts) > this.actual_duration) then
		do
			simulation:queue_remove_entity(this)
		end
		return
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= a.cycle_time)
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	local targets
	do
		do
			targets = U.find_enemies_in_range_filter_off(this.pos, a.radius, a.vis_flags, a.vis_bans)
		end
	end
	if (not targets) then
		return
	end
	for i = 1, (# targets) do
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = a.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = a.damage_factor
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	[112] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		this.aura.ts = store.tick_ts
		context.last_hit_ts = 0
		context.cycles_count = 0
		context.state = 1
	end
	do
		if (context.cycles_count >= this.aura.cycles) then
			simulation:queue_remove_entity(this)
			return
		end
	end
	do
		local te = store.entities[this.aura.source_id]
		if (((not te) or (te.health and te.health.dead)) or (te.enemy and (not te.enemy.can_do_magic))) then
			simulation:queue_remove_entity(this)
			return
		end
		if te.pos then
			this.pos.x, this.pos.y = te.pos.x, te.pos.y
		end
	end
	if ((store.tick_ts - context.last_hit_ts) >= this.aura.cycle_time) then
		do
			context.cycles_count = (context.cycles_count + 1)
		end
		context.last_hit_ts = store.tick_ts
		local targets
		do
			targets = {}
			for _, v in pairs(store.entities) do
				if ((((((v.unit and v.vis) and v.health) and (not v.health.dead)) and (band(v.vis.flags, this.aura.vis_bans) == 0)) and (band(v.vis.bans, this.aura.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)) then
					targets[((# targets) + 1)] = v
				end
			end
		end
		if ((# targets) > 0) then
			local dmin, dmax = this.aura.damage_min, this.aura.damage_max
			local mods = (this.aura.mods or {this.aura.mod})
			local mod_count = (# mods)
			for i = 1, (# targets) do
				local target = targets[i]
				local d = E.assign_damage(this.aura.damage_type, (math.random(dmin, dmax) * this.aura.damage_factor), this.id, target.id)
				d.track_damage = this.aura.track_damage
				d.xp_dest_id = this.aura.xp_dest_id
				d.xp_gain_factor = this.aura.xp_gain_factor
				queue_damage(store, d)
				for j = 1, mod_count do
					local m = E:create_entity(mods[j])
					m.modifier.level = this.aura.level
					m.modifier.target_id = target.id
					m.modifier.source_id = this.id
					m.modifier.damage_factor = this.aura.damage_factor
					simulation:queue_insert_entity(m)
				end
			end
		end
	end
end
,
	[113] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		this.aura.ts = store.tick_ts
		context.last_hit_ts = 0
		context.cycles_count = 0
		context.state = 1
	end
	do
		if (context.cycles_count >= this.aura.cycles) then
			simulation:queue_remove_entity(this)
			return
		end
	end
	if ((store.tick_ts - context.last_hit_ts) >= this.aura.cycle_time) then
		do
			context.cycles_count = (context.cycles_count + 1)
		end
		context.last_hit_ts = store.tick_ts
		local targets
		do
			do
				targets = U.find_enemies_in_range_filter_off(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)
			end
		end
		if (not targets) then
			return
		end
	end
end
,
	[114] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		this.aura.ts = store.tick_ts
		context.last_hit_ts = 0
		context.cycles_count = 0
		context.state = 1
	end
	do
		if (context.cycles_count >= this.aura.cycles) then
			simulation:queue_remove_entity(this)
			return
		end
	end
	if ((store.tick_ts - context.last_hit_ts) >= this.aura.cycle_time) then
		do
			context.cycles_count = (context.cycles_count + 1)
		end
		context.last_hit_ts = store.tick_ts
		local targets
		do
			targets = {}
			for _, v in pairs(store.entities) do
				if (((((((v.unit and v.vis) and v.health) and (not v.health.dead)) and (band(v.vis.flags, this.aura.vis_bans) == 0)) and (band(v.vis.bans, this.aura.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)) and (not table.arraycontains(this.aura.excluded_templates, v.template_name))) then
					targets[((# targets) + 1)] = v
				end
			end
		end
		if ((# targets) > 0) then
			local dmin, dmax = this.aura.damage_min, this.aura.damage_max
			local mods = (this.aura.mods or {this.aura.mod})
			local mod_count = (# mods)
			for i = 1, (# targets) do
				local target = targets[i]
				local d = E.assign_damage(this.aura.damage_type, (math.random(dmin, dmax) * this.aura.damage_factor), this.id, target.id)
				d.track_damage = this.aura.track_damage
				d.xp_dest_id = this.aura.xp_dest_id
				d.xp_gain_factor = this.aura.xp_gain_factor
				queue_damage(store, d)
				for j = 1, mod_count do
					local m = E:create_entity(mods[j])
					m.modifier.level = this.aura.level
					m.modifier.target_id = target.id
					m.modifier.source_id = this.id
					m.modifier.damage_factor = this.aura.damage_factor
					simulation:queue_insert_entity(m)
				end
			end
		end
	end
end
,
	[115] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		this.aura.ts = store.tick_ts
		context.last_hit_ts = 0
		context.cycles_count = 0
		context.state = 1
	end
	do
		if (context.cycles_count >= this.aura.cycles) then
			simulation:queue_remove_entity(this)
			return
		end
	end
	if ((store.tick_ts - context.last_hit_ts) >= this.aura.cycle_time) then
		do
			context.cycles_count = (context.cycles_count + 1)
		end
		context.last_hit_ts = store.tick_ts
		local targets
		do
			targets = {}
			for _, v in pairs(store.soldiers) do
				if (((((not v.health.dead) and (band(v.vis.flags, this.aura.vis_bans) == 0)) and (band(v.vis.bans, this.aura.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)) and (not table.arraycontains(this.aura.excluded_templates, v.template_name))) then
					targets[((# targets) + 1)] = v
				end
			end
		end
		if ((# targets) > 0) then
			local dmin, dmax = this.aura.damage_min, this.aura.damage_max
			local mods = (this.aura.mods or {this.aura.mod})
			local mod_count = (# mods)
			for i = 1, (# targets) do
				local target = targets[i]
				local d = E.assign_damage(this.aura.damage_type, (math.random(dmin, dmax) * this.aura.damage_factor), this.id, target.id)
				d.track_damage = this.aura.track_damage
				d.xp_dest_id = this.aura.xp_dest_id
				d.xp_gain_factor = this.aura.xp_gain_factor
				queue_damage(store, d)
				for j = 1, mod_count do
					local m = E:create_entity(mods[j])
					m.modifier.level = this.aura.level
					m.modifier.target_id = target.id
					m.modifier.source_id = this.id
					m.modifier.damage_factor = this.aura.damage_factor
					simulation:queue_insert_entity(m)
				end
			end
		end
	end
end
,
	[116] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		this.aura.ts = store.tick_ts
		context.last_hit_ts = 0
		context.cycles_count = 0
		context.state = 1
	end
	do
		if (context.cycles_count >= this.aura.cycles) then
			simulation:queue_remove_entity(this)
			return
		end
	end
	if ((store.tick_ts - context.last_hit_ts) >= this.aura.cycle_time) then
		do
			context.cycles_count = (context.cycles_count + 1)
		end
		context.last_hit_ts = store.tick_ts
		local targets
		do
			targets = {}
			for _, v in pairs(store.soldiers) do
				if ((((not v.health.dead) and (band(v.vis.flags, this.aura.vis_bans) == 0)) and (band(v.vis.bans, this.aura.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)) then
					targets[((# targets) + 1)] = v
				end
			end
		end
		if ((# targets) > 0) then
			local dmin, dmax = this.aura.damage_min, this.aura.damage_max
			local mods = (this.aura.mods or {this.aura.mod})
			local mod_count = (# mods)
			for i = 1, (# targets) do
				local target = targets[i]
				local d = E.assign_damage(this.aura.damage_type, (math.random(dmin, dmax) * this.aura.damage_factor), this.id, target.id)
				d.track_damage = this.aura.track_damage
				d.xp_dest_id = this.aura.xp_dest_id
				d.xp_gain_factor = this.aura.xp_gain_factor
				queue_damage(store, d)
				for j = 1, mod_count do
					local m = E:create_entity(mods[j])
					m.modifier.level = this.aura.level
					m.modifier.target_id = target.id
					m.modifier.source_id = this.id
					m.modifier.damage_factor = this.aura.damage_factor
					simulation:queue_insert_entity(m)
				end
			end
		end
	end
end
,
	[117] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		this.aura.ts = store.tick_ts
		context.last_hit_ts = 0
		context.cycles_count = 0
		context.state = 1
	end
	do
		local te = store.entities[this.aura.source_id]
		if (((not te) or (te.health and te.health.dead)) or (te.enemy and (not te.enemy.can_do_magic))) then
			simulation:queue_remove_entity(this)
			return
		end
		if te.pos then
			this.pos.x, this.pos.y = te.pos.x, te.pos.y
		end
	end
	if ((store.tick_ts - context.last_hit_ts) >= this.aura.cycle_time) then
		context.last_hit_ts = store.tick_ts
		local targets
		do
			do
				targets = U.find_enemies_in_range_filter_off(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)
			end
		end
		if (not targets) then
			return
		end
	end
end
,
	[118] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		this.aura.ts = store.tick_ts
		context.last_hit_ts = 0
		context.cycles_count = 0
		context.state = 1
	end
	do
		local te = store.entities[this.aura.source_id]
		if (((not te) or (te.health and te.health.dead)) or (te.enemy and (not te.enemy.can_do_magic))) then
			simulation:queue_remove_entity(this)
			return
		end
		if te.pos then
			this.pos.x, this.pos.y = te.pos.x, te.pos.y
		end
	end
	if ((store.tick_ts - context.last_hit_ts) >= this.aura.cycle_time) then
		context.last_hit_ts = store.tick_ts
		local targets
		do
			targets = {}
			for _, v in pairs(store.soldiers) do
				if ((((not v.health.dead) and (band(v.vis.flags, this.aura.vis_bans) == 0)) and (band(v.vis.bans, this.aura.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)) then
					targets[((# targets) + 1)] = v
				end
			end
		end
		if ((# targets) > 0) then
			local dmin, dmax = this.aura.damage_min, this.aura.damage_max
			local mods = (this.aura.mods or {this.aura.mod})
			local mod_count = (# mods)
			for i = 1, (# targets) do
				local target = targets[i]
				local d = E.assign_damage(this.aura.damage_type, (math.random(dmin, dmax) * this.aura.damage_factor), this.id, target.id)
				d.track_damage = this.aura.track_damage
				d.xp_dest_id = this.aura.xp_dest_id
				d.xp_gain_factor = this.aura.xp_gain_factor
				queue_damage(store, d)
				for j = 1, mod_count do
					local m = E:create_entity(mods[j])
					m.modifier.level = this.aura.level
					m.modifier.target_id = target.id
					m.modifier.source_id = this.id
					m.modifier.damage_factor = this.aura.damage_factor
					simulation:queue_insert_entity(m)
				end
			end
		end
	end
end
,
	[119] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		this.aura.ts = store.tick_ts
		do
			this.aura.duration = (this.aura.duration + (this.aura.level * this.aura.duration_inc))
		end
		context.last_hit_ts = 0
		context.cycles_count = 0
		context.state = 1
	end
	do
		if ((store.tick_ts - this.aura.ts) >= this.aura.duration) then
			simulation:queue_remove_entity(this)
			return
		end
	end
	do
		local te = store.entities[this.aura.source_id]
		if (((not te) or (te.health and te.health.dead)) or (te.enemy and (not te.enemy.can_do_magic))) then
			simulation:queue_remove_entity(this)
			return
		end
		if te.pos then
			this.pos.x, this.pos.y = te.pos.x, te.pos.y
		end
	end
	if ((store.tick_ts - context.last_hit_ts) >= this.aura.cycle_time) then
		context.last_hit_ts = store.tick_ts
		local targets
		do
			targets = {}
			for _, v in pairs(store.soldiers) do
				if ((((not v.health.dead) and (band(v.vis.flags, this.aura.vis_bans) == 0)) and (band(v.vis.bans, this.aura.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)) then
					targets[((# targets) + 1)] = v
				end
			end
		end
		if ((# targets) > 0) then
			local dmin, dmax = this.aura.damage_min, this.aura.damage_max
			local mods = (this.aura.mods or {this.aura.mod})
			local mod_count = (# mods)
			for i = 1, (# targets) do
				local target = targets[i]
				local d = E.assign_damage(this.aura.damage_type, (math.random(dmin, dmax) * this.aura.damage_factor), this.id, target.id)
				d.track_damage = this.aura.track_damage
				d.xp_dest_id = this.aura.xp_dest_id
				d.xp_gain_factor = this.aura.xp_gain_factor
				queue_damage(store, d)
				for j = 1, mod_count do
					local m = E:create_entity(mods[j])
					m.modifier.level = this.aura.level
					m.modifier.target_id = target.id
					m.modifier.source_id = this.id
					m.modifier.damage_factor = this.aura.damage_factor
					simulation:queue_insert_entity(m)
				end
			end
		end
	end
end
,
	[120] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		this.aura.ts = store.tick_ts
		do
			this.aura.duration = (this.aura.duration + (this.aura.level * this.aura.duration_inc))
		end
		context.last_hit_ts = 0
		context.cycles_count = 0
		context.state = 1
	end
	do
		if ((store.tick_ts - this.aura.ts) >= this.aura.duration) then
			simulation:queue_remove_entity(this)
			return
		end
	end
	if ((store.tick_ts - context.last_hit_ts) >= this.aura.cycle_time) then
		context.last_hit_ts = store.tick_ts
		local targets
		do
			do
				targets = U.find_enemies_in_range_filter_off(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)
			end
		end
		if (not targets) then
			return
		end
	end
end
,
	[121] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		this.aura.ts = store.tick_ts
		do
			this.aura.duration = (this.aura.duration + (this.aura.level * this.aura.duration_inc))
		end
		context.last_hit_ts = 0
		context.cycles_count = 0
		context.state = 1
	end
	do
		if ((store.tick_ts - this.aura.ts) >= this.aura.duration) then
			simulation:queue_remove_entity(this)
			return
		end
	end
	if ((store.tick_ts - context.last_hit_ts) >= this.aura.cycle_time) then
		context.last_hit_ts = store.tick_ts
		local targets
		do
			targets = {}
			for _, v in pairs(store.soldiers) do
				if ((((not v.health.dead) and (band(v.vis.flags, this.aura.vis_bans) == 0)) and (band(v.vis.bans, this.aura.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)) then
					targets[((# targets) + 1)] = v
				end
			end
		end
		if ((# targets) > 0) then
			local dmin, dmax = this.aura.damage_min, this.aura.damage_max
			local mods = (this.aura.mods or {this.aura.mod})
			local mod_count = (# mods)
			for i = 1, (# targets) do
				local target = targets[i]
				local d = E.assign_damage(this.aura.damage_type, (math.random(dmin, dmax) * this.aura.damage_factor), this.id, target.id)
				d.track_damage = this.aura.track_damage
				d.xp_dest_id = this.aura.xp_dest_id
				d.xp_gain_factor = this.aura.xp_gain_factor
				queue_damage(store, d)
				for j = 1, mod_count do
					local m = E:create_entity(mods[j])
					m.modifier.level = this.aura.level
					m.modifier.target_id = target.id
					m.modifier.source_id = this.id
					m.modifier.damage_factor = this.aura.damage_factor
					simulation:queue_insert_entity(m)
				end
			end
		end
	end
end
,
	[122] = function(this, store)
	local b = this.bullet
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)
	do
		this.render.sprites[1].hidden = true
	end
	return true
end
,
	[123] = function(this, store)
	local b = this.bullet
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)
	do
		this.render.sprites[1].r = (((math.random() - 0.5)) * math.pi)
		b.rotation_speed = (b.rotation_speed * ((((b.to.x > b.from.x) and (- 1)) or 1)))
	end
	do
		this.render.sprites[1].hidden = true
	end
	return true
end
,
	[124] = function(this, store)
	local b = this.bullet
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)
	do
		this.render.sprites[1].r = (((math.random() - 0.5)) * math.pi)
		b.rotation_speed = (b.rotation_speed * ((((b.to.x > b.from.x) and (- 1)) or 1)))
	end
	return true
end
,
	[125] = function(this, store)
	local b = this.bullet
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)
	return true
end
,
	[126] = function(this, store)
	local b = this.bullet
	if b.target_id then
		local target = store.entities[b.target_id]
		if ((not target) or (target.vis and (band(target.vis.bans, F_RANGED) ~= 0))) then
			return false
		end
	end
	b.speed.x, b.speed.y = V.normalize((b.to.x - b.from.x), (b.to.y - b.from.y))
	local s = this.render.sprites[1]
	__pc_helpers["__pc_bolt_1_insert_1"](this, "flying", nil, store.tick_ts, s.loop)
	return true
end
,
	[127] = function(this, store)
	local b = this.bullet
	if b.target_id then
		local target = store.entities[b.target_id]
		if ((not target) or (target.vis and (band(target.vis.bans, F_RANGED) ~= 0))) then
			return false
		end
	end
	b.speed.x, b.speed.y = V.normalize((b.to.x - b.from.x), (b.to.y - b.from.y))
	local s = this.render.sprites[1]
	do
		s.r = V.angleTo((b.to.x - this.pos.x), (b.to.y - this.pos.y))
	end
	__pc_helpers["__pc_bolt_1_insert_1"](this, "flying", nil, store.tick_ts, s.loop)
	return true
end
,
	[128] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[129] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[130] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[131] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = math.atan2(context.v_y, context.v_x)
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[132] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[133] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[134] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[135] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[136] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		do
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = math.atan2(context.v_y, context.v_x)
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[137] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		do
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[138] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[139] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[140] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[141] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[142] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = math.atan2(context.v_y, context.v_x)
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[143] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[144] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[145] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[146] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[147] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = math.atan2(context.v_y, context.v_x)
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[148] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[149] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			if b._hit_offset_record then
				local hit_pos = V.vclone(this.pos)
				hit_pos.x = (hit_pos.x - b._hit_offset_record.x)
				hit_pos.y = (hit_pos.y - b._hit_offset_record.y)
				enemies = U.find_enemies_in_range_filter_off(hit_pos, context.dradius, b.damage_flags, b.damage_bans)
			else
				enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
			end
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[150] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			if b._hit_offset_record then
				local hit_pos = V.vclone(this.pos)
				hit_pos.x = (hit_pos.x - b._hit_offset_record.x)
				hit_pos.y = (hit_pos.y - b._hit_offset_record.y)
				enemies = U.find_enemies_in_range_filter_off(hit_pos, context.dradius, b.damage_flags, b.damage_bans)
			else
				enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
			end
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[151] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			if b._hit_offset_record then
				local hit_pos = V.vclone(this.pos)
				hit_pos.x = (hit_pos.x - b._hit_offset_record.x)
				hit_pos.y = (hit_pos.y - b._hit_offset_record.y)
				enemies = U.find_enemies_in_range_filter_off(hit_pos, context.dradius, b.damage_flags, b.damage_bans)
			else
				enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
			end
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		do
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[152] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			context.dmin = (context.dmin + (b.level * b.damage_min_inc))
		end
		do
			context.dmax = (context.dmax + (b.level * b.damage_max_inc))
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[153] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			context.dmin = (context.dmin + (b.level * b.damage_min_inc))
		end
		do
			context.dmax = (context.dmax + (b.level * b.damage_max_inc))
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[154] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			context.dradius = (context.dradius + (b.level * b.damage_radius_inc))
		end
		do
			context.dmin = (context.dmin + (b.level * b.damage_min_inc))
		end
		do
			context.dmax = (context.dmax + (b.level * b.damage_max_inc))
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[155] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[156] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = math.atan2(context.v_y, context.v_x)
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[157] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[158] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = math.atan2(context.v_y, context.v_x)
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[159] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[160] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = math.atan2(context.v_y, context.v_x)
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[161] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[162] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[163] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = math.atan2(context.v_y, context.v_x)
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[164] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[165] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		do
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = math.atan2(context.v_y, context.v_x)
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[166] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		do
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = math.atan2(context.v_y, context.v_x)
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[167] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		do
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = math.atan2(context.v_y, context.v_x)
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[168] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = math.atan2(context.v_y, context.v_x)
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[169] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[170] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = math.atan2(context.v_y, context.v_x)
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[171] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[172] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = math.atan2(context.v_y, context.v_x)
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[173] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		end
		if (band(cell_type, TERRAIN_WATER) == 0) then
			local decal = E:create_entity(b.hit_decal)
			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(decal)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[174] = function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		context.v_x = b.speed.x
		context.v_y = b.speed.y
		context.last_ts = store.tick_ts
		context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		this.pos.x, this.pos.y = b.from.x, b.from.y
		context.state = 1
	end
	if (store.tick_ts >= context.expected_stop_time) then
		local dt = (context.expected_stop_time - context.last_ts)
		this.pos.x = (this.pos.x + (context.v_x * dt))
		this.pos.y = (this.pos.y + (((context.v_y + ((0.5 * b.g) * dt))) * dt))
		local enemies
		do
			if b._hit_offset_record then
				local hit_pos = V.vclone(this.pos)
				hit_pos.x = (hit_pos.x - b._hit_offset_record.x)
				hit_pos.y = (hit_pos.y - b._hit_offset_record.y)
				enemies = U.find_enemies_in_range_filter_off(hit_pos, context.dradius, b.damage_flags, b.damage_bans)
			else
				enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
			end
		end
		local mods
		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end
		if enemies then
			for i = 1, (# enemies) do
				local enemy = enemies[i]
				local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
				if UP:get_upgrade("engineer_efficiency") then
					d.value = context.dmax
				else
					local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
					d.value = (context.dmax - (((context.dmax - context.dmin)) * dist_factor))
				end
				d.value = (b.damage_factor * d.value)
				queue_damage(store, d)
				if mods then
					for j = 1, (# mods) do
						local mod_name = mods[j]
						if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							mod.modifier.target_id = enemy.id
							mod.modifier.source_id = b.source_id
							mod.modifier.level = b.level
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		do
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		else
			do
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if b.hit_payload then
			local hp = (((type(b.hit_payload) == "string") and E:create_entity(b.hit_payload)) or b.hit_payload)
			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
			hp.source_id = b.source_id
			if hp.unit then
				hp.unit.damage_factor = (b.damage_factor * hp.unit.damage_factor)
				if ((hp.nav_rally and (hp.nav_rally.pos.x == 0)) and (hp.nav_rally.pos.y == 0)) then
					hp.nav_rally.pos:copy(hp.pos)
					hp.nav_rally.center:copy(hp.pos)
				end
			end
			if hp.aura then
				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = (b.damage_factor * hp.aura.damage_factor)
			end
			simulation:queue_insert_entity(hp)
		end
		simulation:queue_remove_entity(this)
		return
	end
	local dt = (store.tick_ts - context.last_ts)
	local dv_y = (b.g * dt)
	this.pos.x = (this.pos.x + (context.v_x * dt))
	this.pos.y = (this.pos.y + (((context.v_y + dv_y)) * dt))
	do
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	do
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	[175] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local context = this.main_script.context
	if (context.state == 0) then
		context.mspeed = b.min_speed
		context.new_target = false
		context.target_invalid = false
		do
			context.state = 1
		end
	end
	if (context.state == 1) then
		s.z = Z_BULLETS
		s.sort_y_offset = nil
		__pc_helpers["__pc_bolt_1_insert_1"](this, "flying", nil, store.tick_ts, s.loop)
		context.state = 3
	end
	if (context.state == 2) then
		if b.target_id then
			context.mspeed = b.min_speed
			context.new_target = true
			context.target_invalid = false
			context.state = 1
		else
			return
		end
	end
	local arrived = (V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) <= (context.mspeed * store.tick_length))
	if arrived then
		this.pos.x, this.pos.y = b.to.x, b.to.y
		local target = store.entities[b.target_id]
		if (target and (not target.health.dead)) then
			local d = SU.create_bullet_damage(b, target.id, this.id)
			queue_damage(store, d)
			local mods = (b.mods or ((b.mod and {b.mod})))
			if mods then
				for k = 1, (# mods) do
					local m = E:create_entity(mods[k])
					m.modifier.target_id = b.target_id
					m.modifier.source_id = b.source_id
					m.modifier.damage_factor = b.damage_factor
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
		do
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].runs = 0
			simulation:queue_insert_entity(sfx)
		end
		simulation:queue_remove_entity(this)
	end
	local target
	if (not context.target_invalid) then
		target = store.entities[b.target_id]
	end
	if false then
		local tpx, tpy = target.pos.x, target.pos.y
		do
			tpx, tpy = (tpx + target.unit.hit_offset.x), (tpy + target.unit.hit_offset.y)
		end
		if ((math.max(math.abs((tpx - b.to.x)), math.abs((tpy - b.to.y))) > b.max_track_distance) or (band(target.vis.bans, F_RANGED) ~= 0)) then
			context.target_invalid = true
			target = nil
		end
	end
	context.mspeed = (context.mspeed + (FPS * math.ceil(((context.mspeed * ((1 / FPS))) * b.acceleration_factor))))
	context.mspeed = km.clamp(b.min_speed, b.max_speed, context.mspeed)
	b.speed.x, b.speed.y = V.mul(context.mspeed, V.normalize((b.to.x - this.pos.x), (b.to.y - this.pos.y)))
	this.pos.x = (this.pos.x + (b.speed.x * store.tick_length))
	this.pos.y = (this.pos.y + (b.speed.y * store.tick_length))
	do
		s.r = V.angleTo((b.to.x - this.pos.x), (b.to.y - this.pos.y))
	end
end
,
	[176] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local context = this.main_script.context
	if (context.state == 0) then
		context.mspeed = b.min_speed
		context.new_target = false
		context.target_invalid = false
		do
			context.state = 1
		end
	end
	if (context.state == 1) then
		s.z = Z_BULLETS
		s.sort_y_offset = nil
		__pc_helpers["__pc_bolt_1_insert_1"](this, "flying", nil, store.tick_ts, s.loop)
		context.state = 3
	end
	if (context.state == 2) then
		if b.target_id then
			context.mspeed = b.min_speed
			context.new_target = true
			context.target_invalid = false
			context.state = 1
		else
			return
		end
	end
	local arrived = (V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) <= (context.mspeed * store.tick_length))
	if arrived then
		this.pos.x, this.pos.y = b.to.x, b.to.y
		local target = store.entities[b.target_id]
		if (target and (not target.health.dead)) then
			local d = SU.create_bullet_damage(b, target.id, this.id)
			queue_damage(store, d)
			local mods = (b.mods or ((b.mod and {b.mod})))
			if mods then
				for k = 1, (# mods) do
					local m = E:create_entity(mods[k])
					m.modifier.target_id = b.target_id
					m.modifier.source_id = b.source_id
					m.modifier.damage_factor = b.damage_factor
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
		simulation:queue_remove_entity(this)
	end
	local target
	if (not context.target_invalid) then
		target = store.entities[b.target_id]
	end
	if false then
		local tpx, tpy = target.pos.x, target.pos.y
		do
			tpx, tpy = (tpx + target.unit.hit_offset.x), (tpy + target.unit.hit_offset.y)
		end
		if ((math.max(math.abs((tpx - b.to.x)), math.abs((tpy - b.to.y))) > b.max_track_distance) or (band(target.vis.bans, F_RANGED) ~= 0)) then
			context.target_invalid = true
			target = nil
		end
	end
	context.mspeed = (context.mspeed + (FPS * math.ceil(((context.mspeed * ((1 / FPS))) * b.acceleration_factor))))
	context.mspeed = km.clamp(b.min_speed, b.max_speed, context.mspeed)
	b.speed.x, b.speed.y = V.mul(context.mspeed, V.normalize((b.to.x - this.pos.x), (b.to.y - this.pos.y)))
	this.pos.x = (this.pos.x + (b.speed.x * store.tick_length))
	this.pos.y = (this.pos.y + (b.speed.y * store.tick_length))
	do
		s.r = V.angleTo((b.to.x - this.pos.x), (b.to.y - this.pos.y))
	end
end
,
	[177] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local context = this.main_script.context
	if (context.state == 0) then
		context.mspeed = b.min_speed
		context.new_target = false
		context.target_invalid = false
		do
			context.state = 1
		end
	end
	if (context.state == 1) then
		s.z = Z_BULLETS
		s.sort_y_offset = nil
		__pc_helpers["__pc_bolt_1_insert_1"](this, "flying", nil, store.tick_ts, s.loop)
		context.state = 3
	end
	if (context.state == 2) then
		if b.target_id then
			context.mspeed = b.min_speed
			context.new_target = true
			context.target_invalid = false
			context.state = 1
		else
			return
		end
	end
	local arrived = (V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) <= (context.mspeed * store.tick_length))
	if arrived then
		this.pos.x, this.pos.y = b.to.x, b.to.y
		local target = store.entities[b.target_id]
		if (target and (not target.health.dead)) then
			local d = SU.create_bullet_damage(b, target.id, this.id)
			queue_damage(store, d)
			local mods = (b.mods or ((b.mod and {b.mod})))
			if mods then
				for k = 1, (# mods) do
					local m = E:create_entity(mods[k])
					m.modifier.target_id = b.target_id
					m.modifier.source_id = b.source_id
					m.modifier.damage_factor = b.damage_factor
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
		simulation:queue_remove_entity(this)
	end
	local target
	if (not context.target_invalid) then
		target = store.entities[b.target_id]
	end
	if false then
		local tpx, tpy = target.pos.x, target.pos.y
		do
			tpx, tpy = (tpx + target.unit.hit_offset.x), (tpy + target.unit.hit_offset.y)
		end
		if ((math.max(math.abs((tpx - b.to.x)), math.abs((tpy - b.to.y))) > b.max_track_distance) or (band(target.vis.bans, F_RANGED) ~= 0)) then
			context.target_invalid = true
			target = nil
		end
	end
	context.mspeed = (context.mspeed + (FPS * math.ceil(((context.mspeed * ((1 / FPS))) * b.acceleration_factor))))
	context.mspeed = km.clamp(b.min_speed, b.max_speed, context.mspeed)
	b.speed.x, b.speed.y = V.mul(context.mspeed, V.normalize((b.to.x - this.pos.x), (b.to.y - this.pos.y)))
	this.pos.x = (this.pos.x + (b.speed.x * store.tick_length))
	this.pos.y = (this.pos.y + (b.speed.y * store.tick_length))
end
,
	[178] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local context = this.main_script.context
	if (context.state == 0) then
		context.mspeed = b.min_speed
		context.new_target = false
		context.target_invalid = false
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.state = 1
		end
	end
	if (context.state == 1) then
		do
			S:queue(this.sound_events.travel)
		end
		s.z = Z_BULLETS
		s.sort_y_offset = nil
		__pc_helpers["__pc_bolt_1_insert_1"](this, "flying", nil, store.tick_ts, s.loop)
		do
			context.ps.particle_system.emit = true
		end
		context.state = 3
	end
	if (context.state == 2) then
		if b.target_id then
			context.mspeed = b.min_speed
			context.new_target = true
			context.target_invalid = false
			context.state = 1
		else
			return
		end
	end
	local arrived = (V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) <= (context.mspeed * store.tick_length))
	if arrived then
		this.pos.x, this.pos.y = b.to.x, b.to.y
		local target = store.entities[b.target_id]
		if (target and (not target.health.dead)) then
			local d = SU.create_bullet_damage(b, target.id, this.id)
			queue_damage(store, d)
			local mods = (b.mods or ((b.mod and {b.mod})))
			if mods then
				for k = 1, (# mods) do
					local m = E:create_entity(mods[k])
					m.modifier.target_id = b.target_id
					m.modifier.source_id = b.source_id
					m.modifier.damage_factor = b.damage_factor
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
		do
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].runs = 0
			simulation:queue_insert_entity(sfx)
		end
		simulation:queue_remove_entity(this)
	end
	local target
	if (not context.target_invalid) then
		target = store.entities[b.target_id]
	end
	if false then
		local tpx, tpy = target.pos.x, target.pos.y
		do
			tpx, tpy = (tpx + target.unit.hit_offset.x), (tpy + target.unit.hit_offset.y)
		end
		if ((math.max(math.abs((tpx - b.to.x)), math.abs((tpy - b.to.y))) > b.max_track_distance) or (band(target.vis.bans, F_RANGED) ~= 0)) then
			context.target_invalid = true
			target = nil
		end
	end
	context.mspeed = (context.mspeed + (FPS * math.ceil(((context.mspeed * ((1 / FPS))) * b.acceleration_factor))))
	context.mspeed = km.clamp(b.min_speed, b.max_speed, context.mspeed)
	b.speed.x, b.speed.y = V.mul(context.mspeed, V.normalize((b.to.x - this.pos.x), (b.to.y - this.pos.y)))
	this.pos.x = (this.pos.x + (b.speed.x * store.tick_length))
	this.pos.y = (this.pos.y + (b.speed.y * store.tick_length))
	do
		s.r = V.angleTo((b.to.x - this.pos.x), (b.to.y - this.pos.y))
	end
	do
		context.ps.particle_system.emit_direction = s.r
	end
end
,
	[179] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local context = this.main_script.context
	if (context.state == 0) then
		context.mspeed = b.min_speed
		context.new_target = false
		context.target_invalid = false
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.state = 1
		end
	end
	if (context.state == 1) then
		s.z = Z_BULLETS
		s.sort_y_offset = nil
		__pc_helpers["__pc_bolt_1_insert_1"](this, "flying", nil, store.tick_ts, s.loop)
		do
			context.ps.particle_system.emit = true
		end
		context.state = 3
	end
	if (context.state == 2) then
		if b.target_id then
			context.mspeed = b.min_speed
			context.new_target = true
			context.target_invalid = false
			context.state = 1
		else
			return
		end
	end
	local arrived = (V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) <= (context.mspeed * store.tick_length))
	if arrived then
		this.pos.x, this.pos.y = b.to.x, b.to.y
		local target = store.entities[b.target_id]
		if (target and (not target.health.dead)) then
			local d = SU.create_bullet_damage(b, target.id, this.id)
			queue_damage(store, d)
			local mods = (b.mods or ((b.mod and {b.mod})))
			if mods then
				for k = 1, (# mods) do
					local m = E:create_entity(mods[k])
					m.modifier.target_id = b.target_id
					m.modifier.source_id = b.source_id
					m.modifier.damage_factor = b.damage_factor
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
		do
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].runs = 0
			if target then
				sfx.render.sprites[1].name = sfx.render.sprites[1].size_names[target.unit.size]
			end
			simulation:queue_insert_entity(sfx)
		end
		simulation:queue_remove_entity(this)
	end
	local target
	if (not context.target_invalid) then
		target = store.entities[b.target_id]
	end
	if false then
		local tpx, tpy = target.pos.x, target.pos.y
		if ((math.max(math.abs((tpx - b.to.x)), math.abs((tpy - b.to.y))) > b.max_track_distance) or (band(target.vis.bans, F_RANGED) ~= 0)) then
			context.target_invalid = true
			target = nil
		end
	end
	context.mspeed = (context.mspeed + (FPS * math.ceil(((context.mspeed * ((1 / FPS))) * b.acceleration_factor))))
	context.mspeed = km.clamp(b.min_speed, b.max_speed, context.mspeed)
	b.speed.x, b.speed.y = V.mul(context.mspeed, V.normalize((b.to.x - this.pos.x), (b.to.y - this.pos.y)))
	this.pos.x = (this.pos.x + (b.speed.x * store.tick_length))
	this.pos.y = (this.pos.y + (b.speed.y * store.tick_length))
	do
		s.r = V.angleTo((b.to.x - this.pos.x), (b.to.y - this.pos.y))
	end
	do
		context.ps.particle_system.emit_direction = s.r
	end
end
,
	[180] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local context = this.main_script.context
	if (context.state == 0) then
		context.mspeed = b.min_speed
		context.new_target = false
		context.target_invalid = false
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.state = 1
		end
	end
	if (context.state == 1) then
		s.z = Z_BULLETS
		s.sort_y_offset = nil
		__pc_helpers["__pc_bolt_1_insert_1"](this, "flying", nil, store.tick_ts, s.loop)
		do
			context.ps.particle_system.emit = true
		end
		context.state = 3
	end
	if (context.state == 2) then
		if b.target_id then
			context.mspeed = b.min_speed
			context.new_target = true
			context.target_invalid = false
			context.state = 1
		else
			return
		end
	end
	local arrived = (V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) <= (context.mspeed * store.tick_length))
	if arrived then
		this.pos.x, this.pos.y = b.to.x, b.to.y
		local target = store.entities[b.target_id]
		if (target and (not target.health.dead)) then
			local d = SU.create_bullet_damage(b, target.id, this.id)
			queue_damage(store, d)
			local mods = (b.mods or ((b.mod and {b.mod})))
			if mods then
				for k = 1, (# mods) do
					local m = E:create_entity(mods[k])
					m.modifier.target_id = b.target_id
					m.modifier.source_id = b.source_id
					m.modifier.damage_factor = b.damage_factor
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
		do
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].runs = 0
			simulation:queue_insert_entity(sfx)
		end
		simulation:queue_remove_entity(this)
	end
	local target
	if (not context.target_invalid) then
		target = store.entities[b.target_id]
	end
	if false then
		local tpx, tpy = target.pos.x, target.pos.y
		do
			tpx, tpy = (tpx + target.unit.hit_offset.x), (tpy + target.unit.hit_offset.y)
		end
		if ((math.max(math.abs((tpx - b.to.x)), math.abs((tpy - b.to.y))) > b.max_track_distance) or (band(target.vis.bans, F_RANGED) ~= 0)) then
			context.target_invalid = true
			target = nil
		end
	end
	context.mspeed = (context.mspeed + (FPS * math.ceil(((context.mspeed * ((1 / FPS))) * b.acceleration_factor))))
	context.mspeed = km.clamp(b.min_speed, b.max_speed, context.mspeed)
	b.speed.x, b.speed.y = V.mul(context.mspeed, V.normalize((b.to.x - this.pos.x), (b.to.y - this.pos.y)))
	this.pos.x = (this.pos.x + (b.speed.x * store.tick_length))
	this.pos.y = (this.pos.y + (b.speed.y * store.tick_length))
	do
		context.ps.particle_system.emit_direction = s.r
	end
end
,
	[181] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local context = this.main_script.context
	if (context.state == 0) then
		context.mspeed = b.min_speed
		context.new_target = false
		context.target_invalid = false
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.state = 1
		end
	end
	if (context.state == 1) then
		s.z = Z_BULLETS
		s.sort_y_offset = nil
		__pc_helpers["__pc_bolt_1_insert_1"](this, "flying", nil, store.tick_ts, s.loop)
		do
			context.ps.particle_system.emit = true
		end
		context.state = 3
	end
	if (context.state == 2) then
		if b.target_id then
			context.mspeed = b.min_speed
			context.new_target = true
			context.target_invalid = false
			context.state = 1
		else
			return
		end
	end
	local arrived = (V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) <= (context.mspeed * store.tick_length))
	if arrived then
		this.pos.x, this.pos.y = b.to.x, b.to.y
		local target = store.entities[b.target_id]
		if (target and (not target.health.dead)) then
			local d = SU.create_bullet_damage(b, target.id, this.id)
			queue_damage(store, d)
			local mods = (b.mods or ((b.mod and {b.mod})))
			if mods then
				for k = 1, (# mods) do
					local m = E:create_entity(mods[k])
					m.modifier.target_id = b.target_id
					m.modifier.source_id = b.source_id
					m.modifier.damage_factor = b.damage_factor
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
		do
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].runs = 0
			simulation:queue_insert_entity(sfx)
		end
		simulation:queue_remove_entity(this)
	end
	local target
	if (not context.target_invalid) then
		target = store.entities[b.target_id]
	end
	if false then
		local tpx, tpy = target.pos.x, target.pos.y
		do
			tpx, tpy = (tpx + target.unit.hit_offset.x), (tpy + target.unit.hit_offset.y)
		end
		if ((math.max(math.abs((tpx - b.to.x)), math.abs((tpy - b.to.y))) > b.max_track_distance) or (band(target.vis.bans, F_RANGED) ~= 0)) then
			context.target_invalid = true
			target = nil
		end
	end
	context.mspeed = (context.mspeed + (FPS * math.ceil(((context.mspeed * ((1 / FPS))) * b.acceleration_factor))))
	context.mspeed = km.clamp(b.min_speed, b.max_speed, context.mspeed)
	b.speed.x, b.speed.y = V.mul(context.mspeed, V.normalize((b.to.x - this.pos.x), (b.to.y - this.pos.y)))
	this.pos.x = (this.pos.x + (b.speed.x * store.tick_length))
	this.pos.y = (this.pos.y + (b.speed.y * store.tick_length))
	do
		s.r = V.angleTo((b.to.x - this.pos.x), (b.to.y - this.pos.y))
	end
	do
		context.ps.particle_system.emit_direction = s.r
	end
end
,
	[182] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = (s.r + (b.rotation_speed * store.tick_length))
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				do
					mods = {b.mod}
				end
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[183] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = (s.r + (b.rotation_speed * store.tick_length))
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				do
					mods = {b.mod}
				end
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = s.r
					end
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[184] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = (s.r + (b.rotation_speed * store.tick_length))
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = s.r
					end
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			local p = E:create_entity(b.payload)
			p.pos.x, p.pos.y = this.pos.x, this.pos.y
			p.target_id = b.target_id
			p.source_id = b.source_id
			do
				p.aura.level = b.level
				p.aura.damage_factor = b.damage_factor
				p.aura.target_id = b.target_id
			end
			simulation:queue_insert_entity(p)
		end
		do
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[185] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = (s.r + (b.rotation_speed * store.tick_length))
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[186] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = (s.r + (b.rotation_speed * store.tick_length))
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = s.r
					end
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[187] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
				if (math.abs(s.r) > (math.pi * 0.5)) then
					s.flip_y = true
				end
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = s.r
					end
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[188] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				do
					mods = b.mods
				end
				do
					do
						local i = 1
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = s.r
					end
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[189] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				do
					mods = {b.mod}
				end
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = s.r
					end
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[190] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				do
					mods = {b.mod}
				end
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = s.r
					end
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[191] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				do
					mods = {b.mod}
				end
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[192] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = s.r
					end
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[193] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[194] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = s.r
					end
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[195] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		do
			b.damage_min = (b.damage_min + (b.damage_min_inc * b.level))
		end
		do
			b.damage_max = (b.damage_max + (b.damage_max_inc * b.level))
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_bullet_swamp_monster_bomb_tosky_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = s.r
					end
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[196] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
				if (math.abs(s.r) > (math.pi * 0.5)) then
					s.flip_y = true
				end
			end
			do
				context.ps.particle_system.emit_direction = s.r
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
				do
					context.ps.particle_system.emit = (not s.hidden)
				end
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = s.r
					end
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			if context.ps.particle_system.emit then
				s.hidden = true
				context.ps.particle_system.emit = false
				context.wait_until_ts = (store.tick_ts + context.ps.particle_system.particle_lifetime[2])
				context.state = 4
			else
				simulation:queue_remove_entity(this)
				return
			end
		end
	end
	if (context.state == 4) then
		if (store.tick_ts >= context.wait_until_ts) then
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[197] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				context.ps.particle_system.emit_direction = s.r
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			if context.ps.particle_system.emit then
				s.hidden = true
				context.ps.particle_system.emit = false
				context.wait_until_ts = (store.tick_ts + context.ps.particle_system.particle_lifetime[2])
				context.state = 4
			else
				simulation:queue_remove_entity(this)
				return
			end
		end
	end
	if (context.state == 4) then
		if (store.tick_ts >= context.wait_until_ts) then
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[198] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				context.ps.particle_system.emit_direction = s.r
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			local p = E:create_entity(b.payload)
			p.pos.x, p.pos.y = this.pos.x, this.pos.y
			p.target_id = b.target_id
			p.source_id = b.source_id
			do
				p.aura.level = b.level
				p.aura.damage_factor = b.damage_factor
				p.aura.target_id = b.target_id
			end
			simulation:queue_insert_entity(p)
		end
		do
			if context.ps.particle_system.emit then
				s.hidden = true
				context.ps.particle_system.emit = false
				context.wait_until_ts = (store.tick_ts + context.ps.particle_system.particle_lifetime[2])
				context.state = 4
			else
				simulation:queue_remove_entity(this)
				return
			end
		end
	end
	if (context.state == 4) then
		if (store.tick_ts >= context.wait_until_ts) then
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[199] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				context.ps.particle_system.emit_direction = s.r
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
				do
					context.ps.particle_system.emit = (not s.hidden)
				end
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				do
					mods = b.mods
				end
				do
					do
						local i = 1
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = s.r
					end
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			if context.ps.particle_system.emit then
				s.hidden = true
				context.ps.particle_system.emit = false
				context.wait_until_ts = (store.tick_ts + context.ps.particle_system.particle_lifetime[2])
				context.state = 4
			else
				simulation:queue_remove_entity(this)
				return
			end
		end
	end
	if (context.state == 4) then
		if (store.tick_ts >= context.wait_until_ts) then
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[200] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				context.ps.particle_system.emit_direction = s.r
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
				do
					context.ps.particle_system.emit = (not s.hidden)
				end
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				do
					mods = b.mods
				end
				do
					do
						local i = 1
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = s.r
					end
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			local p = E:create_entity(b.payload)
			p.pos.x, p.pos.y = this.pos.x, this.pos.y
			p.target_id = b.target_id
			p.source_id = b.source_id
			do
				p.aura.level = b.level
				p.aura.damage_factor = b.damage_factor
				p.aura.target_id = b.target_id
			end
			do
				for k, v in pairs(b.payload_props) do
					p[k] = v
				end
			end
			simulation:queue_insert_entity(p)
		end
		do
			if context.ps.particle_system.emit then
				s.hidden = true
				context.ps.particle_system.emit = false
				context.wait_until_ts = (store.tick_ts + context.ps.particle_system.particle_lifetime[2])
				context.state = 4
			else
				simulation:queue_remove_entity(this)
				return
			end
		end
	end
	if (context.state == 4) then
		if (store.tick_ts >= context.wait_until_ts) then
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[201] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				context.ps.particle_system.emit_direction = s.r
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
				do
					context.ps.particle_system.emit = (not s.hidden)
				end
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				do
					mods = {b.mod}
				end
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = s.r
					end
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			if context.ps.particle_system.emit then
				s.hidden = true
				context.ps.particle_system.emit = false
				context.wait_until_ts = (store.tick_ts + context.ps.particle_system.particle_lifetime[2])
				context.state = 4
			else
				simulation:queue_remove_entity(this)
				return
			end
		end
	end
	if (context.state == 4) then
		if (store.tick_ts >= context.wait_until_ts) then
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[202] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				context.ps.particle_system.emit_direction = s.r
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
				do
					context.ps.particle_system.emit = (not s.hidden)
				end
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				do
					mods = {b.mod}
				end
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = s.r
					end
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			local p = E:create_entity(b.payload)
			p.pos.x, p.pos.y = this.pos.x, this.pos.y
			p.target_id = b.target_id
			p.source_id = b.source_id
			do
				for k, v in pairs(b.payload_props) do
					p[k] = v
				end
			end
			simulation:queue_insert_entity(p)
		end
		do
			if context.ps.particle_system.emit then
				s.hidden = true
				context.ps.particle_system.emit = false
				context.wait_until_ts = (store.tick_ts + context.ps.particle_system.particle_lifetime[2])
				context.state = 4
			else
				simulation:queue_remove_entity(this)
				return
			end
		end
	end
	if (context.state == 4) then
		if (store.tick_ts >= context.wait_until_ts) then
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[203] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				context.ps.particle_system.emit_direction = s.r
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
				do
					context.ps.particle_system.emit = (not s.hidden)
				end
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				do
					mods = {b.mod}
				end
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = s.r
					end
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			local p = E:create_entity(b.payload)
			p.pos.x, p.pos.y = this.pos.x, this.pos.y
			p.target_id = b.target_id
			p.source_id = b.source_id
			do
				p.aura.level = b.level
				p.aura.damage_factor = b.damage_factor
				p.aura.target_id = b.target_id
			end
			simulation:queue_insert_entity(p)
		end
		do
			if context.ps.particle_system.emit then
				s.hidden = true
				context.ps.particle_system.emit = false
				context.wait_until_ts = (store.tick_ts + context.ps.particle_system.particle_lifetime[2])
				context.state = 4
			else
				simulation:queue_remove_entity(this)
				return
			end
		end
	end
	if (context.state == 4) then
		if (store.tick_ts >= context.wait_until_ts) then
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[204] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				context.ps.particle_system.emit_direction = s.r
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
				do
					context.ps.particle_system.emit = (not s.hidden)
				end
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				do
					mods = {b.mod}
				end
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			if context.ps.particle_system.emit then
				s.hidden = true
				context.ps.particle_system.emit = false
				context.wait_until_ts = (store.tick_ts + context.ps.particle_system.particle_lifetime[2])
				context.state = 4
			else
				simulation:queue_remove_entity(this)
				return
			end
		end
	end
	if (context.state == 4) then
		if (store.tick_ts >= context.wait_until_ts) then
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[205] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				context.ps.particle_system.emit_direction = s.r
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
				do
					context.ps.particle_system.emit = (not s.hidden)
				end
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				do
					mods = {b.mod}
				end
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			if context.ps.particle_system.emit then
				s.hidden = true
				context.ps.particle_system.emit = false
				context.wait_until_ts = (store.tick_ts + context.ps.particle_system.particle_lifetime[2])
				context.state = 4
			else
				simulation:queue_remove_entity(this)
				return
			end
		end
	end
	if (context.state == 4) then
		if (store.tick_ts >= context.wait_until_ts) then
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[206] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				context.ps.particle_system.emit_direction = s.r
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
				do
					context.ps.particle_system.emit = (not s.hidden)
				end
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				do
					mods = {b.mod}
				end
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = s.r
					end
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			if context.ps.particle_system.emit then
				s.hidden = true
				context.ps.particle_system.emit = false
				context.wait_until_ts = (store.tick_ts + context.ps.particle_system.particle_lifetime[2])
				context.state = 4
			else
				simulation:queue_remove_entity(this)
				return
			end
		end
	end
	if (context.state == 4) then
		if (store.tick_ts >= context.wait_until_ts) then
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[207] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				context.ps.particle_system.emit_direction = s.r
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
				do
					context.ps.particle_system.emit = (not s.hidden)
				end
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				do
					mods = {b.mod}
				end
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			if context.ps.particle_system.emit then
				s.hidden = true
				context.ps.particle_system.emit = false
				context.wait_until_ts = (store.tick_ts + context.ps.particle_system.particle_lifetime[2])
				context.state = 4
			else
				simulation:queue_remove_entity(this)
				return
			end
		end
	end
	if (context.state == 4) then
		if (store.tick_ts >= context.wait_until_ts) then
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[208] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				context.ps.particle_system.emit_direction = s.r
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
				do
					context.ps.particle_system.emit = (not s.hidden)
				end
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = s.r
					end
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			if context.ps.particle_system.emit then
				s.hidden = true
				context.ps.particle_system.emit = false
				context.wait_until_ts = (store.tick_ts + context.ps.particle_system.particle_lifetime[2])
				context.state = 4
			else
				simulation:queue_remove_entity(this)
				return
			end
		end
	end
	if (context.state == 4) then
		if (store.tick_ts >= context.wait_until_ts) then
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[209] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				context.ps.particle_system.emit_direction = s.r
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
				do
					context.ps.particle_system.emit = (not s.hidden)
				end
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = s.r
					end
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			local p = E:create_entity(b.payload)
			p.pos.x, p.pos.y = this.pos.x, this.pos.y
			p.target_id = b.target_id
			p.source_id = b.source_id
			do
				for k, v in pairs(b.payload_props) do
					p[k] = v
				end
			end
			simulation:queue_insert_entity(p)
		end
		do
			if context.ps.particle_system.emit then
				s.hidden = true
				context.ps.particle_system.emit = false
				context.wait_until_ts = (store.tick_ts + context.ps.particle_system.particle_lifetime[2])
				context.state = 4
			else
				simulation:queue_remove_entity(this)
				return
			end
		end
	end
	if (context.state == 4) then
		if (store.tick_ts >= context.wait_until_ts) then
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[210] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				context.ps.particle_system.emit_direction = s.r
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
				do
					context.ps.particle_system.emit = (not s.hidden)
				end
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			if context.ps.particle_system.emit then
				s.hidden = true
				context.ps.particle_system.emit = false
				context.wait_until_ts = (store.tick_ts + context.ps.particle_system.particle_lifetime[2])
				context.state = 4
			else
				simulation:queue_remove_entity(this)
				return
			end
		end
	end
	if (context.state == 4) then
		if (store.tick_ts >= context.wait_until_ts) then
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[211] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				context.ps.particle_system.emit_direction = s.r
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
				do
					context.ps.particle_system.emit = (not s.hidden)
				end
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				do
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			if context.ps.particle_system.emit then
				s.hidden = true
				context.ps.particle_system.emit = false
				context.wait_until_ts = (store.tick_ts + context.ps.particle_system.particle_lifetime[2])
				context.state = 4
			else
				simulation:queue_remove_entity(this)
				return
			end
		end
	end
	if (context.state == 4) then
		if (store.tick_ts >= context.wait_until_ts) then
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[212] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				context.ps.particle_system.emit_direction = s.r
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
				do
					context.ps.particle_system.emit = (not s.hidden)
				end
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
				if (target.unit.blood_color ~= BLOOD_NONE) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = s.r
					end
					simulation:queue_insert_entity(sfx)
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			if context.ps.particle_system.emit then
				s.hidden = true
				context.ps.particle_system.emit = false
				context.wait_until_ts = (store.tick_ts + context.ps.particle_system.particle_lifetime[2])
				context.state = 4
			else
				simulation:queue_remove_entity(this)
				return
			end
		end
	end
	if (context.state == 4) then
		if (store.tick_ts >= context.wait_until_ts) then
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[213] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			do
				s.r = math.atan2(context.v_y, context.v_x)
			end
			do
				context.ps.particle_system.emit_direction = s.r
			end
			do
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
				do
					context.ps.particle_system.emit = (not s.hidden)
				end
			end
			context.v_y = (context.v_y + dv_y)
			context.last_ts = store.tick_ts
			if (store.tick_ts > context.expected_stop_time) then
				context.state = 2
			end
		end
	end
	if (context.state == 2) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (target.unit and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_5"](store, target, true))) then
				hit = true
				local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, target.id, this.id)
				queue_damage(store, d)
				local mods
				if mods then
					for i = 1, (# mods) do
						local mod_name = mods[i]
						if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = b.source_id
							mod.modifier.target_id = target.id
							mod.modifier.level = b.level
							mod.modifier.source_damage = d
							mod.modifier.damage_factor = b.damage_factor
							simulation:queue_insert_entity(mod)
						end
					end
				end
			end
		end
		context.state = 3
	end
	if (context.state == 3) then
		do
			if context.ps.particle_system.emit then
				s.hidden = true
				context.ps.particle_system.emit = false
				context.wait_until_ts = (store.tick_ts + context.ps.particle_system.particle_lifetime[2])
				context.state = 4
			else
				simulation:queue_remove_entity(this)
				return
			end
		end
	end
	if (context.state == 4) then
		if (store.tick_ts >= context.wait_until_ts) then
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[214] = function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		do
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		do
			context.last_x = this.pos.x
			context.last_y = this.pos.y
			context.last_ts = store.tick_ts
			context.speed_norm2 = ((b.speed.x * b.speed.x) + (b.speed.y * b.speed.y))
			context.hitted = {}
			do
				context.mods = {b.mod}
			end
		end
		context.state = 1
	end
	if (context.state == 1) then
		do
			local dt = (store.tick_ts - context.last_ts)
			local arrived = false
			if (((context.speed_norm2 * dt) * dt) > V.dist2(context.last_x, context.last_y, b.to.x, b.to.y)) then
				this.pos.x = b.to.x
				this.pos.y = b.to.y
				arrived = true
			else
				this.pos.x = (this.pos.x + (b.speed.x * dt))
				this.pos.y = (this.pos.y + (b.speed.y * dt))
			end
			local targets = U.find_enemies_around_line(context.last_x, context.last_y, this.pos.x, this.pos.y, b.damage_radius, F_RANGED, b.damage_flags, b.damage_bans)
			if targets then
				for i = 1, (# targets) do
					local hit_target = targets[i]
					if (not context.hitted[hit_target.id]) then
						context.hitted[hit_target.id] = true
						local d = __pc_helpers["__pc_arborean_sentinels_spearmen_spear_update_1"](b, hit_target.id, this.id)
						queue_damage(store, d)
						if context.mods then
							for j = 1, (# context.mods) do
								local mod_name = context.mods[j]
								if U.flags_pass(hit_target.vis, E:get_template(mod_name).modifier) then
									local mod = E:create_entity(mod_name)
									mod.modifier.source_id = b.source_id
									mod.modifier.target_id = hit_target.id
									mod.modifier.level = b.level
									mod.modifier.source_damage = d
									mod.modifier.damage_factor = b.damage_factor
									simulation:queue_insert_entity(mod)
								end
							end
						end
						do
							local fx = E:create_entity(b.hit_fx)
							fx.pos = V.vclone(hit_target.pos)
							fx.render.sprites[1].ts = store.tick_ts
							simulation:queue_insert_entity(fx)
						end
					end
				end
			end
			do
				context.state = 3
			end
		end
	end
	if (context.state == 3) then
		do
			if context.ps.particle_system.emit then
				s.hidden = true
				context.ps.particle_system.emit = false
				context.wait_until_ts = (store.tick_ts + context.ps.particle_system.particle_lifetime[2])
				context.state = 4
			else
				simulation:queue_remove_entity(this)
				return
			end
		end
	end
	if (context.state == 4) then
		if (store.tick_ts >= context.wait_until_ts) then
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	[215] = function(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]
	if (not target) then
		return false
	end
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	do
		b.rotation_speed = (b.rotation_speed * ((((b.to.x > this.pos.x) and (- 1)) or 1)))
		do
			this.render.sprites[1].flip_x = (not this.render.sprites[1].flip_x)
		end
	end
	do
		this.render.sprites[1].hidden = true
	end
	return true
end
,
	[216] = function(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]
	if (not target) then
		return false
	end
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	do
		this.render.sprites[1].hidden = true
	end
	return true
end
,
	[217] = function(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]
	if (not target) then
		return false
	end
	do
		b.to.x = (b.to.x + (target.motion.speed.x * b.flight_time))
		b.to.y = (b.to.y + (target.motion.speed.y * b.flight_time))
	end
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	do
		b.rotation_speed = (b.rotation_speed * ((((b.to.x > this.pos.x) and (- 1)) or 1)))
		do
			this.render.sprites[1].flip_x = (not this.render.sprites[1].flip_x)
		end
	end
	do
		this.render.sprites[1].hidden = true
	end
	return true
end
,
	[218] = function(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]
	if (not target) then
		return false
	end
	do
		b.to.x = (b.to.x + (target.motion.speed.x * b.flight_time))
		b.to.y = (b.to.y + (target.motion.speed.y * b.flight_time))
	end
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	do
		this.render.sprites[1].hidden = true
	end
	return true
end
,
	[219] = function(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]
	if (not target) then
		return false
	end
	do
		b.to.x = (b.to.x + (target.motion.speed.x * b.flight_time))
		b.to.y = (b.to.y + (target.motion.speed.y * b.flight_time))
	end
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	return true
end
,
	[220] = function(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]
	if (not target) then
		return false
	end
	do
		b.to.x, b.to.y = target.pos.x, target.pos.y
		if (target.unit and target.unit.hit_offset) then
			b.to.x, b.to.y = (b.to.x + target.unit.hit_offset.x), (b.to.y + target.unit.hit_offset.y)
		end
	end
	do
		b.to.x = (b.to.x + (target.motion.speed.x * b.flight_time))
		b.to.y = (b.to.y + (target.motion.speed.y * b.flight_time))
	end
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	do
		b.rotation_speed = (b.rotation_speed * ((((b.to.x > this.pos.x) and (- 1)) or 1)))
		do
			this.render.sprites[1].flip_x = (not this.render.sprites[1].flip_x)
		end
	end
	do
		this.render.sprites[1].hidden = true
	end
	return true
end
,
	[221] = function(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]
	if (not target) then
		return false
	end
	do
		b.to.x, b.to.y = target.pos.x, target.pos.y
		if (target.unit and target.unit.hit_offset) then
			b.to.x, b.to.y = (b.to.x + target.unit.hit_offset.x), (b.to.y + target.unit.hit_offset.y)
		end
	end
	do
		b.to.x = (b.to.x + (target.motion.speed.x * b.flight_time))
		b.to.y = (b.to.y + (target.motion.speed.y * b.flight_time))
	end
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	do
		this.render.sprites[1].hidden = true
	end
	return true
end
,
	[222] = function(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]
	if (not target) then
		return false
	end
	do
		b.to.x, b.to.y = target.pos.x, target.pos.y
		if (target.unit and target.unit.hit_offset) then
			b.to.x, b.to.y = (b.to.x + target.unit.hit_offset.x), (b.to.y + target.unit.hit_offset.y)
		end
	end
	do
		b.to.x = (b.to.x + (target.motion.speed.x * b.flight_time))
		b.to.y = (b.to.y + (target.motion.speed.y * b.flight_time))
	end
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	return true
end
,
	[223] = function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if (((target and target.unit) and false) and target.render) then
		for i = 1, (# this.render.sprites) do
			local s = this.render.sprites[i]
			s.flip_x = target.render.sprites[1].flip_x
			s.ts = store.tick_ts
			if s.size_names then
				s.name = s.size_names[target.unit.size]
			end
		end
	end
	return true
end
,
	[224] = function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if ((target and target.unit) and target.render) then
		do
			local i = 1
			local s = this.render.sprites[i]
			s.flip_x = target.render.sprites[1].flip_x
			s.ts = store.tick_ts
			do
				s.name = s.size_names[target.unit.size]
			end
		end
	end
	return true
end
,
	[225] = function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if ((target and target.unit) and target.render) then
		do
			local i = 1
			local s = this.render.sprites[i]
			s.flip_x = target.render.sprites[1].flip_x
			s.ts = store.tick_ts
		end
	end
	return true
end
,
	[226] = function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	if (context.state == 0) then
		context.state = 1
		this.modifier.ts = store.tick_ts
		this.pos = target.pos
	end
	if ((store.tick_ts - m.ts) > m.duration) then
		simulation:queue_remove_entity(this)
		return
	end
	if target.unit then
		local s = this.render.sprites[1]
		local flip_sign = 1
		if target.render then
			flip_sign = ((target.render.sprites[1].flip_x and (- 1)) or 1)
		end
		if target.health_bar then
			local hb = target.health_bar.offset
			local hbo = m.health_bar_offset
			s.offset.x, s.offset.y = (hb.x + (hbo.x * flip_sign)), (hb.y + hbo.y)
		elseif target.unit.mod_offset then
			s.offset.x, s.offset.y = (target.unit.mod_offset.x * flip_sign), target.unit.mod_offset.y
		end
	end
end
,
	[227] = function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	if (context.state == 0) then
		context.state = 1
		this.modifier.ts = store.tick_ts
		this.pos = target.pos
	end
	if ((store.tick_ts - m.ts) > m.duration) then
		simulation:queue_remove_entity(this)
		return
	end
	if target.unit then
		local s = this.render.sprites[1]
		local flip_sign = 1
		if target.render then
			flip_sign = ((target.render.sprites[1].flip_x and (- 1)) or 1)
		end
		if target.unit.mod_offset then
			s.offset.x, s.offset.y = (target.unit.mod_offset.x * flip_sign), target.unit.mod_offset.y
		end
	end
end
,
	[228] = function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	if (context.state == 0) then
		context.state = 1
		this.modifier.ts = store.tick_ts
		this.pos = target.pos
	end
	if ((store.tick_ts - m.ts) > m.duration) then
		simulation:queue_remove_entity(this)
		return
	end
	if target.unit then
		local s = this.render.sprites[1]
		local flip_sign = 1
		if target.render then
			flip_sign = ((target.render.sprites[1].flip_x and (- 1)) or 1)
		end
	end
end
,
	[229] = function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	if (context.state == 0) then
		context.state = 1
		this.modifier.ts = store.tick_ts
		this.pos = target.pos
	end
	if ((store.tick_ts - m.ts) > m.duration) then
		simulation:queue_remove_entity(this)
		return
	end
end
,
	[230] = function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	if (context.state == 0) then
		context.state = 1
		this.modifier.ts = store.tick_ts
		this.pos = target.pos
	end
	if target.unit then
		local s = this.render.sprites[1]
		local flip_sign = 1
		if target.render then
			flip_sign = ((target.render.sprites[1].flip_x and (- 1)) or 1)
		end
		if target.unit.mod_offset then
			s.offset.x, s.offset.y = (target.unit.mod_offset.x * flip_sign), target.unit.mod_offset.y
		end
	end
end
,
	[231] = function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	if (context.state == 0) then
		context.state = 1
		this.modifier.ts = store.tick_ts
		this.pos = target.pos
	end
	if target.unit then
		local s = this.render.sprites[1]
		local flip_sign = 1
		if target.render then
			flip_sign = ((target.render.sprites[1].flip_x and (- 1)) or 1)
		end
	end
end
,
	[232] = function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	if (context.state == 0) then
		context.state = 1
		this.modifier.ts = store.tick_ts
		this.pos = target.pos
	end
end
,
	[233] = function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if ((target and target.unit) and false) then
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
	this.dps.ts = (store.tick_ts - this.dps.damage_every)
	this.modifier.ts = store.tick_ts
	signal.emit("mod-applied", this, target)
	return true
end
,
	[234] = function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if (target and target.unit) then
		local s = this.render.sprites[1]
		s.ts = store.tick_ts
		do
			s.name = s.size_names[target.unit.size]
		end
		do
			s.scale = s.size_scales[target.unit.size]
		end
		if target.render then
			s.z = target.render.sprites[1].z
		end
	end
	this.dps.ts = (store.tick_ts - this.dps.damage_every)
	this.modifier.ts = store.tick_ts
	signal.emit("mod-applied", this, target)
	return true
end
,
	[235] = function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if (target and target.unit) then
		local s = this.render.sprites[1]
		s.ts = store.tick_ts
		do
			s.name = s.size_names[target.unit.size]
		end
		if target.render then
			s.z = target.render.sprites[1].z
		end
	end
	this.dps.ts = (store.tick_ts - this.dps.damage_every)
	this.modifier.ts = store.tick_ts
	signal.emit("mod-applied", this, target)
	return true
end
,
	[236] = function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if (target and target.unit) then
		local s = this.render.sprites[1]
		s.ts = store.tick_ts
		if target.render then
			s.z = target.render.sprites[1].z
		end
	end
	this.dps.ts = (store.tick_ts - this.dps.damage_every)
	this.modifier.ts = store.tick_ts
	signal.emit("mod-applied", this, target)
	return true
end
,
	[237] = function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	local dps = this.dps
	local m = this.modifier
	if (context.state == 0) then
		do
			context.dmin = (dps.damage_min + (m.level * dps.damage_inc))
			context.dmax = (dps.damage_max + (m.level * dps.damage_inc))
		end
		this.pos = target.pos
		context.state = 1
	end
	if ((store.tick_ts - m.ts) >= (m.duration - 1e-09)) then
		simulation:queue_remove_entity(this)
		return
	end
	if ((store.tick_ts - dps.ts) >= dps.damage_every) then
		dps.ts = (dps.ts + dps.damage_every)
		local damage_value = math.random(context.dmin, context.dmax)
		damage_value = (damage_value * m.damage_factor)
		local d = E.assign_damage(dps.damage_type, damage_value, this.id, target.id)
		d.pop = dps.pop
		d.pop_chance = dps.pop_chance
		d.pop_conds = dps.pop_conds
		queue_damage(store, d)
		if (dps.fx and target.unit.blood_color) then
			local fx = E:create_entity(dps.fx)
			do
				fx.pos = target.pos
				if target.unit.mod_offset then
					fx.render.sprites[1].offset.x = target.unit.mod_offset.x
					fx.render.sprites[1].offset.y = target.unit.mod_offset.y
				end
			end
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].runs = 0
			do
				fx.render.sprites[1].name = fx.render.sprites[1].size_names[target.unit.size]
			end
			do
				fx.render.sprites[1].name = (fx.render.sprites[1].name .. ("_" .. target.unit.blood_color))
			end
			if target.render then
				fx.render.sprites[1].flip_x = target.render.sprites[1].flip_x
			end
			simulation:queue_insert_entity(fx)
		end
	end
end
,
	[238] = function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	local dps = this.dps
	local m = this.modifier
	if (context.state == 0) then
		do
			context.dmin = (dps.damage_min + (m.level * dps.damage_inc))
			context.dmax = (dps.damage_max + (m.level * dps.damage_inc))
		end
		this.pos = target.pos
		context.state = 1
	end
	if ((store.tick_ts - m.ts) >= (m.duration - 1e-09)) then
		simulation:queue_remove_entity(this)
		return
	end
	if ((store.tick_ts - dps.ts) >= dps.damage_every) then
		dps.ts = (dps.ts + dps.damage_every)
		local damage_value = math.random(context.dmin, context.dmax)
		damage_value = (damage_value * m.damage_factor)
		local d = E.assign_damage(dps.damage_type, damage_value, this.id, target.id)
		d.pop = dps.pop
		d.pop_chance = dps.pop_chance
		d.pop_conds = dps.pop_conds
		queue_damage(store, d)
	end
end
,
	[239] = function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	local dps = this.dps
	local m = this.modifier
	if (context.state == 0) then
		do
			context.dmin = (dps.damage_min + (m.level * dps.damage_inc))
			context.dmax = (dps.damage_max + (m.level * dps.damage_inc))
		end
		this.pos = target.pos
		context.state = 1
	end
	if ((store.tick_ts - m.ts) >= (m.duration - 1e-09)) then
		simulation:queue_remove_entity(this)
		return
	end
	if target.unit.mod_offset then
		this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
	end
	if ((store.tick_ts - dps.ts) >= dps.damage_every) then
		dps.ts = (dps.ts + dps.damage_every)
		local damage_value = math.random(context.dmin, context.dmax)
		damage_value = (damage_value * m.damage_factor)
		local d = E.assign_damage(dps.damage_type, damage_value, this.id, target.id)
		d.pop = dps.pop
		d.pop_chance = dps.pop_chance
		d.pop_conds = dps.pop_conds
		queue_damage(store, d)
	end
end
,
	[240] = function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	local dps = this.dps
	local m = this.modifier
	if (context.state == 0) then
		do
			context.dmin, context.dmax = dps.damage_min, dps.damage_max
		end
		do
			context.fx_ts = 0
		end
		this.pos = target.pos
		context.state = 1
	end
	if ((store.tick_ts - m.ts) >= (m.duration - 1e-09)) then
		simulation:queue_remove_entity(this)
		return
	end
	if ((store.tick_ts - dps.ts) >= dps.damage_every) then
		dps.ts = (dps.ts + dps.damage_every)
		local damage_value = math.random(context.dmin, context.dmax)
		damage_value = (damage_value * m.damage_factor)
		local d = E.assign_damage(dps.damage_type, damage_value, this.id, target.id)
		d.pop = dps.pop
		d.pop_chance = dps.pop_chance
		d.pop_conds = dps.pop_conds
		queue_damage(store, d)
		if ((dps.fx and ((store.tick_ts - context.fx_ts) >= dps.fx_every)) and target.unit.blood_color) then
			do
				context.fx_ts = store.tick_ts
			end
			local fx = E:create_entity(dps.fx)
			do
				fx.pos = target.pos
				if target.unit.mod_offset then
					fx.render.sprites[1].offset.x = target.unit.mod_offset.x
					fx.render.sprites[1].offset.y = target.unit.mod_offset.y
				end
			end
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].runs = 0
			do
				fx.render.sprites[1].name = fx.render.sprites[1].size_names[target.unit.size]
			end
			do
				fx.render.sprites[1].name = (fx.render.sprites[1].name .. ("_" .. target.unit.blood_color))
			end
			if target.render then
				fx.render.sprites[1].flip_x = target.render.sprites[1].flip_x
			end
			simulation:queue_insert_entity(fx)
		end
	end
end
,
	[241] = function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	local dps = this.dps
	local m = this.modifier
	if (context.state == 0) then
		do
			context.dmin, context.dmax = dps.damage_min, dps.damage_max
		end
		do
			context.fx_ts = 0
		end
		this.pos = target.pos
		context.state = 1
	end
	if ((store.tick_ts - m.ts) >= (m.duration - 1e-09)) then
		simulation:queue_remove_entity(this)
		return
	end
	if target.unit.mod_offset then
		this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
	end
	if ((store.tick_ts - dps.ts) >= dps.damage_every) then
		dps.ts = (dps.ts + dps.damage_every)
		local damage_value = math.random(context.dmin, context.dmax)
		damage_value = (damage_value * m.damage_factor)
		local d = E.assign_damage(dps.damage_type, damage_value, this.id, target.id)
		d.pop = dps.pop
		d.pop_chance = dps.pop_chance
		d.pop_conds = dps.pop_conds
		queue_damage(store, d)
		if (dps.fx and ((store.tick_ts - context.fx_ts) >= dps.fx_every)) then
			do
				context.fx_ts = store.tick_ts
			end
			local fx = E:create_entity(dps.fx)
			do
				fx.pos = V.vclone(this.pos)
				if target.unit.mod_offset then
					fx.pos.x, fx.pos.y = (fx.pos.x + target.unit.mod_offset.x), (fx.pos.y + target.unit.mod_offset.y)
				end
			end
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].runs = 0
			simulation:queue_insert_entity(fx)
		end
	end
end
,
	[242] = function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	local dps = this.dps
	local m = this.modifier
	if (context.state == 0) then
		do
			context.dmin, context.dmax = dps.damage_min, dps.damage_max
		end
		this.pos = target.pos
		context.state = 1
	end
	if ((store.tick_ts - m.ts) >= (m.duration - 1e-09)) then
		simulation:queue_remove_entity(this)
		return
	end
	if ((store.tick_ts - dps.ts) >= dps.damage_every) then
		dps.ts = (dps.ts + dps.damage_every)
		local damage_value = math.random(context.dmin, context.dmax)
		damage_value = (damage_value * m.damage_factor)
		do
			damage_value = km.clamp(0, (target.health.hp - 1), damage_value)
		end
		local d = E.assign_damage(dps.damage_type, damage_value, this.id, target.id)
		d.pop = dps.pop
		d.pop_chance = dps.pop_chance
		d.pop_conds = dps.pop_conds
		queue_damage(store, d)
	end
end
,
	[243] = function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	local dps = this.dps
	local m = this.modifier
	if (context.state == 0) then
		do
			context.dmin, context.dmax = dps.damage_min, dps.damage_max
		end
		this.pos = target.pos
		context.state = 1
	end
	if ((store.tick_ts - m.ts) >= (m.duration - 1e-09)) then
		simulation:queue_remove_entity(this)
		return
	end
	if ((store.tick_ts - dps.ts) >= dps.damage_every) then
		dps.ts = (dps.ts + dps.damage_every)
		local damage_value = math.random(context.dmin, context.dmax)
		damage_value = (damage_value * m.damage_factor)
		local d = E.assign_damage(dps.damage_type, damage_value, this.id, target.id)
		d.pop = dps.pop
		d.pop_chance = dps.pop_chance
		d.pop_conds = dps.pop_conds
		queue_damage(store, d)
		if (dps.fx and target.unit.blood_color) then
			local fx = E:create_entity(dps.fx)
			do
				fx.pos = target.pos
				if target.unit.mod_offset then
					fx.render.sprites[1].offset.x = target.unit.mod_offset.x
					fx.render.sprites[1].offset.y = target.unit.mod_offset.y
				end
			end
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].runs = 0
			do
				fx.render.sprites[1].name = fx.render.sprites[1].size_names[target.unit.size]
			end
			do
				fx.render.sprites[1].name = (fx.render.sprites[1].name .. ("_" .. target.unit.blood_color))
			end
			if target.render then
				fx.render.sprites[1].flip_x = target.render.sprites[1].flip_x
			end
			simulation:queue_insert_entity(fx)
		end
	end
end
,
	[244] = function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	local dps = this.dps
	local m = this.modifier
	if (context.state == 0) then
		do
			context.dmin, context.dmax = dps.damage_min, dps.damage_max
		end
		this.pos = target.pos
		context.state = 1
	end
	if ((store.tick_ts - m.ts) >= (m.duration - 1e-09)) then
		simulation:queue_remove_entity(this)
		return
	end
	if ((store.tick_ts - dps.ts) >= dps.damage_every) then
		dps.ts = (dps.ts + dps.damage_every)
		local damage_value = math.random(context.dmin, context.dmax)
		damage_value = (damage_value * m.damage_factor)
		local d = E.assign_damage(dps.damage_type, damage_value, this.id, target.id)
		d.pop = dps.pop
		d.pop_chance = dps.pop_chance
		d.pop_conds = dps.pop_conds
		queue_damage(store, d)
		if dps.fx then
			local fx = E:create_entity(dps.fx)
			do
				fx.pos = V.vclone(this.pos)
				if target.unit.mod_offset then
					fx.pos.x, fx.pos.y = (fx.pos.x + target.unit.mod_offset.x), (fx.pos.y + target.unit.mod_offset.y)
				end
			end
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].runs = 0
			simulation:queue_insert_entity(fx)
		end
	end
end
,
	[245] = function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	local dps = this.dps
	local m = this.modifier
	if (context.state == 0) then
		do
			context.dmin, context.dmax = dps.damage_min, dps.damage_max
		end
		this.pos = target.pos
		context.state = 1
	end
	if ((store.tick_ts - m.ts) >= (m.duration - 1e-09)) then
		simulation:queue_remove_entity(this)
		return
	end
	if ((store.tick_ts - dps.ts) >= dps.damage_every) then
		dps.ts = (dps.ts + dps.damage_every)
		local damage_value = math.random(context.dmin, context.dmax)
		damage_value = (damage_value * m.damage_factor)
		local d = E.assign_damage(dps.damage_type, damage_value, this.id, target.id)
		d.pop = dps.pop
		d.pop_chance = dps.pop_chance
		d.pop_conds = dps.pop_conds
		queue_damage(store, d)
	end
end
,
	[246] = function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	local dps = this.dps
	local m = this.modifier
	if (context.state == 0) then
		do
			context.dmin, context.dmax = dps.damage_min, dps.damage_max
		end
		this.pos = target.pos
		context.state = 1
	end
	if ((store.tick_ts - m.ts) >= (m.duration - 1e-09)) then
		simulation:queue_remove_entity(this)
		return
	end
	if target.unit.mod_offset then
		this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
	end
	if ((store.tick_ts - dps.ts) >= dps.damage_every) then
		dps.ts = (dps.ts + dps.damage_every)
		local damage_value = math.random(context.dmin, context.dmax)
		damage_value = (damage_value * m.damage_factor)
		do
			damage_value = km.clamp(0, (target.health.hp - 1), damage_value)
		end
		local d = E.assign_damage(dps.damage_type, damage_value, this.id, target.id)
		d.pop = dps.pop
		d.pop_chance = dps.pop_chance
		d.pop_conds = dps.pop_conds
		queue_damage(store, d)
	end
end
,
	[247] = function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	local dps = this.dps
	local m = this.modifier
	if (context.state == 0) then
		do
			context.dmin, context.dmax = dps.damage_min, dps.damage_max
		end
		this.pos = target.pos
		context.state = 1
	end
	if ((store.tick_ts - m.ts) >= (m.duration - 1e-09)) then
		simulation:queue_remove_entity(this)
		return
	end
	if target.unit.mod_offset then
		this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
	end
	if ((store.tick_ts - dps.ts) >= dps.damage_every) then
		dps.ts = (dps.ts + dps.damage_every)
		local damage_value = math.random(context.dmin, context.dmax)
		damage_value = (damage_value * m.damage_factor)
		local d = E.assign_damage(dps.damage_type, damage_value, this.id, target.id)
		d.pop = dps.pop
		d.pop_chance = dps.pop_chance
		d.pop_conds = dps.pop_conds
		queue_damage(store, d)
	end
end
,
	[248] = function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	local dps = this.dps
	local m = this.modifier
	if (context.state == 0) then
		do
			context.dmin, context.dmax = dps.damage_min, dps.damage_max
		end
		this.pos = target.pos
		context.state = 1
	end
	if ((store.tick_ts - m.ts) >= (m.duration - 1e-09)) then
		simulation:queue_remove_entity(this)
		return
	end
end
,
	[249] = function(this, store)
	this.aura.ts = store.tick_ts
	do
		for _, s in ipairs(this.render.sprites) do
			s.ts = store.tick_ts
		end
	end
	if this.aura.source_id then
		local target = store.entities[this.aura.source_id]
		if (((target and false) and target.unit) and target.unit.mod_offset) then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end
	end
	this.actual_duration = this.aura.duration
	do
		this.actual_duration = (this.actual_duration + (this.aura.level * this.aura.duration_inc))
	end
	return true
end
,
	[250] = function(this, store)
	this.aura.ts = store.tick_ts
	do
		for _, s in ipairs(this.render.sprites) do
			s.ts = store.tick_ts
		end
	end
	if this.aura.source_id then
		local target = store.entities[this.aura.source_id]
		if ((target and target.unit) and target.unit.mod_offset) then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end
	end
	this.actual_duration = this.aura.duration
	do
		this.actual_duration = (this.actual_duration + (this.aura.level * this.aura.duration_inc))
	end
	return true
end
,
	[251] = function(this, store)
	this.aura.ts = store.tick_ts
	if this.aura.source_id then
		local target = store.entities[this.aura.source_id]
		if ((((target and false) and false) and target.unit) and target.unit.mod_offset) then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end
	end
	this.actual_duration = this.aura.duration
	do
		this.actual_duration = (this.actual_duration + (this.aura.level * this.aura.duration_inc))
	end
	return true
end
,
	[252] = function(this, store)
	this.aura.ts = store.tick_ts
	if this.aura.source_id then
		local target = store.entities[this.aura.source_id]
		if (((target and false) and target.unit) and target.unit.mod_offset) then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end
	end
	this.actual_duration = this.aura.duration
	do
		this.actual_duration = (this.actual_duration + (this.aura.level * this.aura.duration_inc))
	end
	return true
end
,
}
