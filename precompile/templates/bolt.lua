local bolt = {}

bolt.insert = [[
return function(this, store)
	constvar b = this.bullet
	local b = this.bullet

	if(b.target_id) then
		local target = store.entities[b.target_id]

		if not target or target.vis and band(target.vis.bans, F_RANGED) ~= 0 then
			return false
		end
	end

	b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

	local s = this.render.sprites[1]

	@constif(not b.ignore_rotation)
	s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

	U.animation_start(this, "flying", nil, store.tick_ts, s.loop)

	return true
end
]]

-- bolt.update = [[
-- return function(this, store)
-- 	constvar b = this.bullet
-- 	local b = this.bullet
-- 	local s = this.render.sprites[1]
-- 	local mspeed = b.min_speed
-- 	local target
-- 	local new_target = false
-- 	local target_invalid = false

-- 	constif(b.particles_name)
-- 		local ps = E:create_entity(b.particles_name)
-- 		ps.particle_system.track_id = this.id
-- 		queue_insert(store, ps)
-- 	constend

-- 	::label_75_0::

-- 	if b.store and not b.target_id then
-- 		@constif(this.sound_events.summon)
-- 		S:queue(this.sound_events.summon)

-- 		s.z = Z_OBJECTS
-- 		s.sort_y_offset = b.store_sort_y_offset
-- 		U.animation_start(this, "idle", nil, store.tick_ts, true)

-- 		@constif(b.particles_name)
-- 		ps.particle_system.emit = false
-- 	else
-- 		@constif(this.sound_events.travel)
-- 		S:queue(this.sound_events.travel)

-- 		s.z = Z_BULLETS
-- 		s.sort_y_offset = nil

-- 		U.animation_start(this, "flying", nil, store.tick_ts, s.loop)

-- 		@constif(b.particles_name)
-- 		ps.particle_system.emit = true
-- 	end

-- 	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
-- 		coroutine.yield()

-- 		if not target_invalid then
-- 			target = store.entities[b.target_id]
-- 		end

-- 		if target and not new_target then
-- 			local tpx, tpy = target.pos.x, target.pos.y

-- 			@constif(not b.ignore_hit_offset)
-- 			tpx, tpy = tpx + target.unit.hit_offset.x, tpy + target.unit.hit_offset.y

-- 			if math.max(math.abs(tpx - b.to.x), math.abs(tpy - b.to.y)) > b.max_track_distance or band(target.vis.bans, F_RANGED) ~= 0 then
-- 				target_invalid = true
-- 				target = nil
-- 			end
-- 		end

-- 		if target and not target.health.dead then
-- 			@constif(b.ignore_hit_offset)
-- 			b.to.x, b.to.y = target.pos.x, target.pos.y
-- 			@constelse
-- 			b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y

-- 			new_target = false
-- 		end

-- 		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
-- 		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
-- 		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
-- 		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length

-- 		@constif(not b.ignore_rotation)
-- 		s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

-- 		@constif(b.particles_name)
-- 		ps.particle_system.emit_direction = s.r
-- 	end

-- 	while b.store and not b.target_id do
-- 		coroutine.yield()

-- 		if b.target_id then
-- 			mspeed = b.min_speed
-- 			new_target = true
-- 			goto label_75_0
-- 		end
-- 	end

-- 	this.pos.x, this.pos.y = b.to.x, b.to.y

-- 	if target and not target.health.dead then
-- 		local d = SU.create_bullet_damage(b, target.id, this.id)

-- 		queue_damage(store, d)

-- 		local mods = b.mods or (b.mod and {b.mod})
-- 		if mods then
-- 			for k = 1, #mods do
-- 				local m = E:create_entity(mods[k])

-- 				m.modifier.target_id = b.target_id
-- 				m.modifier.level = b.level

-- 				queue_insert(store, m)
-- 			end
-- 		end

-- 		if b.hit_payload then
-- 			local hp = b.hit_payload

-- 			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
-- 			queue_insert(store, hp)
-- 		end
-- 	end

-- 	if b.payload then
-- 		local hp = b.payload

-- 		hp.pos.x, hp.pos.y = b.to.x, b.to.y
-- 		queue_insert(store, hp)
-- 	end

-- 	constif(b.hit_fx)
-- 		local sfx = E:create_entity(b.hit_fx)

-- 		sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
-- 		sfx.render.sprites[1].ts = store.tick_ts
-- 		sfx.render.sprites[1].runs = 0

-- 		constif(E:get_template(b.hit_fx).render and E:get_template(b.hit_fx).render.sprites[1].size_names)
--             if target then
--                 sfx.render.sprites[1].name = sfx.render.sprites[1].size_names[target.unit.size]
--             end
-- 		constend

-- 		queue_insert(store, sfx)
-- 	constend

-- 	queue_remove(store, this)
-- end
-- ]]

