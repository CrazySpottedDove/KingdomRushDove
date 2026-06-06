local aura_apply_mod = {}

aura_apply_mod.insert = [[
return function(this, store)
	this.aura.ts = store.tick_ts

	constif(this.render)
		constfor i = 1, #this.render.sprites do
			this.render.sprites[i].ts = store.tick_ts
		constend
		constif(this.aura.use_mod_offset)
			local target = store.entities[this.aura.target_id]
			if target and target.unit and target.unit.mod_offset then
			 	this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
			end
		constend
	constend

	constif(this.aura.duration_inc)
		this.actual_duration = this.aura.duration + this.aura.level * this.aura.duration_inc
	constelse
		conststmt(this.actual_duration = this.aura.duration)
	constend

	return true
end
]]

-- aura_apply_mod.update = [[
-- return function(this, store)
-- 	constvar a = this.aura

-- 	@constif(a.apply_duration)
-- 	local first_hit_ts = store.tick_ts

-- 	@constif(a.cycles)
-- 	local cycles_count = 0

-- 	@constif(a.max_count)
-- 	local victims_count = 0

--     constif(this.ps_names)
--         constfor i = 1, #this.ps_names do
--             local ps = E:create_entity(this.ps_names[i])

--             @constif(this.ps_spread_follow_radius)
--             ps.particle_system.emit_area_spread = V.vv(this.aura.radius)

--             ps.particle_system.track_id = this.id
--             queue_insert(store, ps)
--         constend
--     constend

-- 	constif(a.track_source)
--         local source = store.entities[this.aura.source_id]

--         if source and source.pos then
--             this.pos = source.pos
--         end
-- 	constend

-- 	@constif(a.apply_delay)
-- 	local last_hit_ts = store.tick_ts - this.aura.apply_delay - this.aura.cycle_time
-- 	@constelse
-- 	local last_hit_ts = store.tick_ts - this.aura.cycle_time

-- 	local mods = this.aura.mods or {this.aura.mod}
-- 	local mod_count = #mods

-- 	while true do
-- 		if this.interrupt then
-- 			last_hit_ts = 1e+99
-- 		end

-- 		constif(a.cycles)
-- 		if cycles_count >= this.aura.cycles then
-- 			break
-- 		end
-- 		constend

-- 		constif(a.duration >= 0)
-- 		if store.tick_ts - this.aura.ts > this.actual_duration then
-- 			break
-- 		end
-- 		constend

-- 		constif((a.track_source and not a.track_dead) or a.source_vis_flags or a.requires_alive_source)
-- 			local source = store.entities[this.aura.source_id]

-- 			constif(a.track_source and not a.track_dead)
-- 			if not source or (source.health and source.health.dead) then
-- 				break
-- 			end
-- 			constend

-- 			constif(this.render)
-- 			if source and source.enemy and not source.enemy.can_do_magic then
-- 				this.render.sprites[1].hidden = not source.enemy.can_do_magic
-- 				goto label_89_0
-- 			end
-- 			constend

-- 			constif(a.source_vis_flags)
-- 			if source and source.vis and band(source.vis.bans, this.aura.source_vis_flags) ~= 0 then
-- 				goto label_89_0
-- 			end
-- 			constend

-- 			constif(a.requires_alive_source)
-- 			if source and source.health and source.health.dead then
-- 				goto label_89_0
-- 			end
-- 			constend
-- 		constend

-- 		@constif(a.apply_duration)
-- 		if store.tick_ts - last_hit_ts >= this.aura.cycle_time and store.tick_ts - first_hit_ts <= this.aura.apply_duration then
-- 		@constelse
-- 		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
-- 			@constif(this.render and a.cast_resets_sprite_id)
-- 			this.render.sprites[this.aura.cast_resets_sprite_id].ts = store.tick_ts

-- 			last_hit_ts = store.tick_ts

-- 			@constif(a.cycles)
-- 			cycles_count = cycles_count + 1

-- 			constif(band(a.vis_bans, F_ENEMY) ~= 0)
-- 			local targets = table.filter(store.soldiers, function(k, v)
-- 				return not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)

-- 				@constif(this.aura.allowed_templates)
-- 				and table.arraycontains(this.aura.allowed_templates, v.template_name)

-- 				@constif(this.aura.excluded_templates)
-- 				and not table.arraycontains(this.aura.excluded_templates, v.template_name)

-- 				@constif(this.aura.filter_source)
-- 				and this.aura.source_id ~= v.id
-- 			end)
-- 			constelseif(band(a.vis_bans, F_FRIEND) ~= 0)
-- 				constif(a.allowed_templates or a.excluded_templates or a.filter_source)
-- 				local targets = U.find_enemies_in_range_filter_on(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans, function(e)
-- 					return true

-- 					@constif(this.aura.allowed_templates)
-- 					and table.arraycontains(this.aura.allowed_templates, e.template_name)

-- 					@constif(this.aura.excluded_templates)
-- 					and not table.arraycontains(this.aura.excluded_templates, e.template_name)

-- 					@constif(this.aura.filter_source)
-- 					and this.aura.source_id ~= e.id
-- 				end)
-- 				constelse
-- 				local targets = U.find_enemies_in_range_filter_off(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)
-- 				constend
-- 			constelse
-- 			local targets = table.filter(store.entities, function(k, v)
-- 				return v.unit and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)

-- 				@constif(this.aura.allowed_templates)
-- 				and table.arraycontains(this.aura.allowed_templates, v.template_name)

-- 				@constif(this.aura.excluded_templates)
-- 				and not table.arraycontains(this.aura.excluded_templates, v.template_name)

-- 				@constif(this.aura.filter_source)
-- 				and this.aura.source_id ~= v.id
-- 			end)
-- 			constend

