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
			SU.soldier_power_upgrade(this, pn)
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
			SU.soldier_power_upgrade(this, pn)
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
			SU.soldier_power_upgrade(this, pn)
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
			SU.soldier_power_upgrade(this, pn)
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
			SU.soldier_power_upgrade(this, pn)
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
			SU.soldier_power_upgrade(this, pn)
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
			SU.soldier_power_upgrade(this, pn)
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
			SU.y_enemy_death(store, this)
			return
		end
		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			local cont, blocker, ranged = SU.y_enemy_walk_until_blocked_off__ignore_soldiers__func(store, this)
			if (not cont) then
			else
				if blocker then
					if (not SU.y_wait_for_blocker(store, this, blocker)) then
						goto label_25_0
					end
					while SU.can_melee_blocker(store, this, blocker) do
						if (not SU.y_enemy_melee_attacks(store, this, blocker)) then
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
			SU.y_enemy_death(store, this)
			return
		end
		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			local cont, blocker, ranged = SU.y_enemy_walk_until_blocked_off__ignore_soldiers__func(store, this)
			if (not cont) then
			else
				if blocker then
					if (not SU.y_wait_for_blocker(store, this, blocker)) then
						goto label_25_0
					end
					while SU.can_melee_blocker(store, this, blocker) do
						if (this.ranged.range_while_blocking and ranged) then
							SU.y_enemy_range_attacks(store, this, ranged)
						end
						if (not SU.y_enemy_melee_attacks(store, this, blocker)) then
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
			SU.y_enemy_death(store, this)
			return
		end
		if this.unit.is_stunned then
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
			coroutine.yield()
		else
			SU.y_enemy_walk_until_blocked_off__ignore_soldiers__func__ranged(store, this)
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
		if this.health.dead then
			SU.y_enemy_death(store, this)
			return
		end
		if this.unit.is_stunned then
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
			coroutine.yield()
		else
			SU.y_enemy_walk_until_blocked_off__ignore_soldiers__func__ranged(store, this)
		end
	end
end
,
	[18] = function(this, store)
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
	[19] = function(this, store)
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
	[20] = function(this, store)
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
	[21] = function(this, store)
	local b = this.bullet
	if b.target_id then
		local target = store.entities[b.target_id]
		if ((not target) or (target.vis and (band(target.vis.bans, F_RANGED) ~= 0))) then
			return false
		end
	end
	b.speed.x, b.speed.y = V.normalize((b.to.x - b.from.x), (b.to.y - b.from.y))
	local s = this.render.sprites[1]
	U.animation_start_default(this, "flying", nil, store.tick_ts, s.loop)
	return true
end
,
	[22] = function(this, store)
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
	U.animation_start_default(this, "flying", nil, store.tick_ts, s.loop)
	return true
