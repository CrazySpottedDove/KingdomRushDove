local aura_apply_damage = {}

aura_apply_damage.update = [[
return function(this, store)
    constvar a = this.aura
	this.aura.ts = store.tick_ts

    @constif(not a.cycles and a.duration >= 0)
    this.aura.duration = this.aura.duration + this.aura.level * this.aura.duration_inc

	local last_hit_ts = 0

    @constif(a.cycles)
	local cycles_count = 0

	while true do
		constif(a.cycles)
            if cycles_count >= this.aura.cycles then
                break
            end
        constelseif(a.duration >= 0)
            if store.tick_ts - this.aura.ts >= this.aura.duration then
                break
            end
        constend

		constif(a.track_source)
		local te = store.entities[this.aura.source_id]

		if not te or te.health and te.health.dead or (te.enemy and (not te.enemy.can_do_magic)) then
			queue_remove(store, this)
			return
		end

		if te.pos then
			this.pos.x, this.pos.y = te.pos.x, te.pos.y
		end
		constend

		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
            @constif(a.cycles)
			cycles_count = cycles_count + 1

			last_hit_ts = store.tick_ts

            constif(band(a.vis_bans, F_ENEMY) ~= 0)
			local targets = table.filter(store.soldiers, function(k, v)
				return not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)

				@constif(this.aura.allowed_templates)
				and table.contains(this.aura.allowed_templates, v.template_name)

				@constif(this.aura.excluded_templates)
				and not table.contains(this.aura.excluded_templates, v.template_name)

				@constif(this.aura.filter_source)
				and this.aura.source_id ~= v.id
			end)
			constelseif(band(a.vis_bans, F_FRIEND) ~= 0)
				constif(a.allowed_templates or a.excluded_templates or a.filter_source)
				local targets = U.find_enemies_in_range_filter_on(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans, function(e)
					return true

					@constif(this.aura.allowed_templates)
					and table.contains(this.aura.allowed_templates, e.template_name)

					@constif(this.aura.excluded_templates)
					and not table.contains(this.aura.excluded_templates, e.template_name)

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
				and table.contains(this.aura.allowed_templates, v.template_name)

				@constif(this.aura.excluded_templates)
				and not table.contains(this.aura.excluded_templates, v.template_name)

				@constif(this.aura.filter_source)
				and this.aura.source_id ~= v.id
			end)
			constend

            constif(band(a.vis_bans, F_FRIEND) ~= 0)
            if not targets then
                goto label_89_0
            end
            constend

            @constif(band(a.vis_bans, F_FRIEND) == 0)
			if #targets > 0 then
				local dmin, dmax = this.aura.damage_min, this.aura.damage_max

				constif(this.aura.damage_inc)
				dmin = dmin + this.aura.damage_inc * this.aura.level
				dmax = dmax + this.aura.damage_inc * this.aura.level
				constend

				local mods = this.aura.mods or {this.aura.mod}
				local mod_count = #mods

				for i = 1, #targets do
					local target = targets[i]

					local d = E.create_damage()

					d.source_id = this.id
					d.target_id = target.id

					d.value = math.random(dmin, dmax) * this.aura.damage_factor
					d.damage_type = this.aura.damage_type
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

                        constif(a.hide_source_fx)
						if target.id == this.aura.source_id then
							m.render = nil
						end
                        constend

						queue_insert(store, m)
					end
				end
            @constif(band(a.vis_bans, F_FRIEND) == 0)
			end
		end

        ::label_89_0::

		coroutine.yield()
	end

	queue_remove(store, this)
end
]]

return aura_apply_damage