--             constif(band(a.vis_bans, F_FRIEND) ~= 0)
--             if not targets then
--                 goto label_89_0
--             end
--             constend

-- 			for i = 1, #targets do
-- 				constif(a.targets_per_cycle)
-- 				if i > this.aura.targets_per_cycle then
-- 					break
-- 				end
-- 				constend

-- 				constif(a.max_count)
-- 				if victims_count >= this.aura.max_count then
-- 					break
-- 				end
-- 				victims_count = victims_count + 1
-- 				constend

-- 				local target = targets[i]
-- 				for j = 1, mod_count do
-- 					local new_mod = E:create_entity(mods[j])

-- 					new_mod.modifier.level = this.aura.level
-- 					new_mod.modifier.target_id = target.id
-- 					new_mod.modifier.source_id = this.id
-- 					new_mod.modifier.damage_factor = this.aura.damage_factor

-- 					constif(a.hide_source_fx)
-- 					if target.id == this.aura.source_id then
-- 						new_mod.render = nil
-- 					end
-- 					constend

-- 					queue_insert(store, new_mod)
-- 				end
-- 			end
-- 		end

-- 		::label_89_0::

-- 		coroutine.yield()
-- 	end

-- 	@constif(a.max_count)
-- 	signal.emit("aura-apply-mod-victims", this, victims_count)

-- 	queue_remove(store, this)
-- end
-- ]]