end
,
	[23] = function(this, store)
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
	[24] = function(this, store)
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
	[25] = function(this, store)
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
	[26] = function(this, store)
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
	[27] = function(this, store)
	local brk, sta
	if this.vis._bans_added then
		U.bans_remove(this.vis, F_ALL)
		this.vis._bans_added = nil
	end
	if (this.render.sprites[1].name == "raise") then
		this.health_bar.hidden = true
		U.animation_start_default(this, "raise", nil, store.tick_ts, false)
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
					SU.soldier_power_upgrade(this, pn)
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
		if ((not this.health.dead) or SU.y_soldier_revive(store, this)) then
		else
			SU.y_soldier_death(store, this)
			return
		end
		scripts.soldier_revive_resist(this, store)
		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			if (this.dodge and this.dodge.active) then
				this.dodge.active = false
				if (this.dodge.counter_attack and (this.powers[this.dodge.counter_attack.power_name].level > 0)) then
					this.dodge.counter_attack_pending = true
				elseif this.dodge.animation then
					U.animation_start_default(this, this.dodge.animation, nil, store.tick_ts, false)
					while (not U.animation_finished_default(this)) do
						coroutine.yield()
					end
				end
				signal.emit("soldier-dodge", this)
			end
			while this.nav_rally.new do
				if SU.y_soldier_new_rally(store, this) then
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
				brk, sta = SU.y_soldier_timed_attacks(store, this)
				if brk then
					goto label_39_1
				end
			end
			do
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
				if (brk or (sta ~= A_NO_TARGET)) then
					goto label_39_1
				end
			end
			if SU.soldier_go_back_step(store, this) then
				goto label_39_1
			end
			::label_39_0::
			SU.soldier_idle(store, this)
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
	[28] = function(this, store)
	local brk, sta
	if this.vis._bans_added then
		U.bans_remove(this.vis, F_ALL)
		this.vis._bans_added = nil
	end
	if (this.render.sprites[1].name == "raise") then
		this.health_bar.hidden = true
		U.animation_start_default(this, "raise", nil, store.tick_ts, false)
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
					SU.soldier_power_upgrade(this, pn)
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
		if ((not this.health.dead) or SU.y_soldier_revive(store, this)) then
		else
			SU.y_soldier_death(store, this)
			return
		end
		scripts.soldier_revive_resist(this, store)
		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			if (this.dodge and this.dodge.active) then
				this.dodge.active = false
				if (this.dodge.counter_attack and (this.powers[this.dodge.counter_attack.power_name].level > 0)) then
					this.dodge.counter_attack_pending = true
				elseif this.dodge.animation then
					U.animation_start_default(this, this.dodge.animation, nil, store.tick_ts, false)
					while (not U.animation_finished_default(this)) do
						coroutine.yield()
					end
				end
				signal.emit("soldier-dodge", this)
			end
			while this.nav_rally.new do
				if SU.y_soldier_new_rally(store, this) then
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
				brk, sta = SU.y_soldier_timed_attacks(store, this)
				if brk then
					goto label_39_1
				end
			end
			if this.ranged.range_while_blocking then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)
				if brk then
					goto label_39_1
				end
			end
			do
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
				if (brk or (sta ~= A_NO_TARGET)) then
					goto label_39_1
				end
			end
			if (not this.ranged.range_while_blocking) then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)
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
			SU.soldier_idle(store, this)
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
	[29] = function(this, store)
	local brk, sta
	if this.vis._bans_added then
		U.bans_remove(this.vis, F_ALL)
		this.vis._bans_added = nil
	end
	if (this.render.sprites[1].name == "raise") then
		this.health_bar.hidden = true
		U.animation_start_default(this, "raise", nil, store.tick_ts, false)
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
		if ((not this.health.dead) or SU.y_soldier_revive(store, this)) then
		else
			SU.y_soldier_death(store, this)
			return
		end
		scripts.soldier_revive_resist(this, store)
		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			if (this.dodge and this.dodge.active) then
				this.dodge.active = false
				if (this.dodge.counter_attack and (this.powers[this.dodge.counter_attack.power_name].level > 0)) then
					this.dodge.counter_attack_pending = true
				elseif this.dodge.animation then
					U.animation_start_default(this, this.dodge.animation, nil, store.tick_ts, false)
					while (not U.animation_finished_default(this)) do
						coroutine.yield()
					end
				end
				signal.emit("soldier-dodge", this)
			end
			while this.nav_rally.new do
				if SU.y_soldier_new_rally(store, this) then
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
				brk, sta = SU.y_soldier_timed_attacks(store, this)
				if brk then
					goto label_39_1
				end
			end
			do
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
				if (brk or (sta ~= A_NO_TARGET)) then
					goto label_39_1
				end
			end
			if SU.soldier_go_back_step(store, this) then
				goto label_39_1
			end
			::label_39_0::
			SU.soldier_idle(store, this)
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
		U.animation_start_default(this, "raise", nil, store.tick_ts, false)
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
		if ((not this.health.dead) or SU.y_soldier_revive(store, this)) then
		else
			SU.y_soldier_death(store, this)
			return
		end
		scripts.soldier_revive_resist(this, store)
		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			if (this.dodge and this.dodge.active) then
				this.dodge.active = false
				if (this.dodge.counter_attack and (this.powers[this.dodge.counter_attack.power_name].level > 0)) then
					this.dodge.counter_attack_pending = true
				elseif this.dodge.animation then
					U.animation_start_default(this, this.dodge.animation, nil, store.tick_ts, false)
					while (not U.animation_finished_default(this)) do
						coroutine.yield()
					end
				end
				signal.emit("soldier-dodge", this)
			end
			while this.nav_rally.new do
				if SU.y_soldier_new_rally(store, this) then
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
				brk, sta = SU.y_soldier_timed_attacks(store, this)
				if brk then
					goto label_39_1
				end
			end
			if this.ranged.range_while_blocking then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)
				if brk then
					goto label_39_1
				end
			end
			do
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
				if (brk or (sta ~= A_NO_TARGET)) then
					goto label_39_1
				end
			end
			if (not this.ranged.range_while_blocking) then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)
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
			SU.soldier_idle(store, this)
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
	[32] = function(this, store)
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
	[33] = function(this, store)
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
	[34] = function(this, store)
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
	[35] = function(this, store)
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
	[36] = function(this, store)
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
	[37] = function(this, store)
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
	[38] = function(this, store)
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
	[39] = function(this, store)
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
	[40] = function(this, store)
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
	end
	do
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
	this.enemy.gold_bag = this.enemy.gold
	return true
