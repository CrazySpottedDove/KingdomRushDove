local arrow = {}

arrow.insert = [[
return function(this, store)
	constvar b = this.bullet
	local b = this.bullet
	local target = store.entities[b.target_id]

	if not target then
		return false
	end

    @constif(b.flight_time_min and b.flight_time_per_dist)
    b.flight_time = b.flight_time_min + V.dist(b.from.x, b.from.y, b.to.x, b.to.y) * b.flight_time_per_dist

    constif(b.reset_to_target_pos)
    b.to.x, b.to.y = target.pos.x, target.pos.y

    constif(not b.ignore_hit_offset)
    if target.unit and target.unit.hit_offset then
        b.to.x, b.to.y = b.to.x + target.unit.hit_offset.x, b.to.y + target.unit.hit_offset.y
        end
        constend
    constend

    @constif(b.predict_target_pos)
    b.to.x, b.to.y = b.to.x + target.motion.speed.x * b.flight_time, b.to.y + target.motion.speed.y * b.flight_time

    constif(b.straight_forward_distance)
        local angle = math.atan2(b.to.y - this.pos.y, b.to.x - this.pos.x)
        b.to.x = this.pos.x + math.cos(angle) * b.straight_forward_distance
        b.to.y = this.pos.y + math.sin(angle) * b.straight_forward_distance

        b.speed.x = math.cos(angle) * b.straight_forward_distance / b.flight_time
        b.speed.y = math.sin(angle) * b.straight_forward_distance / b.flight_time
    constelse
        b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
        b.ts = store.tick_ts
    constend

	constif(b.rotation_speed)
		b.rotation_speed = b.rotation_speed * (b.to.x > this.pos.x and -1 or 1)

		if b.rotation_speed > 0 then
			this.render.sprites[1].flip_x = not this.render.sprites[1].flip_x
		end
	constend

	@constif(b.hide_radius)
	this.render.sprites[1].hidden = true

	return true
end
]]

