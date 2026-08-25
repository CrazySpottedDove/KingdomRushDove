local bomb = {}

bomb.insert = [[
return function(this, store)
	constvar b = this.bullet
	local b = this.bullet

    constif(b.use_hit_offset)
        if b.target_id then
            local target = store.entities[b.target_id]
            if target then
                b._hit_offset_record = target.unit.hit_offset
            end
        end
    constend

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
    local context = this.main_script.context

    if context.state == 0 then
        context.dmin = b.damage_min
        context.dmax = b.damage_max
        context.dradius = b.damage_radius

        @constif(b.damage_radius_inc)
        context.dradius = context.dradius + b.level * b.damage_radius_inc

        @constif(b.damage_min_inc)
        context.dmin = context.dmin + b.level * b.damage_min_inc

        @constif(b.damage_max_inc)
        context.dmax = context.dmax + b.level * b.damage_max_inc

        constif(b.particles_name)
            local ps = E:create_entity(b.particles_name)
            ps.particle_system.track_id = this.id
            simulation:queue_insert_entity(ps)
            context.ps = ps
        constend

        context.v_x = b.speed.x
        context.v_y = b.speed.y
        context.last_ts = store.tick_ts
        context.expected_stop_time = b.ts + b.flight_time - store.tick_length

        this.pos.x = b.from.x
        this.pos.y = b.from.y

        context.state = 1
    end

    if store.tick_ts >= context.expected_stop_time then
        local dt = context.expected_stop_time - context.last_ts

        this.pos.x = this.pos.x + context.v_x * dt
        this.pos.y = this.pos.y + (context.v_y + 0.5 * b.g * dt) * dt

        constif(b.use_hit_offset)
        local enemies
        if b._hit_offset_record then
            local hit_pos = V.vclone(this.pos)
            hit_pos.x = hit_pos.x - b._hit_offset_record.x
            hit_pos.y = hit_pos.y - b._hit_offset_record.y
            enemies = U.find_enemies_in_range_filter_off(hit_pos, context.dradius, b.damage_flags, b.damage_bans)
        else
            enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
        end
        constelse
        local enemies = U.find_enemies_in_range_filter_off(this.pos, context.dradius, b.damage_flags, b.damage_bans)
        constend

        local mods

        if b.mod then
            mods = {b.mod}
        elseif b.mods then
            mods = b.mods
        end

        if enemies then
            for i = 1, #enemies do
                local enemy = enemies[i]
                local d = SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)

                if UP:get_upgrade("engineer_efficiency") then
                    d.value = context.dmax
                else
                    local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, context.dradius)
                    d.value = context.dmax - (context.dmax - context.dmin) * dist_factor
                end

                d.value = b.damage_factor * d.value

                queue_damage(store, d)

                if mods then
                    for j = 1, #mods do
                        local mod_name = mods[j]

                        if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
                            local mod = E:create_entity(mod_name)
                            mod.modifier.source_damage = d
                            mod.modifier.damage_factor = b.damage_factor
                            mod.modifier.target_id = enemy.id
                            mod.modifier.source_id = this.id
                            mod.modifier.level = b.level

                            simulation:queue_insert_entity(mod)
                        end
                    end
                end
            end
        end

        constif(b.pop)
            local pop = SU.create_pop(store, this.pos, b.pop)
            simulation:queue_insert_entity(pop)
        constend

        @constif(b.hit_fx_water or b.hit_decal)
        local cell_type = GR:cell_type(this.pos.x, this.pos.y)

        constif(b.hit_fx_water)
            if band(cell_type, TERRAIN_WATER) ~= 0 then
                @constif(this.sound_events and this.sound_events.hit_water)
                S:queue(this.sound_events.hit_water)

                local water_fx = E:create_entity(b.hit_fx_water)

                water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
                water_fx.render.sprites[1].ts = store.tick_ts
                water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset

                simulation:queue_insert_entity(water_fx)
            constif(b.hit_fx)
            else
                @constif(this.sound_events and this.sound_events.hit)
                S:queue(this.sound_events.hit)

                local sfx = E:create_entity(b.hit_fx)

                sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
                sfx.render.sprites[1].ts = store.tick_ts
                sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset

                simulation:queue_insert_entity(sfx)
            constend
            end
        constelse
            constif(b.hit_fx)
                @constif(this.sound_events and this.sound_events.hit)
                S:queue(this.sound_events.hit)

                local sfx = E:create_entity(b.hit_fx)

                sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
                sfx.render.sprites[1].ts = store.tick_ts
                sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset

                simulation:queue_insert_entity(sfx)
            constend
        constend

        constif(b.hit_decal)
            if band(cell_type, TERRAIN_WATER) == 0 then
                local decal = E:create_entity(b.hit_decal)

                decal.pos = V.vclone(this.pos)
                decal.render.sprites[1].ts = store.tick_ts

                simulation:queue_insert_entity(decal)
            end
        constend

        if b.hit_payload then
            local hp = type(b.hit_payload) == "string" and E:create_entity(b.hit_payload) or b.hit_payload

            hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
            hp.source_id = b.source_id

            if hp.unit then
                hp.unit.damage_factor = this.bullet.damage_factor * hp.unit.damage_factor
                if hp.nav_rally and hp.nav_rally.pos.x == 0 and hp.nav_rally.pos.y == 0 then
                    hp.nav_rally.pos:copy(hp.pos)
                    hp.nav_rally.center:copy(hp.pos)
                end
            end

            if hp.aura then
                hp.aura.level = this.bullet.level
                hp.aura.damage_factor = this.bullet.damage_factor * hp.aura.damage_factor
            end

            simulation:queue_insert_entity(hp)
        end

        simulation:queue_remove_entity(this)
        return
    end

    local dt = store.tick_ts - context.last_ts
    local dv_y = b.g * dt

    this.pos.x = this.pos.x + context.v_x * dt
    this.pos.y = this.pos.y + (context.v_y + dv_y) * dt

    constif(b.align_with_trajectory)
        this.render.sprites[1].r = math.atan2(context.v_y, context.v_x)
    constelseif(b.rotation_speed)
        this.render.sprites[1].r = this.render.sprites[1].r + b.rotation_speed * store.tick_length
    constend

    @constif(b.hide_radius)
    this.render.sprites[1].hidden = V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < b.hide_radius * b.hide_radius or V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < b.hide_radius * b.hide_radius

    context.v_y = context.v_y + dv_y
    context.last_ts = store.tick_ts
end
]]

return bomb