end
,
	[62] = function(this, store)
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
	[63] = function(this, store)
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
	[64] = function(this, store)
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
	[65] = function(this, store)
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
	[66] = function(this, store)
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
	[67] = function(this, store)
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
	[68] = function(this, store)
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
	[69] = function(this, store)
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
	[70] = function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		do
			U.animation_start_default(this, "in", false, store.tick_ts, false)
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
				U.animation_start_default(this, "run", false, store.tick_ts, true)
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
			U.animation_start_default(this, "out", false, store.tick_ts, false)
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
	[71] = function(this, store)
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
	[72] = function(this, store)
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
	[73] = function(this, store)
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
	[74] = function(this, store)
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
	[75] = function(this, store)
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
	[76] = function(this, store)
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
	[77] = function(this, store)
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
	[78] = function(this, store)
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
	[79] = function(this, store)
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
	[80] = function(this, store)
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
	[81] = function(this, store)
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
	[84] = function(this, store)
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
	[85] = function(this, store)
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
	[86] = function(this, store)
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
	[87] = function(this, store)
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
	[88] = function(this, store)
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
	[89] = function(this, store)
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
	[90] = function(this, store)
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
	[106] = function(this, store)
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
	[107] = function(this, store)
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
	[108] = function(this, store)
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
	[109] = function(this, store)
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
	[110] = function(this, store)
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
	[111] = function(this, store)
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
	[113] = function(this, store)
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
	[114] = function(this, store)
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
	[115] = function(this, store)
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
	[116] = function(this, store)
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
	[117] = function(this, store)
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
	[118] = function(this, store)
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
	[119] = function(this, store)
	local b = this.bullet
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)
	return true
end
,
	[120] = function(this, store)
	local b = this.bullet
	if b.target_id then
		local target = store.entities[b.target_id]
		if ((not target) or (target.vis and (band(target.vis.bans, F_RANGED) ~= 0))) then
			return false
		end
	end
	b.speed.x, b.speed.y = V.normalize((b.to.x - b.from.x), (b.to.y - b.from.y))
	local s = this.render.sprites[1]
	U.animation_start_default(this, "flying", nil, store.tick_ts, s.loop)
	return true
end
,
	[121] = function(this, store)
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
	U.animation_start_default(this, "flying", nil, store.tick_ts, s.loop)
	return true