aura_apply_mod.update = [[
return function(this, store)
    constvar a = this.aura

    local context = this.main_script.context
    if context.state == 0 then
        context.state = 1
        @constif(a.apply_duration)
        context.first_hit_ts = store.tick_ts

        @constif(a.cycles)
        context.cycles_count = 0

        @constif(a.max_count)
        context.victims_count = 0

        constif(this.ps_names)
            context.ps_instances = {}
            constfor i = 1, #this.ps_names do
                local ps = E:create_entity(this.ps_names[i])

                @constif(this.ps_spread_follow_radius)
                ps.particle_system.emit_area_spread = V.vv(this.aura.radius)

                ps.particle_system.track_id = this.id
                queue_insert(store, ps)
                context.ps_instances[i] = ps
            constend
        constend

        constif(a.track_source)
            local source = store.entities[this.aura.source_id]
            if source and source.pos then
                this.pos = source.pos
            end
        constend

        @constif(a.apply_delay)
        context.last_hit_ts = store.tick_ts - this.aura.apply_delay - this.aura.cycle_time
        @constelse
        context.last_hit_ts = store.tick_ts - this.aura.cycle_time

        context.mods = this.aura.mods or {this.aura.mod}
    end

    if this.interrupt then
        context.last_hit_ts = 1e+99
    end

    constif(a.cycles)
    if context.cycles_count >= this.aura.cycles then
        queue_remove(store, this)
        return
    end
    constend

    constif(a.duration >= 0)
    if store.tick_ts - this.aura.ts > this.actual_duration then
        queue_remove(store, this)
        return
    end
    constend

    constif((a.track_source and not a.track_dead) or a.source_vis_flags or a.requires_alive_source)
        local source = store.entities[this.aura.source_id]

        constif(a.track_source and not a.track_dead)
        if not source or (source.health and source.health.dead) then
            queue_remove(store, this)
            return
        end
        constend

        constif(this.render)
        if source and source.enemy and not source.enemy.can_do_magic then
            this.render.sprites[1].hidden = not source.enemy.can_do_magic
            return
        end
        constend

        constif(a.source_vis_flags)
        if source and source.vis and band(source.vis.bans, this.aura.source_vis_flags) ~= 0 then
            return
        end
        constend

        constif(a.requires_alive_source)
        if source and source.health and source.health.dead then
            return
        end
        constend
    constend

    @constif(a.apply_duration)
    if store.tick_ts - context.last_hit_ts >= this.aura.cycle_time and store.tick_ts - context.first_hit_ts <= this.aura.apply_duration then
    @constelse
    if store.tick_ts - context.last_hit_ts >= this.aura.cycle_time then
        @constif(this.render and a.cast_resets_sprite_id)
        this.render.sprites[this.aura.cast_resets_sprite_id].ts = store.tick_ts

        context.last_hit_ts = store.tick_ts

        @constif(a.cycles)
        context.cycles_count = context.cycles_count + 1

        constif(band(a.vis_bans, F_ENEMY) ~= 0)
        local targets = table.filter(store.soldiers, function(k, v)
            return not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)

            @constif(this.aura.allowed_templates)
            and table.arraycontains(this.aura.allowed_templates, v.template_name)

            @constif(this.aura.excluded_templates)
            and not table.arraycontains(this.aura.excluded_templates, v.template_name)

            @constif(this.aura.filter_source)
            and this.aura.source_id ~= v.id
        end)
        constelseif(band(a.vis_bans, F_FRIEND) ~= 0)
            constif(a.allowed_templates or a.excluded_templates or a.filter_source)
            local targets = U.find_enemies_in_range_filter_on(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans, function(e)
                return true

                @constif(this.aura.allowed_templates)
                and table.arraycontains(this.aura.allowed_templates, e.template_name)

                @constif(this.aura.excluded_templates)
                and not table.arraycontains(this.aura.excluded_templates, e.template_name)

                @constif(this.aura.filter_source)
                and this.aura.source_id ~= e.id
            end)
            constelse
            local targets = U.find_enemies_in_range_filter_off(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)
            constend
        constelse
        local targets = table.filter(store.entities, function(k, v)
            return v.unit and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)

            @constif(this.aura.allowed_templates)
            and table.arraycontains(this.aura.allowed_templates, v.template_name)

            @constif(this.aura.excluded_templates)
            and not table.arraycontains(this.aura.excluded_templates, v.template_name)

            @constif(this.aura.filter_source)
            and this.aura.source_id ~= v.id
        end)
        constend

        constif(band(a.vis_bans, F_FRIEND) ~= 0)
        if not targets then
            return
        end
        constend

        for i = 1, #targets do
            constif(a.targets_per_cycle)
            if i > this.aura.targets_per_cycle then
                break
            end
            constend

            constif(a.max_count)
            if context.victims_count >= this.aura.max_count then
                break
            end
            context.victims_count = context.victims_count + 1
            constend

            local target = targets[i]
            local mods = context.mods
            for j = 1, #mods do
                local new_mod = E:create_entity(mods[j])

                new_mod.modifier.level = this.aura.level
                new_mod.modifier.target_id = target.id
                new_mod.modifier.source_id = this.id
                new_mod.modifier.damage_factor = this.aura.damage_factor

                constif(a.hide_source_fx)
                if target.id == this.aura.source_id then
                    new_mod.render = nil
                end
                constend

                queue_insert(store, new_mod)
            end
        end
    end
end
]]

return aura_apply_mod
