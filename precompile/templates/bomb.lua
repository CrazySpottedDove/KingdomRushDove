local bomb = {}

bomb.insert = [[
return function(this, store)
	constvar b = this.bullet
	local b = this.bullet

	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)

	constif(b.rotation_speed)
		this.render.sprites[1].r = (math.random() - 0.5) * math.pi
		b.rotation_speed = b.rotation_speed * (b.to.x > b.from.x and -1 or 1)
	constend

	@constif(b.hide_radius)
	this.render.sprites[1].hidden = true

	return true
end
]]

bomb.update = [[
return function(this, store)
	constvar b = this.bullet
	local b = this.bullet
	local dmin, dmax = b.damage_min, b.damage_max
	local dradius = b.damage_radius

    @constif(b.damage_radius_inc)
    dradius = dradius + b.level * b.damage_radius_inc

    @constif(b.damage_min_inc)
    dmin = dmin + b.level * b.damage_min_inc

    @constif(b.damage_max_inc)
    dmax = dmax + b.level * b.damage_max_inc

	constif(b.particles_name)
		local ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id
		queue_insert(store, ps)
	constend

	local expected_stop_time = b.ts + b.flight_time - store.tick_length
	local this_pos = this.pos

	this_pos.x = b.from.x
	this_pos.y = b.from.y

	local v_x = b.speed.x
	local v_y = b.speed.y
	local last_ts = store.tick_ts
	local sprites = this.render.sprites

	while store.tick_ts < expected_stop_time do
		coroutine.yield()

		local dt = store.tick_ts - last_ts

		this_pos.x = this_pos.x + v_x * dt
		this_pos.y = this_pos.y + v_y * dt

		constif(b.align_with_trajectory)
			sprites[1].r = math.atan2(v_y, v_x)
		constelseif(b.rotation_speed)
			sprites[1].r = sprites[1].r + b.rotation_speed * store.tick_length
		constend

		@constif(b.hide_radius)
		sprites[1].hidden = V.dist2(this_pos.x, this_pos.y, b.from.x, b.from.y) < b.hide_radius * b.hide_radius or V.dist2(this_pos.x, this_pos.y, b.to.x, b.to.y) < b.hide_radius * b.hide_radius

		v_y = v_y + b.g * dt
		last_ts = last_ts + dt
	end

	local enemies = U.find_enemies_in_range_filter_off(this_pos, dradius, b.damage_flags, b.damage_bans)

	local mods
	if b.mod then
		mods = type(b.mod) == "string" and {b.mod} or b.mod
	elseif b.mods then
		mods = b.mods
	end

	if enemies then
		for i = 1, #enemies do
			local enemy = enemies[i]
			local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)

			if UP:get_upgrade("engineer_efficiency") then
				d.value = dmax
			else
				local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, dradius)
				d.value = dmax - (dmax - dmin) * dist_factor
			end

			d.value = b.damage_factor * d.value

			queue_damage(store, d)

			if mods then
				for j = 1, #mods do
					local mod_name = mods[j]

					if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
						local mod = E:create_entity(mod_name)

						mod.modifier.damage_factor = b.damage_factor
						mod.modifier.target_id = enemy.id
						mod.modifier.source_id = this.id

						queue_insert(store, mod)
					end
				end
			end
		end
	end

    constif(b.pop)
	    local pop = SU.create_pop(store, this.pos, b.pop)
        queue_insert(store, pop)
    constend

    @constif(b.hit_fx_water or b.hit_decal)
    local cell_type = GR:cell_type(this_pos.x, this_pos.y)

    constif(b.hit_fx_water)
        if band(cell_type, TERRAIN_WATER) ~= 0 then
            @constif(this.sound_events and this.sound_events.hit_water)
            S:queue(this.sound_events.hit_water)

            local water_fx = E:create_entity(b.hit_fx_water)

            water_fx.pos.x, water_fx.pos.y = this_pos.x, this_pos.y
            water_fx.render.sprites[1].ts = store.tick_ts
            water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset

            queue_insert(store, water_fx)
        constif(b.hit_fx)
        else
            @constif(this.sound_events and this.sound_events.hit)
            S:queue(this.sound_events.hit)

            local sfx = E:create_entity(b.hit_fx)

            sfx.pos.x, sfx.pos.y = this_pos.x, this_pos.y
            sfx.render.sprites[1].ts = store.tick_ts
            sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset

            queue_insert(store, sfx)
        constend
        end
    constelse
        constif(b.hit_fx)
            @constif(this.sound_events and this.sound_events.hit)
            S:queue(this.sound_events.hit)

            local sfx = E:create_entity(b.hit_fx)

            sfx.pos.x, sfx.pos.y = this_pos.x, this_pos.y
            sfx.render.sprites[1].ts = store.tick_ts
            sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset

            queue_insert(store, sfx)
        constend
    constend

	constif(b.hit_decal)
    if band(cell_type, TERRAIN_WATER) == 0 then
        local decal = E:create_entity(b.hit_decal)

        decal.pos = V.vclone(this_pos)
        decal.render.sprites[1].ts = store.tick_ts

        queue_insert(store, decal)
    end
    constend

	if b.hit_payload then
		local hp = type(b.hit_payload) == "string" and E:create_entity(b.hit_payload) or b.hit_payload

		hp.pos.x, hp.pos.y = this_pos.x, this_pos.y
		hp.source_id = b.source_id

		if hp.unit then
			hp.unit.damage_factor = this.bullet.damage_factor * hp.unit.damage_factor
		end

		if hp.aura then
			hp.aura.level = this.bullet.level
			hp.aura.damage_factor = this.bullet.damage_factor * hp.aura.damage_factor
		end

		queue_insert(store, hp)
	end

	queue_remove(store, this)
end
]]

return bomb
