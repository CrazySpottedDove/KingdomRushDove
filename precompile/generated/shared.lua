return {
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
	do
		this.melee.order = U.attack_order(this.melee.attacks)
	end
	do
	end
	if (this.track_kills and this.track_kills.mod) then
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
	do
		this.melee.order = U.attack_order(this.melee.attacks)
	end
	if (this.track_kills and this.track_kills.mod) then
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
	function(this, store)
	if (this.render.sprites[1].name == "raise") then
		if (this.sound_events and this.sound_events.raise) then
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
						if ((this.ranged and this.ranged.range_while_blocking) and ranged) then
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
	function(this, store)
	if (this.render.sprites[1].name == "raise") then
		if (this.sound_events and this.sound_events.raise) then
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
	function(this, store)
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
		if this.cliff then
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
	function(this, store)
	local b = this.bullet
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)
	if b.rotation_speed then
		this.render.sprites[1].r = (((math.random() - 0.5)) * math.pi)
		b.rotation_speed = (b.rotation_speed * ((((b.to.x > b.from.x) and (- 1)) or 1)))
	end
	if b.hide_radius then
		this.render.sprites[1].hidden = true
	end
	return true
end
,
	function(this, store)
	local b = this.bullet
	if b.target_id then
		local target = store.entities[b.target_id]
		if ((not target) or (target.vis and (band(target.vis.bans, F_RANGED) ~= 0))) then
			return false
		end
	end
	b.speed.x, b.speed.y = V.normalize((b.to.x - b.from.x), (b.to.y - b.from.y))
	local s = this.render.sprites[1]
	if (not b.ignore_rotation) then
		s.r = V.angleTo((b.to.x - this.pos.x), (b.to.y - this.pos.y))
	end
	U.animation_start_default(this, "flying", nil, store.tick_ts, s.loop)
	return true
end
,
	function(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]
	if (not target) then
		return false
	end
	if b.reset_to_target_pos then
		b.to.x, b.to.y = target.pos.x, target.pos.y
		if ((target.unit and target.unit.hit_offset) and (not b.ignore_hit_offset)) then
			b.to.x, b.to.y = (b.to.x + target.unit.hit_offset.x), (b.to.y + target.unit.hit_offset.y)
		end
	end
	if b.predict_target_pos then
		b.to.x = (b.to.x + (target.motion.speed.x * b.flight_time))
		b.to.y = (b.to.y + (target.motion.speed.y * b.flight_time))
	end
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	if b.rotation_speed then
		b.rotation_speed = (b.rotation_speed * ((((b.to.x > this.pos.x) and (- 1)) or 1)))
		if (b.rotation_speed > 0) then
			this.render.sprites[1].flip_x = (not this.render.sprites[1].flip_x)
		end
	end
	if b.hide_radius then
		this.render.sprites[1].hidden = true
	end
	return true
end
,
	function(this, store)
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
	function(this, store)
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
			if (this.ranged and this.ranged.range_while_blocking) then
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
			if (this.ranged and (not this.ranged.range_while_blocking)) then
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
	function(this, store)
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
	function(this, store)
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
			if (this.ranged and this.ranged.range_while_blocking) then
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
			if (this.ranged and (not this.ranged.range_while_blocking)) then
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
	function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if (((target and target.unit) and this.render) and target.render) then
		do
			local i = 1
			local s = this.render.sprites[i]
			s.flip_x = target.render.sprites[1].flip_x
			s.ts = store.tick_ts
			if s.size_names then
				s.name = s.size_names[target.unit.size]
			end
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
	function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if (((target and target.unit) and this.render) and target.render) then
		do
			local i = 1
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
	function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if (((target and target.unit) and this.render) and target.render) then
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
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
	function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if ((target and target.unit) and this.render) then
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
	function(this, store)
	this.aura.ts = store.tick_ts
	do
		for _, s in ipairs(this.render.sprites) do
			s.ts = store.tick_ts
		end
	end
	if this.aura.source_id then
		local target = store.entities[this.aura.source_id]
		if ((((target and this.render) and this.aura.use_mod_offset) and target.unit) and target.unit.mod_offset) then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end
	end
	this.actual_duration = this.aura.duration
	if this.aura.duration_inc then
		this.actual_duration = (this.actual_duration + (this.aura.level * this.aura.duration_inc))
	end
	return true
end
,
	function(this, store)
	this.aura.ts = store.tick_ts
	if this.aura.source_id then
		local target = store.entities[this.aura.source_id]
		if ((((target and this.render) and this.aura.use_mod_offset) and target.unit) and target.unit.mod_offset) then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end
	end
	this.actual_duration = this.aura.duration
	if this.aura.duration_inc then
		this.actual_duration = (this.actual_duration + (this.aura.level * this.aura.duration_inc))
	end
	return true