end
,
	[122] = function(this, store)
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
		elseif false then
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
	[123] = function(this, store)
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
		elseif false then
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
	[124] = function(this, store)
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
		elseif true then
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
	[125] = function(this, store)
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
		elseif true then
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
	[126] = function(this, store)
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
		elseif true then
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
	[127] = function(this, store)
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
		elseif true then
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
		elseif true then
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
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		elseif true then
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
		elseif false then
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
		elseif false then
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
		elseif false then
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
		elseif false then
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
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		elseif false then
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
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		elseif true then
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
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		elseif false then
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
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		elseif false then
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
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		elseif true then
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
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		elseif true then
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
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		elseif true then
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
		elseif true then
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
		elseif true then
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
	[147] = function(this, store)
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
		elseif true then
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
	[148] = function(this, store)
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
		elseif true then
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
	[149] = function(this, store)
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
		elseif true then
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
		elseif false then
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
	[151] = function(this, store)
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
		elseif false then
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
	[152] = function(this, store)
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
		elseif true then
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
		elseif true then
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
	[154] = function(this, store)
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
		elseif false then
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
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		elseif false then
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
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		elseif false then
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
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		elseif true then
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
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		elseif true then
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
		elseif true then
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
		elseif true then
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
		elseif false then
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
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		elseif false then
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
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
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
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		elseif true then
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
		if (band(cell_type, TERRAIN_WATER) ~= 0) then
			do
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		elseif true then
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
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		elseif false then
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
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		elseif true then
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
		elseif true then
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
	[171] = function(this, store)
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
		U.animation_start_default(this, "flying", nil, store.tick_ts, s.loop)
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
	[172] = function(this, store)
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
		U.animation_start_default(this, "flying", nil, store.tick_ts, s.loop)
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
	[173] = function(this, store)
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
		U.animation_start_default(this, "flying", nil, store.tick_ts, s.loop)
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
	[174] = function(this, store)
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
		U.animation_start_default(this, "flying", nil, store.tick_ts, s.loop)
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
	[175] = function(this, store)
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
		U.animation_start_default(this, "flying", nil, store.tick_ts, s.loop)
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
	[176] = function(this, store)
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
		U.animation_start_default(this, "flying", nil, store.tick_ts, s.loop)
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
	[177] = function(this, store)
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
		U.animation_start_default(this, "flying", nil, store.tick_ts, s.loop)
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
	[178] = function(this, store)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
	[179] = function(this, store)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
	[180] = function(this, store)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
	[181] = function(this, store)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
	[192] = function(this, store)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
	[193] = function(this, store)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
	[194] = function(this, store)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
	[195] = function(this, store)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
			if ((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
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
						local d = SU.create_bullet_damage(b, hit_target.id, this.id)
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
	[211] = function(this, store)
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
	[212] = function(this, store)
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
	[213] = function(this, store)
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
	[214] = function(this, store)
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
	[215] = function(this, store)
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
	[216] = function(this, store)
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
	[217] = function(this, store)
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
	[218] = function(this, store)
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
	[219] = function(this, store)
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
	[220] = function(this, store)
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
	[221] = function(this, store)
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
	[222] = function(this, store)
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
	[223] = function(this, store)
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
	[224] = function(this, store)
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
	[225] = function(this, store)
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
	if target.unit then
		local s = this.render.sprites[1]
		local flip_sign = 1
		if target.render then
			flip_sign = ((target.render.sprites[1].flip_x and (- 1)) or 1)
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
end
,
	[229] = function(this, store)
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
	[230] = function(this, store)
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
	[231] = function(this, store)
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
	[232] = function(this, store)
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
	[233] = function(this, store)
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
	[234] = function(this, store)
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
	[235] = function(this, store)
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
	[236] = function(this, store)
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
end
,
	[245] = function(this, store)
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
	[246] = function(this, store)
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
	[247] = function(this, store)
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
	[248] = function(this, store)
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