-- state0: 初始化
-- state1: 开始飞行
-- state2: 等待目标
-- state3: 飞行、造成伤害
bolt.update = [[
return function(this, store)
    constvar b = this.bullet
    local b = this.bullet
    local s = this.render.sprites[1]
    local context = this.main_script.context

    if context.state == 0 then
        context.mspeed = b.min_speed
        context.new_target = false
        context.target_invalid = false

        constif(b.particles_name)
            local ps = E:create_entity(b.particles_name)
            ps.particle_system.track_id = this.id
            queue_insert(store, ps)
            context.ps = ps
        constend

        if b.store and not b.target_id then
            @constif(this.sound_events.summon)
            S:queue(this.sound_events.summon)

            s.z = Z_OBJECTS
            s.sort_y_offset = b.store_sort_y_offset
            U.animation_start(this, "idle", nil, store.tick_ts, true)

            @constif(b.particles_name)
            context.ps.particle_system.emit = false

            context.state = 2
        else
            context.state = 1
        end
    end

    if context.state == 1 then
        @constif(this.sound_events.travel)
        S:queue(this.sound_events.travel)

        s.z = Z_BULLETS
        s.sort_y_offset = nil
        U.animation_start(this, "flying", nil, store.tick_ts, s.loop)

        @constif(b.particles_name)
        context.ps.particle_system.emit = true

        context.state = 3
    end

    if context.state == 2 then
        if b.target_id then
            context.mspeed = b.min_speed
            context.new_target = true
            context.target_invalid = false
            context.state = 1
        else
            return
        end
    end

    local arrived = V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) <= context.mspeed * store.tick_length

    if arrived then
        this.pos.x, this.pos.y = b.to.x, b.to.y

        local target = store.entities[b.target_id]

        if target and not target.health.dead then
            local d = SU.create_bullet_damage(b, target.id, this.id)

            queue_damage(store, d)

            local mods = b.mods or (b.mod and {b.mod})
            if mods then
                for k = 1, #mods do
                    local m = E:create_entity(mods[k])

                    m.modifier.target_id = b.target_id
                    m.modifier.level = b.level

                    queue_insert(store, m)
                end
            end

            if b.hit_payload then
                local hp = b.hit_payload

                hp.pos.x, hp.pos.y = this.pos.x, this.pos.y
                queue_insert(store, hp)
            end
        end

        if b.payload then
            local hp = b.payload

            hp.pos.x, hp.pos.y = b.to.x, b.to.y
            queue_insert(store, hp)
        end

        constif(b.hit_fx)
            local sfx = E:create_entity(b.hit_fx)

            sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
            sfx.render.sprites[1].ts = store.tick_ts
            sfx.render.sprites[1].runs = 0

            constif(E:get_template(b.hit_fx).render and E:get_template(b.hit_fx).render.sprites[1].size_names)
                if target then
                    sfx.render.sprites[1].name = sfx.render.sprites[1].size_names[target.unit.size]
                end
            constend

            queue_insert(store, sfx)
        constend

        queue_remove(store, this)
    end

    local target

    if not context.target_invalid then
        target = store.entities[b.target_id]
    end

    if target and not context.new_target then
        local tpx, tpy = target.pos.x, target.pos.y

        @constif(not b.ignore_hit_offset)
        tpx, tpy = tpx + target.unit.hit_offset.x, tpy + target.unit.hit_offset.y

        if math.max(math.abs(tpx - b.to.x), math.abs(tpy - b.to.y)) > b.max_track_distance or band(target.vis.bans, F_RANGED) ~= 0 then
            context.target_invalid = true
            target = nil
        end
    end

    if target and not target.health.dead then
        @constif(b.ignore_hit_offset)
        b.to.x, b.to.y = target.pos.x, target.pos.y
        @constelse
        b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y

        context.new_target = false
    end

    context.mspeed = context.mspeed + FPS * math.ceil(context.mspeed * (1 / FPS) * b.acceleration_factor)
    context.mspeed = km.clamp(b.min_speed, b.max_speed, context.mspeed)
    b.speed.x, b.speed.y = V.mul(context.mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
    this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length

    @constif(not b.ignore_rotation)
    s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

    @constif(b.particles_name)
    context.ps.particle_system.emit_direction = s.r
end
]]

return bolt