-- arrow.update = [[
-- return function(this, store)
-- 	constvar b = this.bullet
-- 	local b = this.bullet
-- 	local s = this.render.sprites[1]
-- 	local target = store.entities[b.target_id]

-- 	constif(b.particles_name)
--         local ps = E:create_entity(b.particles_name)
--         ps.particle_system.track_id = this.id
--         queue_insert(store, ps)
-- 	constend

--     constif(b.straight_forward_distance)
--         local last_x = this.pos.x
--         local last_y = this.pos.y
--         local last_ts = store.tick_ts
--         local speed_norm2 = b.speed.x * b.speed.x + b.speed.y * b.speed.y
--         local hitted = {}
--         local mods

--         if b.mod then
--             mods = type(b.mod) == "table" and b.mod or {b.mod}
--         elseif b.mods then
--             mods = b.mods
--         end

--         while true do
--             local dt = store.tick_ts - last_ts
--             local arrived = false
--             if speed_norm2 * dt * dt > V.dist2(last_x, last_y, b.to.x, b.to.y) then
--                 this.pos.x = b.to.x
--                 this.pos.y = b.to.y
--                 arrived = true
--             else
--                 this.pos.x = this.pos.x + b.speed.x * dt
--                 this.pos.y = this.pos.y + b.speed.y * dt
--             end

--             local targets = U.find_enemies_around_line(last_x, last_y, this.pos.x, this.pos.y, b.damage_radius, F_RANGED, b.damage_flags, b.damage_bans)

--             if targets then
--                 for i = 1, #targets do
--                     local target = targets[i]
--                     if not hitted[target.id] then
--                         hitted[target.id] = true
--                         local d = SU.create_bullet_damage(b, target.id, this.id)

--                         queue_damage(store, d)

--                         if mods then
--                             for i = 1, #mods do
--                                 local mod_name = mods[i]
--                                 if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
--                                     local mod = E:create_entity(mod_name)

--                                     mod.modifier.source_id = this.id
--                                     mod.modifier.target_id = target.id
--                                     mod.modifier.level = b.level
--                                     mod.modifier.source_damage = d
--                                     mod.modifier.damage_factor = b.damage_factor

--                                     queue_insert(store, mod)
--                                 end
--                             end
--                         end

--                         constif(b.hit_fx)
--                             local fx = E:create_entity(b.hit_fx)
--                             fx.pos = V.vclone(target.pos)
--                             fx.render.sprites[1].ts = store.tick_ts
--                             queue_insert(store, fx)
--                         constend

--                         constif(b.hit_blood_fx)
--                             if target.unit.blood_color ~= BLOOD_NONE then
--                                 local sfx = E:create_entity(b.hit_blood_fx)
--                                 sfx.pos = V.vclone(target.pos)
--                                 sfx.render.sprites[1].ts = store.tick_ts

--                                 constif(E:get_template(b.hit_blood_fx).use_blood_color)
--                                     if target.unit.blood_color then
--                                         sfx.render.sprites[1].name = target.unit.blood_color
--                                         sfx.render.sprites[1].r = s.r
--                                     end
--                                 constend

--                                 queue_insert(store, sfx)
--                             end
--                         constend
--                     end
--                 end
--             end

--             if arrived then
--                 break
--             end
--             last_x, last_y = this.pos.x, this.pos.y
--             last_ts = store.tick_ts
--             coroutine.yield()
--         end
--     constelse
--         local last_ts = store.tick_ts
--         local v_x = b.speed.x
--         local v_y = b.speed.y
--         local this_pos = this.pos

--         this_pos.x, this_pos.y = b.from.x, b.from.y

--         local expected_stop_time = b.ts + b.flight_time - store.tick_length

--         while store.tick_ts <= expected_stop_time do
--             coroutine.yield()

--             local dt = store.tick_ts - last_ts

--             this_pos.x = this_pos.x + v_x * dt
--             this_pos.y = this_pos.y + v_y * dt

--             constif(b.rotation_speed)
--                 s.r = s.r + b.rotation_speed * store.tick_length
--             constelse
--                 s.r = math.atan2(v_y, v_x)

--                 constif(b.asymmetrical)
--                 if math.abs(s.r) > math.pi * 0.5 then
--                     s.flip_y = true
--                 end
--                 constend
--             constend

--             @constif(b.particles_name)
--             ps.particle_system.emit_direction = s.r

--             constif(b.hide_radius)
--                 local hide_radius_squared = b.hide_radius * b.hide_radius

--                 s.hidden = V.dist2(this_pos.x, this_pos.y, b.from.x, b.from.y) < hide_radius_squared or V.dist2(this_pos.x, this_pos.y, b.to.x, b.to.y) < hide_radius_squared

--                 @constif(b.particles_name)
--                 ps.particle_system.emit = not s.hidden
--             constend

--             v_y = v_y + b.g * dt
--             last_ts = store.tick_ts
--         end

--         local hit = false

--         if target and not target.health.dead then
--             local target_pos = V.vclone(target.pos)

--             constif(not b.ignore_hit_offset)
--                 if target.unit and target.unit.hit_offset then
--                     target_pos.x, target_pos.y = target_pos.x + target.unit.hit_offset.x, target_pos.y + target.unit.hit_offset.y
--                 end
--             constend

--             if V.dist2(this_pos.x, this_pos.y, target_pos.x, target_pos.y) < b.hit_distance * b.hit_distance * 1.44
--                 and not SU.unit_dodges(store, target, true)
--                 @constif(b.hit_chance)
--                 and (math.random() < b.hit_chance)
--             then
--                 hit = true

--                 local d = SU.create_bullet_damage(b, target.id, this.id)

--                 queue_damage(store, d)

--                 local mods

--                 if b.mod then
--                     mods = type(b.mod) == "table" and b.mod or {b.mod}
--                 elseif b.mods then
--                     mods = b.mods
--                 end

--                 if mods then
--                     for i = 1, #mods do
--                         local mod_name = mods[i]
--                         if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
--                             local mod = E:create_entity(mod_name)

--                             mod.modifier.source_id = this.id
--                             mod.modifier.target_id = target.id
--                             mod.modifier.level = b.level
--                             mod.modifier.source_damage = d
--                             mod.modifier.damage_factor = b.damage_factor

--                             queue_insert(store, mod)
--                         end
--                     end
--                 end

--                 constif(b.hit_fx)
--                     local fx = E:create_entity(b.hit_fx)
--                     fx.pos = V.vclone(target_pos)
--                     fx.render.sprites[1].ts = store.tick_ts
--                     queue_insert(store, fx)
--                 constend

--                 constif(b.hit_blood_fx)
--                     if target.unit.blood_color ~= BLOOD_NONE then
--                         local sfx = E:create_entity(b.hit_blood_fx)
--                         sfx.pos = V.vclone(target_pos)
--                         sfx.render.sprites[1].ts = store.tick_ts

--                         constif(E:get_template(b.hit_blood_fx).use_blood_color)
--                             if target.unit.blood_color then
--                                 sfx.render.sprites[1].name = target.unit.blood_color
--                                 sfx.render.sprites[1].r = s.r
--                             end
--                         constend

--                         queue_insert(store, sfx)
--                     end
--                 constend
--             end
--         end

--         if not hit then
--             if GR:cell_is(this_pos.x, this_pos.y, TERRAIN_WATER) then
--                 constif(b.miss_fx_water)
--                     local water_fx = E:create_entity(b.miss_fx_water)
--                     water_fx.pos.x, water_fx.pos.y = this_pos.x, this_pos.y
--                     water_fx.render.sprites[1].ts = store.tick_ts
--                     queue_insert(store, water_fx)
--                 constend
--             else
--                 constif(b.miss_fx)
--                     local fx = E:create_entity(b.miss_fx)
--                     fx.pos.x, fx.pos.y = this_pos.x, this_pos.y
--                     fx.render.sprites[1].ts = store.tick_ts
--                     queue_insert(store, fx)
--                 constend

--                 constif(b.miss_decal)
--                     local decal = E:create_entity("decal_tween")
--                     decal.pos = V.vclone(this_pos)
--                     decal.tween.props[1].keys = {{0, 255}, {2.1, 0}}
--                     decal.render.sprites[1].ts = store.tick_ts
--                     decal.render.sprites[1].name = b.miss_decal
--                     decal.render.sprites[1].animated = false
--                     decal.render.sprites[1].z = Z_DECALS

--                     @constif(b.rotation_speed)
--                     decal.render.sprites[1].flip_x = b.rotation_speed > 0
--                     @constelse
--                     decal.render.sprites[1].r = -math.pi * 0.5 * (1 + (0.5 - math.random()) * 0.35)

--                     @constif(b.miss_decal_anchor)
--                     decal.render.sprites[1].anchor = b.miss_decal_anchor

--                     queue_insert(store, decal)
--                 constend
--             end
--         end
--     constend

-- 	constif(b.payload)
-- 		local p = E:create_entity(b.payload)
-- 		p.pos.x, p.pos.y = this.pos.x, this.pos.y
-- 		p.target_id = b.target_id
-- 		p.source_id = this.id

-- 		constif(E:get_template(b.payload).aura)
-- 			p.aura.level = b.level
-- 			p.aura.damage_factor = b.damage_factor
-- 		constend

-- 		constif(b.payload_props)
-- 			for k, v in pairs(b.payload_props) do
-- 				p[k] = v
-- 			end
-- 		constend

-- 		queue_insert(store, p)
-- 	constend

-- 	constif(b.particles_name)
-- 		if ps.particle_system.emit then
-- 			s.hidden = true
-- 			ps.particle_system.emit = false
-- 			U.y_wait(store, ps.particle_system.particle_lifetime[2])
-- 		end
-- 	constend

-- 	queue_remove(store, this)
-- end
-- ]]