end
,
	function(this, store)
	local a = this.aura
	local context = this.main_script.context
	if (context.state == 0) then
		this.aura.ts = store.tick_ts
		if ((not a.cycles) and (a.duration >= 0)) then
			this.aura.duration = (this.aura.duration + (this.aura.level * this.aura.duration_inc))
		end
		context.last_hit_ts = 0
		context.cycles_count = 0
		context.state = 1
	end
	if a.cycles then
		if (context.cycles_count >= this.aura.cycles) then
			simulation:queue_remove_entity(this)
			return
		end
	elseif (a.duration >= 0) then
		if ((store.tick_ts - this.aura.ts) >= this.aura.duration) then
			simulation:queue_remove_entity(this)
			return
		end
	end
	if a.track_source then
		local te = store.entities[this.aura.source_id]
		if (((not te) or ((te.health and te.health.dead))) or ((te.enemy and (not te.enemy.can_do_magic)))) then
			simulation:queue_remove_entity(this)
			return
		end
		if te.pos then
			this.pos.x, this.pos.y = te.pos.x, te.pos.y
		end
	end
	if ((store.tick_ts - context.last_hit_ts) >= this.aura.cycle_time) then
		if a.cycles then
			context.cycles_count = (context.cycles_count + 1)
		end
		context.last_hit_ts = store.tick_ts
		local targets
		if (band(a.vis_bans, F_ENEMY) ~= 0) then
			targets = {}
			for _, v in pairs(store.soldiers) do
				if (((((((not v.health.dead) and (band(v.vis.flags, this.aura.vis_bans) == 0)) and (band(v.vis.bans, this.aura.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)) and (((not this.aura.allowed_templates) or table.arraycontains(this.aura.allowed_templates, v.template_name)))) and (((not this.aura.excluded_templates) or (not table.arraycontains(this.aura.excluded_templates, v.template_name))))) and (((not this.aura.filter_source) or (this.aura.source_id ~= v.id)))) then
					targets[((# targets) + 1)] = v
				end
			end
		elseif (band(a.vis_bans, F_FRIEND) ~= 0) then
			if ((a.allowed_templates or a.excluded_templates) or a.filter_source) then
				local aura = this.aura
				local function filter_fn(e)
					return (((((not aura.allowed_templates) or table.arraycontains(aura.allowed_templates, e.template_name))) and (((not aura.excluded_templates) or (not table.arraycontains(aura.excluded_templates, e.template_name))))) and (((not aura.filter_source) or (aura.source_id ~= e.id))))
				end
				targets = U.find_enemies_in_range_filter_on(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans, filter_fn)
			else
				targets = U.find_enemies_in_range_filter_off(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)
			end
		else
			targets = {}
			for _, v in pairs(store.entities) do
				if (((((((((v.unit and v.vis) and v.health) and (not v.health.dead)) and (band(v.vis.flags, this.aura.vis_bans) == 0)) and (band(v.vis.bans, this.aura.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)) and (((not this.aura.allowed_templates) or table.arraycontains(this.aura.allowed_templates, v.template_name)))) and (((not this.aura.excluded_templates) or (not table.arraycontains(this.aura.excluded_templates, v.template_name))))) and (((not this.aura.filter_source) or (this.aura.source_id ~= v.id)))) then
					targets[((# targets) + 1)] = v
				end
			end
		end
		if ((band(a.vis_bans, F_FRIEND) ~= 0) and (not targets)) then
			return
		end
		if ((band(a.vis_bans, F_FRIEND) == 0) and ((# targets) > 0)) then
			local dmin, dmax = this.aura.damage_min, this.aura.damage_max
			if this.aura.damage_inc then
				dmin = (dmin + (this.aura.damage_inc * this.aura.level))
				dmax = (dmax + (this.aura.damage_inc * this.aura.level))
			end
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
					if (a.hide_source_fx and (target.id == this.aura.source_id)) then
						m.render = nil
					end
					simulation:queue_insert_entity(m)
				end
			end
		end
	end
end
,
	function(this, store)
	local a = this.aura
	local context = this.main_script.context
	local function finish()
		if a.with_fade then
			context.state = 3
			U.animation_start_default(this, "out", false, store.tick_ts, false)

		else
			simulation:queue_remove_entity(this)

		end
	end
	local function init_context()
		context.state = 1
		if a.apply_duration then
			context.first_hit_ts = store.tick_ts

		end
		if a.cycles then
			context.cycles_count = 0

		end
		if a.max_count then
			context.victims_count = 0

		end
		if this.ps_names then
			context.ps_instances = {}
			for i = 1, (# this.ps_names) do
				local ps = E:create_entity(this.ps_names[i])
				if this.ps_spread_follow_radius then
					ps.particle_system.emit_area_spread = V.vv(this.aura.radius)

				end
				ps.particle_system.track_id = this.id
				simulation:queue_insert_entity(ps)
				context.ps_instances[i] = ps

			end

		end
		if a.track_source then
			local source = store.entities[this.aura.source_id]
			if (source and source.pos) then
				this.pos = source.pos

			end

		end
		if a.track_target then
			local target = store.entities[this.aura.target_id]
			if (target and target.pos) then
				this.pos = target.pos

			end

		end
		if a.apply_delay then
			context.last_hit_ts = ((store.tick_ts - this.aura.apply_delay) - this.aura.cycle_time)

		else
			context.last_hit_ts = (store.tick_ts - this.aura.cycle_time)

		end
		context.mods = (this.aura.mods or {this.aura.mod})
	end
	if (context.state == 0) then
		if a.with_fade then
			U.animation_start_default(this, "in", false, store.tick_ts, false)
			context.state = 2
		else
			init_context()
		end
	end
	if a.with_fade then
		if (context.state == 2) then
			if U.animation_finished_default(this) then
				init_context()
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
	if (a.cycles and (context.cycles_count >= this.aura.cycles)) then
		finish()
		return
	end
	if ((a.duration >= 0) and ((store.tick_ts - this.aura.ts) > this.actual_duration)) then
		finish()
		return
	end
	if ((((a.track_source and (not a.track_dead))) or a.source_vis_flags) or a.requires_alive_source) then
		local source = store.entities[this.aura.source_id]
		if ((a.track_source and (not a.track_dead)) and (((not source) or ((source.health and source.health.dead))))) then
			finish()
			return
		end
		if (((a.source_vis_flags and source) and source.vis) and (band(source.vis.bans, this.aura.source_vis_flags) ~= 0)) then
			return
		end
		if (((a.requires_alive_source and source) and source.health) and source.health.dead) then
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= this.aura.cycle_time)
	if a.apply_duration then
		apply = (apply and ((store.tick_ts - context.first_hit_ts) <= this.aura.apply_duration))
	end
	if (not apply) then
		return
	end
	context.last_hit_ts = store.tick_ts
	if a.cycles then
		context.cycles_count = (context.cycles_count + 1)
	end
	local targets
	if (band(a.vis_bans, F_ENEMY) ~= 0) then
		targets = {}
		for _, v in pairs(store.soldiers) do
			if (((((((not v.health.dead) and (band(v.vis.flags, this.aura.vis_bans) == 0)) and (band(v.vis.bans, this.aura.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)) and (((not this.aura.allowed_templates) or table.arraycontains(this.aura.allowed_templates, v.template_name)))) and (((not this.aura.excluded_templates) or (not table.arraycontains(this.aura.excluded_templates, v.template_name))))) and (((not this.aura.filter_source) or (this.aura.source_id ~= v.id)))) then
				targets[((# targets) + 1)] = v
			end
		end
	elseif (band(a.vis_bans, F_FRIEND) ~= 0) then
		if ((a.allowed_templates or a.excluded_templates) or a.filter_source) then
			local aura = this.aura
			local function filter_fn(e)
				return (((((not aura.allowed_templates) or table.arraycontains(aura.allowed_templates, e.template_name))) and (((not aura.excluded_templates) or (not table.arraycontains(aura.excluded_templates, e.template_name))))) and (((not aura.filter_source) or (aura.source_id ~= e.id))))
			end
			targets = U.find_enemies_in_range_filter_on(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans, filter_fn)
		else
			targets = U.find_enemies_in_range_filter_off(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)
		end
	else
		targets = {}
		for _, v in pairs(store.entities) do
			if (((((((((v.unit and v.vis) and v.health) and (not v.health.dead)) and (band(v.vis.flags, this.aura.vis_bans) == 0)) and (band(v.vis.bans, this.aura.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)) and (((not this.aura.allowed_templates) or table.arraycontains(this.aura.allowed_templates, v.template_name)))) and (((not this.aura.excluded_templates) or (not table.arraycontains(this.aura.excluded_templates, v.template_name))))) and (((not this.aura.filter_source) or (this.aura.source_id ~= v.id)))) then
				targets[((# targets) + 1)] = v
			end
		end
	end
	if ((band(a.vis_bans, F_FRIEND) ~= 0) and (not targets)) then
		return
	end
	for i = 1, (# targets) do
		if (a.targets_per_cycle and (i > this.aura.targets_per_cycle)) then
			break
		end
		if a.max_count then
			if (context.victims_count >= this.aura.max_count) then
				break
			end
			context.victims_count = (context.victims_count + 1)
		end
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = this.aura.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = this.aura.damage_factor
			if (a.hide_source_fx and (target.id == this.aura.source_id)) then
				new_mod.render = nil
			end
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	function(this, store)
	local a = this.aura
	local context = this.main_script.context
	local function finish()
		if a.with_fade then
			context.state = 3
			U.animation_start_default(this, "out", false, store.tick_ts, false)

		else
			simulation:queue_remove_entity(this)

		end
	end
	local function init_context()
		context.state = 1
		if a.apply_duration then
			context.first_hit_ts = store.tick_ts

		end
		if a.cycles then
			context.cycles_count = 0

		end
		if a.max_count then
			context.victims_count = 0

		end
		if this.ps_names then
			context.ps_instances = {}
			for i = 1, (# this.ps_names) do
				local ps = E:create_entity(this.ps_names[i])
				if this.ps_spread_follow_radius then
					ps.particle_system.emit_area_spread = V.vv(this.aura.radius)

				end
				ps.particle_system.track_id = this.id
				simulation:queue_insert_entity(ps)
				context.ps_instances[i] = ps

			end

		end
		if a.track_source then
			local source = store.entities[this.aura.source_id]
			if (source and source.pos) then
				this.pos = source.pos

			end

		end
		if a.track_target then
			local target = store.entities[this.aura.target_id]
			if (target and target.pos) then
				this.pos = target.pos

			end

		end
		if a.apply_delay then
			context.last_hit_ts = ((store.tick_ts - this.aura.apply_delay) - this.aura.cycle_time)

		else
			context.last_hit_ts = (store.tick_ts - this.aura.cycle_time)

		end
		context.mods = (this.aura.mods or {this.aura.mod})
	end
	if (context.state == 0) then
		if a.with_fade then
			U.animation_start_default(this, "in", false, store.tick_ts, false)
			context.state = 2
		else
			init_context()
		end
	end
	if a.with_fade then
		if (context.state == 2) then
			if U.animation_finished_default(this) then
				init_context()
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
	if (a.cycles and (context.cycles_count >= this.aura.cycles)) then
		finish()
		return
	end
	if ((a.duration >= 0) and ((store.tick_ts - this.aura.ts) > this.actual_duration)) then
		finish()
		return
	end
	if ((((a.track_source and (not a.track_dead))) or a.source_vis_flags) or a.requires_alive_source) then
		local source = store.entities[this.aura.source_id]
		if ((a.track_source and (not a.track_dead)) and (((not source) or ((source.health and source.health.dead))))) then
			finish()
			return
		end
		if (((this.render and source) and source.enemy) and (not source.enemy.can_do_magic)) then
			this.render.sprites[1].hidden = (not source.enemy.can_do_magic)
			return
		end
		if (((a.source_vis_flags and source) and source.vis) and (band(source.vis.bans, this.aura.source_vis_flags) ~= 0)) then
			return
		end
		if (((a.requires_alive_source and source) and source.health) and source.health.dead) then
			return
		end
	end
	local apply = ((store.tick_ts - context.last_hit_ts) >= this.aura.cycle_time)
	if a.apply_duration then
		apply = (apply and ((store.tick_ts - context.first_hit_ts) <= this.aura.apply_duration))
	end
	if (not apply) then
		return
	end
	if (this.render and a.cast_resets_sprite_id) then
		this.render.sprites[this.aura.cast_resets_sprite_id].ts = store.tick_ts
	end
	context.last_hit_ts = store.tick_ts
	if a.cycles then
		context.cycles_count = (context.cycles_count + 1)
	end
	local targets
	if (band(a.vis_bans, F_ENEMY) ~= 0) then
		targets = {}
		for _, v in pairs(store.soldiers) do
			if (((((((not v.health.dead) and (band(v.vis.flags, this.aura.vis_bans) == 0)) and (band(v.vis.bans, this.aura.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)) and (((not this.aura.allowed_templates) or table.arraycontains(this.aura.allowed_templates, v.template_name)))) and (((not this.aura.excluded_templates) or (not table.arraycontains(this.aura.excluded_templates, v.template_name))))) and (((not this.aura.filter_source) or (this.aura.source_id ~= v.id)))) then
				targets[((# targets) + 1)] = v
			end
		end
	elseif (band(a.vis_bans, F_FRIEND) ~= 0) then
		if ((a.allowed_templates or a.excluded_templates) or a.filter_source) then
			local aura = this.aura
			local function filter_fn(e)
				return (((((not aura.allowed_templates) or table.arraycontains(aura.allowed_templates, e.template_name))) and (((not aura.excluded_templates) or (not table.arraycontains(aura.excluded_templates, e.template_name))))) and (((not aura.filter_source) or (aura.source_id ~= e.id))))
			end
			targets = U.find_enemies_in_range_filter_on(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans, filter_fn)
		else
			targets = U.find_enemies_in_range_filter_off(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)
		end
	else
		targets = {}
		for _, v in pairs(store.entities) do
			if (((((((((v.unit and v.vis) and v.health) and (not v.health.dead)) and (band(v.vis.flags, this.aura.vis_bans) == 0)) and (band(v.vis.bans, this.aura.vis_flags) == 0)) and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)) and (((not this.aura.allowed_templates) or table.arraycontains(this.aura.allowed_templates, v.template_name)))) and (((not this.aura.excluded_templates) or (not table.arraycontains(this.aura.excluded_templates, v.template_name))))) and (((not this.aura.filter_source) or (this.aura.source_id ~= v.id)))) then
				targets[((# targets) + 1)] = v
			end
		end
	end
	if ((band(a.vis_bans, F_FRIEND) ~= 0) and (not targets)) then
		return
	end
	for i = 1, (# targets) do
		if (a.targets_per_cycle and (i > this.aura.targets_per_cycle)) then
			break
		end
		if a.max_count then
			if (context.victims_count >= this.aura.max_count) then
				break
			end
			context.victims_count = (context.victims_count + 1)
		end
		local target = targets[i]
		local mods = context.mods
		for j = 1, (# mods) do
			local new_mod = E:create_entity(mods[j])
			new_mod.modifier.level = this.aura.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = this.id
			new_mod.modifier.damage_factor = this.aura.damage_factor
			if (a.hide_source_fx and (target.id == this.aura.source_id)) then
				new_mod.render = nil
			end
			simulation:queue_insert_entity(new_mod)
		end
	end
end
,
	function(this, store)
	local b = this.bullet
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)
	if b.rotation_speed then
		this.render.sprites[1].r = (((math.random() - 0.5)) * math.pi)
		b.rotation_speed = (b.rotation_speed * ((((b.to.x > b.from.x) and (- 1)) or 1)))
	end
	if b.hide_radius then
		this.render.sprites[1].hidden = true
	end
	return true
end
,
	function(this, store)
	local b = this.bullet
	if b.target_id then
		local target = store.entities[b.target_id]
		if ((not target) or (target.vis and (band(target.vis.bans, F_RANGED) ~= 0))) then
			return false
		end
	end
	b.speed.x, b.speed.y = V.normalize((b.to.x - b.from.x), (b.to.y - b.from.y))
	local s = this.render.sprites[1]
	if (not b.ignore_rotation) then
		s.r = V.angleTo((b.to.x - this.pos.x), (b.to.y - this.pos.y))
	end
	U.animation_start_default(this, "flying", nil, store.tick_ts, s.loop)
	return true
end
,
	function(this, store)
	local b = this.bullet
	local context = this.main_script.context
	if (context.state == 0) then
		context.dmin = b.damage_min
		context.dmax = b.damage_max
		context.dradius = b.damage_radius
		if b.damage_radius_inc then
			context.dradius = (context.dradius + (b.level * b.damage_radius_inc))
		end
		if b.damage_min_inc then
			context.dmin = (context.dmin + (b.level * b.damage_min_inc))
		end
		if b.damage_max_inc then
			context.dmax = (context.dmax + (b.level * b.damage_max_inc))
		end
		if b.particles_name then
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
		if b.use_hit_offset then
			if b._hit_offset_record then
				local hit_pos = V.vclone(this.pos)
				hit_pos.x = (hit_pos.x - b._hit_offset_record.x)
				hit_pos.y = (hit_pos.y - b._hit_offset_record.y)
				enemies = U.find_enemies_in_range_filter_off(hit_pos, context.dradius, b.damage_flags, b.damage_bans)
			else
				enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
			end
		else
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
		if b.pop then
			simulation:queue_insert_entity(SU.create_pop(store, this.pos, b.pop))
		end
		local cell_type = GR:cell_type(this.pos.x, this.pos.y)
		if (b.hit_fx_water and (band(cell_type, TERRAIN_WATER) ~= 0)) then
			if (this.sound_events and this.sound_events.hit_water) then
				S:queue(this.sound_events.hit_water)
			end
			local water_fx = E:create_entity(b.hit_fx_water)
			water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
			water_fx.render.sprites[1].ts = store.tick_ts
			water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(water_fx)
		elseif b.hit_fx then
			if (this.sound_events and this.sound_events.hit) then
				S:queue(this.sound_events.hit)
			end
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
			simulation:queue_insert_entity(sfx)
		end
		if (b.hit_decal and (band(cell_type, TERRAIN_WATER) == 0)) then
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
	if b.align_with_trajectory then
		this.render.sprites[1].r = math.atan2(context.v_y, context.v_x)
	elseif b.rotation_speed then
		this.render.sprites[1].r = (this.render.sprites[1].r + (b.rotation_speed * store.tick_length))
	end
	if b.hide_radius then
		this.render.sprites[1].hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < (b.hide_radius * b.hide_radius)) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < (b.hide_radius * b.hide_radius)))
	end
	context.v_y = (context.v_y + dv_y)
	context.last_ts = store.tick_ts
end
,
	function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local context = this.main_script.context
	if (context.state == 0) then
		context.mspeed = b.min_speed
		context.new_target = false
		context.target_invalid = false
		if b.particles_name then
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		if (b.store and (not b.target_id)) then
			if (this.sound_events and this.sound_events.summon) then
				S:queue(this.sound_events.summon)
			end
			s.z = Z_OBJECTS
			s.sort_y_offset = b.store_sort_y_offset
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
			if b.particles_name then
				context.ps.particle_system.emit = false
			end
			context.state = 2
		else
			context.state = 1
		end
	end
	if (context.state == 1) then
		if (this.sound_events and this.sound_events.travel) then
			S:queue(this.sound_events.travel)
		end
		s.z = Z_BULLETS
		s.sort_y_offset = nil
		U.animation_start_default(this, "flying", nil, store.tick_ts, s.loop)
		if b.particles_name then
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
		if b.hit_fx then
			local sfx = E:create_entity(b.hit_fx)
			sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].runs = 0
			if ((E:get_template(b.hit_fx).render and E:get_template(b.hit_fx).render.sprites[1].size_names) and target) then
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
	if (target and (not context.new_target)) then
		local tpx, tpy = target.pos.x, target.pos.y
		if (not b.ignore_hit_offset) then
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
	if (not b.ignore_rotation) then
		s.r = V.angleTo((b.to.x - this.pos.x), (b.to.y - this.pos.y))
	end
	if b.particles_name then
		context.ps.particle_system.emit_direction = s.r
	end
end
,
	function(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local context = this.main_script.context
	if (context.state == 0) then
		if b.particles_name then
			local ps = E:create_entity(b.particles_name)
			ps.particle_system.track_id = this.id
			simulation:queue_insert_entity(ps)
			context.ps = ps
		end
		if b.straight_forward_distance then
			context.last_x = this.pos.x
			context.last_y = this.pos.y
			context.last_ts = store.tick_ts
			context.speed_norm2 = ((b.speed.x * b.speed.x) + (b.speed.y * b.speed.y))
			context.hitted = {}
			if b.mod then
				context.mods = {b.mod}
			elseif b.mods then
				context.mods = b.mods
			end
		else
			context.last_ts = store.tick_ts
			context.v_x = b.speed.x
			context.v_y = b.speed.y
			this.pos.x, this.pos.y = b.from.x, b.from.y
			context.expected_stop_time = ((b.ts + b.flight_time) - store.tick_length)
		end
		if b.damage_min_inc then
			b.damage_min = (b.damage_min + (b.damage_min_inc * b.level))
		end
		if b.damage_max_inc then
			b.damage_max = (b.damage_max + (b.damage_max_inc * b.level))
		end
		context.state = 1
	end
	if (context.state == 1) then
		if b.straight_forward_distance then
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
						if b.hit_fx then
							local fx = E:create_entity(b.hit_fx)
							fx.pos = V.vclone(hit_target.pos)
							fx.render.sprites[1].ts = store.tick_ts
							simulation:queue_insert_entity(fx)
						end
						if (b.hit_blood_fx and (hit_target.unit.blood_color ~= BLOOD_NONE)) then
							local sfx = E:create_entity(b.hit_blood_fx)
							sfx.pos = V.vclone(hit_target.pos)
							sfx.render.sprites[1].ts = store.tick_ts
							if (E:get_template(b.hit_blood_fx).use_blood_color and hit_target.unit.blood_color) then
								sfx.render.sprites[1].name = hit_target.unit.blood_color
								sfx.render.sprites[1].r = s.r
							end
							simulation:queue_insert_entity(sfx)
						end
					end
				end
			end
			do
				context.state = 3
			end
		else
			local dt = (store.tick_ts - context.last_ts)
			local dv_y = (b.g * dt)
			this.pos.x = (this.pos.x + (context.v_x * dt))
			this.pos.y = (this.pos.y + (((context.v_y + (0.5 * dv_y))) * dt))
			if b.rotation_speed then
				s.r = (s.r + (b.rotation_speed * store.tick_length))
			else
				s.r = math.atan2(context.v_y, context.v_x)
				if (b.asymmetrical and (math.abs(s.r) > (math.pi * 0.5))) then
					s.flip_y = true
				end
			end
			if b.particles_name then
				context.ps.particle_system.emit_direction = s.r
			end
			if b.hide_radius then
				local hide_radius_squared = (b.hide_radius * b.hide_radius)
				s.hidden = ((V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared) or (V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared))
				if b.particles_name then
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
	if ((not b.straight_forward_distance) and (context.state == 2)) then
		local hit = false
		if (target and (not target.health.dead)) then
			local target_pos = V.vclone(target.pos)
			if (((not b.ignore_hit_offset) and target.unit) and target.unit.hit_offset) then
				target_pos.x, target_pos.y = (target_pos.x + target.unit.hit_offset.x), (target_pos.y + target.unit.hit_offset.y)
			end
			if (((V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < ((b.hit_distance * b.hit_distance) * 1.44)) and (not SU.unit_dodges(store, target, true))) and (((not b.hit_chance) or (math.random() < b.hit_chance)))) then
				hit = true
				local d = SU.create_bullet_damage(b, target.id, this.id)
				queue_damage(store, d)
				local mods
				if b.mod then
					mods = {b.mod}
				elseif b.mods then
					mods = b.mods
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
				if b.hit_fx then
					local fx = E:create_entity(b.hit_fx)
					fx.pos = V.vclone(target_pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
				if (b.hit_blood_fx and (target.unit.blood_color ~= BLOOD_NONE)) then
					local sfx = E:create_entity(b.hit_blood_fx)
					sfx.pos = V.vclone(target_pos)
					sfx.render.sprites[1].ts = store.tick_ts
					if (E:get_template(b.hit_blood_fx).use_blood_color and target.unit.blood_color) then
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
		if b.payload then
			local p = E:create_entity(b.payload)
			p.pos.x, p.pos.y = this.pos.x, this.pos.y
			p.target_id = b.target_id
			p.source_id = b.source_id
			if E:get_template(b.payload).aura then
				p.aura.level = b.level
				p.aura.damage_factor = b.damage_factor
				p.aura.target_id = b.target_id
			end
			if b.payload_props then
				for k, v in pairs(b.payload_props) do
					p[k] = v
				end
			end
			simulation:queue_insert_entity(p)
		end
		if b.particles_name then
			if context.ps.particle_system.emit then
				s.hidden = true
				context.ps.particle_system.emit = false
				context.wait_until_ts = (store.tick_ts + context.ps.particle_system.particle_lifetime[2])
				context.state = 4
			else
				simulation:queue_remove_entity(this)
				return
			end
		else
			simulation:queue_remove_entity(this)
			return
		end
	end
	if (b.particles_name and (context.state == 4)) then
		if (store.tick_ts >= context.wait_until_ts) then
			simulation:queue_remove_entity(this)
			return
		end
	end
end
,
	function(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]
	if (not target) then
		return false
	end
	if b.reset_to_target_pos then
		b.to.x, b.to.y = target.pos.x, target.pos.y
		if ((target.unit and target.unit.hit_offset) and (not b.ignore_hit_offset)) then
			b.to.x, b.to.y = (b.to.x + target.unit.hit_offset.x), (b.to.y + target.unit.hit_offset.y)
		end
	end
	if b.predict_target_pos then
		b.to.x = (b.to.x + (target.motion.speed.x * b.flight_time))
		b.to.y = (b.to.y + (target.motion.speed.y * b.flight_time))
	end
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	if b.rotation_speed then
		b.rotation_speed = (b.rotation_speed * ((((b.to.x > this.pos.x) and (- 1)) or 1)))
		if (b.rotation_speed > 0) then
			this.render.sprites[1].flip_x = (not this.render.sprites[1].flip_x)
		end
	end
	if b.hide_radius then
		this.render.sprites[1].hidden = true
	end
	return true
end
,
	function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if (((target and target.unit) and this.render) and target.render) then
		do
			local i = 1
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
	function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if (((target and target.unit) and this.render) and target.render) then
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
	function(this, store)
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
	if ((m.duration and (m.duration >= 0)) and ((store.tick_ts - m.ts) > m.duration)) then
		simulation:queue_remove_entity(this)
		return
	end
	if (m.last_node and (target.nav_path.ni > m.last_node)) then
		simulation:queue_remove_entity(this)
		return
	end
	if (this.render and target.unit) then
		local s = this.render.sprites[1]
		local flip_sign = 1
		if target.render then
			flip_sign = ((target.render.sprites[1].flip_x and (- 1)) or 1)
		end
		if (m.health_bar_offset and target.health_bar) then
			local hb = target.health_bar.offset
			local hbo = m.health_bar_offset
			s.offset.x, s.offset.y = (hb.x + (hbo.x * flip_sign)), (hb.y + hbo.y)
		elseif (m.use_mod_offset and target.unit.mod_offset) then
			s.offset.x, s.offset.y = (target.unit.mod_offset.x * flip_sign), target.unit.mod_offset.y
		end
	end
end
,
	function(this, store)
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
	if ((m.duration and (m.duration >= 0)) and ((store.tick_ts - m.ts) > m.duration)) then
		simulation:queue_remove_entity(this)
		return
	end
	if (m.last_node and (target.nav_path.ni > m.last_node)) then
		simulation:queue_remove_entity(this)
		return
	end
end
,
	function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		return false
	end
	if ((band(this.modifier.vis_flags, target.vis.bans) ~= 0) or (band(this.modifier.vis_bans, target.vis.flags) ~= 0)) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)
		return false
	end
	if ((target and target.unit) and this.render) then
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
	function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	local dps = this.dps
	local m = this.modifier
	if (context.state == 0) then
		if dps.damage_first then
			context.cycles = 0
		end
		if (dps.damage_inc ~= 0) then
			context.dmin = (dps.damage_min + (m.level * dps.damage_inc))
			context.dmax = (dps.damage_max + (m.level * dps.damage_inc))
		else
			context.dmin, context.dmax = dps.damage_min, dps.damage_max
		end
		if (dps.damage_every and dps.fx_every) then
			context.fx_ts = 0
		end
		this.pos = target.pos
		context.state = 1
	end
	if ((store.tick_ts - m.ts) >= (m.duration - 1e-09)) then
		if dps.damage_last then
			local d = E.assign_damage(dps.damage_type, (dps.damage_last * m.damage_factor), this.id, target.id)
			d.pop = dps.pop
			d.pop_chance = dps.pop_chance
			d.pop_conds = dps.pop_conds
			queue_damage(store, d)
		end
		simulation:queue_remove_entity(this)
		return
	end
	if ((this.render and m.use_mod_offset) and target.unit.mod_offset) then
		this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
	end
	if (dps.damage_every and ((store.tick_ts - dps.ts) >= dps.damage_every)) then
		dps.ts = (dps.ts + dps.damage_every)
		local damage_value = math.random(context.dmin, context.dmax)
		if dps.damage_first then
			context.cycles = (context.cycles + 1)
			if (context.cycles == 1) then
				damage_value = dps.damage_first
			end
		end
		damage_value = (damage_value * m.damage_factor)
		if (not dps.kill) then
			damage_value = km.clamp(0, (target.health.hp - 1), damage_value)
		end
		local d = E.assign_damage(dps.damage_type, damage_value, this.id, target.id)
		d.pop = dps.pop
		d.pop_chance = dps.pop_chance
		d.pop_conds = dps.pop_conds
		queue_damage(store, d)
		if ((dps.fx and (((not dps.fx_every) or ((store.tick_ts - context.fx_ts) >= dps.fx_every)))) and (((not E:get_template(dps.fx).render.sprites[1].use_blood_color) or target.unit.blood_color))) then
			if dps.fx_every then
				context.fx_ts = store.tick_ts
			end
			local fx = E:create_entity(dps.fx)
			if dps.fx_tracks_target then
				fx.pos = target.pos
				if (m.use_mod_offset and target.unit.mod_offset) then
					fx.render.sprites[1].offset.x = target.unit.mod_offset.x
					fx.render.sprites[1].offset.y = target.unit.mod_offset.y
				end
			else
				fx.pos = V.vclone(this.pos)
				if (m.use_mod_offset and target.unit.mod_offset) then
					fx.pos.x, fx.pos.y = (fx.pos.x + target.unit.mod_offset.x), (fx.pos.y + target.unit.mod_offset.y)
				end
			end
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].runs = 0
			if E:get_template(dps.fx).render.sprites[1].size_names then
				fx.render.sprites[1].name = fx.render.sprites[1].size_names[target.unit.size]
			end
			if E:get_template(dps.fx).render.sprites[1].use_blood_color then
				fx.render.sprites[1].name = (fx.render.sprites[1].name .. ("_" .. target.unit.blood_color))
			end
			if (dps.fx_target_flip and target.render) then
				fx.render.sprites[1].flip_x = target.render.sprites[1].flip_x
			end
			simulation:queue_insert_entity(fx)
		end
	end
end
,
	function(this, store)
	local target = store.entities[this.modifier.target_id]
	if ((not target) or target.health.dead) then
		simulation:queue_remove_entity(this)
		return
	end
	local context = this.main_script.context
	local dps = this.dps
	local m = this.modifier
	if (context.state == 0) then
		if dps.damage_first then
			context.cycles = 0
		end
		if (dps.damage_inc ~= 0) then
			context.dmin = (dps.damage_min + (m.level * dps.damage_inc))
			context.dmax = (dps.damage_max + (m.level * dps.damage_inc))
		else
			context.dmin, context.dmax = dps.damage_min, dps.damage_max
		end
		if (dps.damage_every and dps.fx_every) then
			context.fx_ts = 0
		end
		this.pos = target.pos
		context.state = 1
	end
	if ((store.tick_ts - m.ts) >= (m.duration - 1e-09)) then
		if dps.damage_last then
			local d = E.assign_damage(dps.damage_type, (dps.damage_last * m.damage_factor), this.id, target.id)
			d.pop = dps.pop
			d.pop_chance = dps.pop_chance
			d.pop_conds = dps.pop_conds
			queue_damage(store, d)
		end
		simulation:queue_remove_entity(this)
		return
	end
	if (dps.damage_every and ((store.tick_ts - dps.ts) >= dps.damage_every)) then
		dps.ts = (dps.ts + dps.damage_every)
		local damage_value = math.random(context.dmin, context.dmax)
		if dps.damage_first then
			context.cycles = (context.cycles + 1)
			if (context.cycles == 1) then
				damage_value = dps.damage_first
			end
		end
		damage_value = (damage_value * m.damage_factor)
		if (not dps.kill) then
			damage_value = km.clamp(0, (target.health.hp - 1), damage_value)
		end
		local d = E.assign_damage(dps.damage_type, damage_value, this.id, target.id)
		d.pop = dps.pop
		d.pop_chance = dps.pop_chance
		d.pop_conds = dps.pop_conds
		queue_damage(store, d)
		if ((dps.fx and (((not dps.fx_every) or ((store.tick_ts - context.fx_ts) >= dps.fx_every)))) and (((not E:get_template(dps.fx).render.sprites[1].use_blood_color) or target.unit.blood_color))) then
			if dps.fx_every then
				context.fx_ts = store.tick_ts
			end
			local fx = E:create_entity(dps.fx)
			if dps.fx_tracks_target then
				fx.pos = target.pos
				if (m.use_mod_offset and target.unit.mod_offset) then
					fx.render.sprites[1].offset.x = target.unit.mod_offset.x
					fx.render.sprites[1].offset.y = target.unit.mod_offset.y
				end
			else
				fx.pos = V.vclone(this.pos)
				if (m.use_mod_offset and target.unit.mod_offset) then
					fx.pos.x, fx.pos.y = (fx.pos.x + target.unit.mod_offset.x), (fx.pos.y + target.unit.mod_offset.y)
				end
			end
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].runs = 0
			if E:get_template(dps.fx).render.sprites[1].size_names then
				fx.render.sprites[1].name = fx.render.sprites[1].size_names[target.unit.size]
			end
			if E:get_template(dps.fx).render.sprites[1].use_blood_color then
				fx.render.sprites[1].name = (fx.render.sprites[1].name .. ("_" .. target.unit.blood_color))
			end
			if (dps.fx_target_flip and target.render) then
				fx.render.sprites[1].flip_x = target.render.sprites[1].flip_x
			end
			simulation:queue_insert_entity(fx)
		end
	end
end
,
	function(this, store)
	this.aura.ts = store.tick_ts
	do
		for _, s in ipairs(this.render.sprites) do
			s.ts = store.tick_ts
		end
	end
	if this.aura.source_id then
		local target = store.entities[this.aura.source_id]
		if ((((target and this.render) and this.aura.use_mod_offset) and target.unit) and target.unit.mod_offset) then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end
	end
	this.actual_duration = this.aura.duration
	if this.aura.duration_inc then
		this.actual_duration = (this.actual_duration + (this.aura.level * this.aura.duration_inc))
	end
	return true
end
,
	function(this, store)
	this.aura.ts = store.tick_ts
	if this.aura.source_id then
		local target = store.entities[this.aura.source_id]
		if ((((target and this.render) and this.aura.use_mod_offset) and target.unit) and target.unit.mod_offset) then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end
	end
	this.actual_duration = this.aura.duration
	if this.aura.duration_inc then
		this.actual_duration = (this.actual_duration + (this.aura.level * this.aura.duration_inc))
	end
	return true
end
,
}
