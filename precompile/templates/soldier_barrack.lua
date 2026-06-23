local soldier_barrack = {}

soldier_barrack.insert = [[
return function(this, store)
	constif(this.melee)
	this.melee.order = U.attack_order(this.melee.attacks)
	constend

	constif(this.ranged)
	this.ranged.order = U.attack_order(this.ranged.attacks)
	constend

	constif(this.auras)
	constfor i = 1, #this.auras.list do
		local a = this.auras.list[i]
		if a.cooldown == 0 then
			local e = E:create_entity(a.name)
			e.pos.x = this.pos.x
			e.pos.y = this.pos.y
			e.aura.level = this.unit.level
			e.aura.source_id = this.id
			e.aura.ts = store.tick_ts
			queue_insert(store, e)
		end
	constend
	constend

	constif(this.track_kills and this.track_kills.mod)
	local mod_name = this.track_kills.mod
	local m = E:create_entity(mod_name)
	m.modifier.target_id = this.id
	m.modifier.source_id = this.id
	m.pos.x = this.pos.x
	m.pos.y = this.pos.y
	queue_insert(store, m)
	constend

	constif(this.track_damage and this.track_damage.mod)
	local e = E:create_entity(this.track_damage.mod)
	e.pos.x = this.pos.x
	e.pos.y = this.pos.y
	e.modifier.target_id = this.id
	e.modifier.source_id = this.id
	queue_insert(store, e)
	constend

	constif(this.powers)
	for pn, p in pairs(this.powers) do
		for i = 1, p.level do
			SU.soldier_power_upgrade(this, pn)
		end
	end
	constend

	constif(this.info and this.info.random_name_format)
	this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""), math.random(this.info.random_name_count))
	constend

	this.vis._bans = this.vis.bans
	this.vis.bans = F_ALL

	constif(this.render)
	constfor i = 1, #this.render.sprites do
		this.render.sprites[i].ts = store.tick_ts - U.frandom(0, 1)
	constend
	constend

	return true
end
]]

soldier_barrack.update = [[
return function(this, store)
	local brk, sta

	if this.vis._bans then
		this.vis.bans = this.vis._bans
		this.vis._bans = nil
	end

	if this.render.sprites[1].name == "raise" then
		this.health_bar.hidden = true
		U.animation_start(this, "raise", nil, store.tick_ts, 1)

		while not U.animation_finished_default(this) and not this.health.dead do
			coroutine.yield()
		end

		if not this.health.dead then
			this.health_bar.hidden = nil
		end
	end

	while true do
		constif(this.powers)
			for pn, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil

					SU.soldier_power_upgrade(this, pn)
				end
			end
		constend

        constif(this.cloak)
        if this.soldier.target_id then
            this.vis.flags = band(this.vis.flags, bnot(this.cloak.flags))
            this.vis.bans = band(this.vis.bans, bnot(this.cloak.bans))
            this.render.sprites[1].alpha = 255
        end
        constend

		if this.health.dead
        @constif(this.revive)
        and not SU.y_soldier_revive(store, this)
        then
			SU.y_soldier_death(store, this)

			return
		end

        @constif(this.revive)
		scripts.soldier_revive_resist(this, store)

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
            constif(this.dodge)
                if this.dodge.active then
                    this.dodge.active = false

                    constif(this.dodge.counter_attack)
                        if this.powers[this.dodge.counter_attack.power_name].level > 0 then
                            this.dodge.counter_attack_pending = true
                    constif(this.dodge.animation)
                        elseif this.dodge.animation then
                            U.animation_start(this, this.dodge.animation, nil, store.tick_ts, 1)

                            while not U.animation_finished_default(this) do
                                coroutine.yield()
                            end
                    constend
                        end
                    constelseif(this.dodge.animation)
                        U.animation_start(this, this.dodge.animation, nil, store.tick_ts, 1)

                        while not U.animation_finished_default(this) do
                            coroutine.yield()
                        end
                    constend

                    signal.emit("soldier-dodge", this)
                end
            constend

			while this.nav_rally.new do
				if SU.y_soldier_new_rally(store, this) then
					goto label_39_1
				end
			end

			constif(this.timed_actions)
				brk, sta = SU.y_soldier_timed_actions(store, this)

				if brk then
					goto label_39_1
				end
			constend

			constif(this.timed_attacks)
				brk, sta = SU.y_soldier_timed_attacks(store, this)

				if brk then
					goto label_39_1
				end
			constend

			constif(this.ranged and this.ranged.range_while_blocking)
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
					goto label_39_1
				end
			constend

			constif(this.melee)
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
					goto label_39_1
				end
			constend

			constif(this.ranged and not this.ranged.range_while_blocking)
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk or sta == A_DONE then
					goto label_39_1
				elseif sta == A_IN_COOLDOWN and not this.ranged.go_back_during_cooldown then
					goto label_39_0
				end
			constend

			if SU.soldier_go_back_step(store, this) then
				goto label_39_1
			end

			::label_39_0::

			SU.soldier_idle(store, this)

			constif(this.cloak)
				this.vis.flags = bor(this.vis.flags, this.cloak.flags)
				this.vis.bans = bor(this.vis.bans, this.cloak.bans)

				@constif(this.cloak.alpha)
				this.render.sprites[1].alpha = this.cloak.alpha
			constend

            @constif(this.regen)
			SU.soldier_regen(store, this)
		end

		::label_39_1::

		coroutine.yield()
	end
end
]]

return soldier_barrack