arrow.update = [[
return function(this, store)
    constvar b = this.bullet
    local b = this.bullet
    local s = this.render.sprites[1]
    local target = store.entities[b.target_id]
    local context = this.main_script.context

    if context.state == 0 then
        constif(b.particles_name)
            local ps = E:create_entity(b.particles_name)
            ps.particle_system.track_id = this.id
            queue_insert(store, ps)
            context.ps = ps
        constend

        constif(b.straight_forward_distance)
            context.last_x = this.pos.x
            context.last_y = this.pos.y
            context.last_ts = store.tick_ts
            context.speed_norm2 = b.speed.x * b.speed.x + b.speed.y * b.speed.y
            context.hitted = {}

            if b.mod then
                context.mods = type(b.mod) == "table" and b.mod or {b.mod}
            elseif b.mods then
                context.mods = b.mods
            end
        constelse
            context.last_ts = store.tick_ts
            context.v_x = b.speed.x
            context.v_y = b.speed.y

            this.pos.x, this.pos.y = b.from.x, b.from.y

            context.expected_stop_time = b.ts + b.flight_time - store.tick_length
        constend

        context.state = 1
    end

    if context.state == 1 then
        constif(b.straight_forward_distance)
            local dt = store.tick_ts - context.last_ts
            local arrived = false

            if context.speed_norm2 * dt * dt > V.dist2(context.last_x, context.last_y, b.to.x, b.to.y) then
                this.pos.x = b.to.x
                this.pos.y = b.to.y
                arrived = true
            else
                this.pos.x = this.pos.x + b.speed.x * dt
                this.pos.y = this.pos.y + b.speed.y * dt
            end

            local targets = U.find_enemies_around_line(context.last_x, context.last_y, this.pos.x, this.pos.y, b.damage_radius, F_RANGED, b.damage_flags, b.damage_bans)

            if targets then
                for i = 1, #targets do
                    local target = targets[i]
                    if not context.hitted[target.id] then
                        context.hitted[target.id] = true
                        local d = SU.create_bullet_damage(b, target.id, this.id)

                        queue_damage(store, d)

                        if context.mods then
                            for j = 1, #context.mods do
                                local mod_name = context.mods[j]
                                if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
                                    local mod = E:create_entity(mod_name)

                                    mod.modifier.source_id = this.id
                                    mod.modifier.target_id = target.id
                                    mod.modifier.level = b.level
                                    mod.modifier.source_damage = d
                                    mod.modifier.damage_factor = b.damage_factor

                                    queue_insert(store, mod)
                                end
                            end
                        end

                        constif(b.hit_fx)
                            local fx = E:create_entity(b.hit_fx)
                            fx.pos = V.vclone(target.pos)
                            fx.render.sprites[1].ts = store.tick_ts
                            queue_insert(store, fx)
                        constend

                        constif(b.hit_blood_fx)
                            if target.unit.blood_color ~= BLOOD_NONE then
                                local sfx = E:create_entity(b.hit_blood_fx)
                                sfx.pos = V.vclone(target.pos)
                                sfx.render.sprites[1].ts = store.tick_ts

                                constif(E:get_template(b.hit_blood_fx).use_blood_color)
                                    if target.unit.blood_color then
                                        sfx.render.sprites[1].name = target.unit.blood_color
                                        sfx.render.sprites[1].r = s.r
                                    end
                                constend

                                queue_insert(store, sfx)
                            end
                        constend
                    end
                end
            end

            if arrived then
                context.state = 3
            else
                context.last_x, context.last_y = this.pos.x, this.pos.y
                context.last_ts = store.tick_ts
            end
        constelse
            local dt = store.tick_ts - context.last_ts

            this.pos.x = this.pos.x + context.v_x * dt
            this.pos.y = this.pos.y + context.v_y * dt

            constif(b.rotation_speed)
                s.r = s.r + b.rotation_speed * store.tick_length
            constelse
                s.r = math.atan2(context.v_y, context.v_x)

                constif(b.asymmetrical)
                if math.abs(s.r) > math.pi * 0.5 then
                    s.flip_y = true
                end
                constend
            constend

            @constif(b.particles_name)
            context.ps.particle_system.emit_direction = s.r

            constif(b.hide_radius)
                local hide_radius_squared = b.hide_radius * b.hide_radius

                s.hidden = V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < hide_radius_squared or V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < hide_radius_squared

                @constif(b.particles_name)
                context.ps.particle_system.emit = not s.hidden
            constend

            context.v_y = context.v_y + b.g * dt
            context.last_ts = store.tick_ts

            if store.tick_ts > context.expected_stop_time then
                context.state = 2
            end
        constend
    end

    constif(not b.straight_forward_distance)
    if context.state == 2 then
        local hit = false

        if target and not target.health.dead then
            local target_pos = V.vclone(target.pos)

            constif(not b.ignore_hit_offset)
                if target.unit and target.unit.hit_offset then
                    target_pos.x, target_pos.y = target_pos.x + target.unit.hit_offset.x, target_pos.y + target.unit.hit_offset.y
                end
            constend

            if V.dist2(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < b.hit_distance * b.hit_distance * 1.44
                and not SU.unit_dodges(store, target, true)
                @constif(b.hit_chance)
                and (math.random() < b.hit_chance)
            then
                hit = true

                local d = SU.create_bullet_damage(b, target.id, this.id)

                queue_damage(store, d)

                local mods

                if b.mod then
                    mods = type(b.mod) == "table" and b.mod or {b.mod}
                elseif b.mods then
                    mods = b.mods
                end

                if mods then
                    for i = 1, #mods do
                        local mod_name = mods[i]
                        if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
                            local mod = E:create_entity(mod_name)

                            mod.modifier.source_id = this.id
                            mod.modifier.target_id = target.id
                            mod.modifier.level = b.level
                            mod.modifier.source_damage = d
                            mod.modifier.damage_factor = b.damage_factor

                            queue_insert(store, mod)
                        end
                    end
                end

                constif(b.hit_fx)
                    local fx = E:create_entity(b.hit_fx)
                    fx.pos = V.vclone(target_pos)
                    fx.render.sprites[1].ts = store.tick_ts
                    queue_insert(store, fx)
                constend

                constif(b.hit_blood_fx)
                    if target.unit.blood_color ~= BLOOD_NONE then
                        local sfx = E:create_entity(b.hit_blood_fx)
                        sfx.pos = V.vclone(target_pos)
                        sfx.render.sprites[1].ts = store.tick_ts

                        constif(E:get_template(b.hit_blood_fx).use_blood_color)
                            if target.unit.blood_color then
                                sfx.render.sprites[1].name = target.unit.blood_color
                                sfx.render.sprites[1].r = s.r
                            end
                        constend

                        queue_insert(store, sfx)
                    end
                constend
            end
        end

        if not hit then
            if GR:cell_is(this.pos.x, this.pos.y, TERRAIN_WATER) then
                constif(b.miss_fx_water)
                    local water_fx = E:create_entity(b.miss_fx_water)
                    water_fx.pos.x, water_fx.pos.y = this.pos.x, this.pos.y
                    water_fx.render.sprites[1].ts = store.tick_ts
                    queue_insert(store, water_fx)
                constend
            else
                constif(b.miss_fx)
                    local fx = E:create_entity(b.miss_fx)
                    fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
                    fx.render.sprites[1].ts = store.tick_ts
                    queue_insert(store, fx)
                constend

                constif(b.miss_decal)
                    local decal = E:create_entity("decal_tween")
                    decal.pos = V.vclone(this.pos)
                    decal.tween.props[1].keys = {{0, 255}, {2.1, 0}}
                    decal.render.sprites[1].ts = store.tick_ts
                    decal.render.sprites[1].name = b.miss_decal
                    decal.render.sprites[1].animated = false
                    decal.render.sprites[1].z = Z_DECALS

                    @constif(b.rotation_speed)
                    decal.render.sprites[1].flip_x = b.rotation_speed > 0
                    @constelse
                    decal.render.sprites[1].r = -math.pi * 0.5 * (1 + (0.5 - math.random()) * 0.35)

                    @constif(b.miss_decal_anchor)
                    decal.render.sprites[1].anchor = b.miss_decal_anchor

                    queue_insert(store, decal)
                constend
            end
        end

        context.state = 3
    end
    constend

    if context.state == 3 then
        constif(b.payload)
            local p = E:create_entity(b.payload)
            p.pos.x, p.pos.y = this.pos.x, this.pos.y
            p.target_id = b.target_id
            p.source_id = this.id

            constif(E:get_template(b.payload).aura)
                p.aura.level = b.level
                p.aura.damage_factor = b.damage_factor
            constend

            constif(b.payload_props)
                for k, v in pairs(b.payload_props) do
                    p[k] = v
                end
            constend

            queue_insert(store, p)
        constend

        constif(b.particles_name)
            if context.ps.particle_system.emit then
                s.hidden = true
                context.ps.particle_system.emit = false
                context.wait_until_ts = store.tick_ts + context.ps.particle_system.particle_lifetime[2]
                context.state = 4
            else
                queue_remove(store, this)
                return
            end
        constelse
            queue_remove(store, this)
            return
        constend
    end

    constif(b.particles_name)
    if context.state == 4 then
        if store.tick_ts >= context.wait_until_ts then
            queue_remove(store, this)
            return
        end
    end
    constend
end
]]

return arrow
