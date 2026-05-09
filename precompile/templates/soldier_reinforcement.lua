local soldier_reinforcement = {}

soldier_reinforcement.insert = [[
return function(this, store)
	constif(this.melee)
	this.melee.order = U.attack_order(this.melee.attacks)
	constend

	constif(this.ranged)
	this.ranged.order = U.attack_order(this.ranged.attacks)
	constend

	constif(this.info and this.info.random_name_format)
	this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""), math.random(this.info.random_name_count))
	constend

	return true
end
]]

soldier_reinforcement.update = [[
return function(this, store)
	local brk, stam, star

	this.reinforcement.ts = store.tick_ts
	this.render.sprites[1].ts = store.tick_ts

	constif(this.reinforcement.fade or this.reinforcement.fade_in)
	SU.y_reinforcement_fade_in(store, this)
	constelseif(this.render.sprites[1].name == "raise")
	constif(this.sound_events and this.sound_events.raise)
	S:queue(this.sound_events.raise)
	constend

	this.health_bar.hidden = true
	U.y_animation_play(this, "raise", nil, store.tick_ts, 1)

	if not this.health.dead then
		this.health_bar.hidden = nil
	end
	constend

	while true do
		if this.health.dead or this.reinforcement.duration and store.tick_ts - this.reinforcement.ts > this.reinforcement.duration then
			if this.health.hp > 0 then
				this.reinforcement.hp_before_timeout = this.health.hp
			end

			this.health.hp = 0
			SU.y_soldier_death(store, this)
			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_controable_new_rally(store, this) then
					goto label_34_1
				end
			end

			constif(this.melee)
			brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
				goto label_34_1
			end
			constend

			constif(this.ranged)
			brk, star = SU.y_soldier_ranged_attacks(store, this)

			if brk or star == A_DONE then
				goto label_34_1
			elseif star == A_IN_COOLDOWN then
				goto label_34_0
			end
			constend

			constif(this.melee and this.melee.continue_in_cooldown)
			if stam == A_IN_COOLDOWN then
				goto label_34_1
			end
			constend

			if SU.soldier_go_back_step(store, this) then
				goto label_34_1
			end

			::label_34_0::

			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_34_1::

		coroutine.yield()
	end
end
]]

return soldier_reinforcement
