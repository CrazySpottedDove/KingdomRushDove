local aura_apply_damage = {}

aura_apply_damage.update = [[
return function(this, store)
	this.aura.ts = store.tick_ts

	local last_hit_ts = 0
	local cycles_count = 0

	while true do
		constif(this.aura.cycles)
		if cycles_count >= this.aura.cycles then
			break
		end
		constelse
		conststmt(if this.aura.duration >= 0 and store.tick_ts - this.aura.ts >= this.aura.duration + this.aura.level * this.aura.duration_inc then break end)
		constend

		constif(this.aura.track_source and this.aura.source_id)
		local te = store.entities[this.aura.source_id]

		if not te or te.health and te.health.dead or (te.enemy and (not te.enemy.can_do_magic)) then
			queue_remove(store, this)
			return
		end

		if te and te.pos then
			this.pos.x, this.pos.y = te.pos.x, te.pos.y
		end
		constend

		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
			cycles_count = cycles_count + 1
			last_hit_ts = store.tick_ts

			local targets

			constif(band(this.aura.vis_bans, F_ENEMY) ~= 0)
			targets = table.filter(store.soldiers, function(k, v)
				return v.unit and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)

				@constif(this.aura.allowed_templates)
				and table.contains(this.aura.allowed_templates, v.template_name)

				@constif(this.aura.excluded_templates)
				and not table.contains(this.aura.excluded_templates, v.template_name)
			end)
			constelseif(band(this.aura.vis_bans, F_FRIEND) ~= 0)
			targets = U.find_enemies_in_range_filter_off(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans, function(e)
				return true

				@constif(this.aura.allowed_templates)
				and table.contains(this.aura.allowed_templates, e.template_name)

				@constif(this.aura.excluded_templates)
				and not table.contains(this.aura.excluded_templates, e.template_name)

				@constif(this.aura.filter_source)
				and this.aura.source_id ~= e.id
			end) or {}
			constelse
			targets = table.filter(store.entities, function(k, v)
				return v.unit and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)

				@constif(this.aura.allowed_templates)
				and table.contains(this.aura.allowed_templates, v.template_name)

				@constif(this.aura.excluded_templates)
				and not table.contains(this.aura.excluded_templates, v.template_name)
			end)
			constend

			if #targets > 0 then
				local dmin, dmax = this.aura.damage_min, this.aura.damage_max

				constif(this.aura.damage_inc)
				dmin = dmin + this.aura.damage_inc * this.aura.level
				dmax = dmax + this.aura.damage_inc * this.aura.level
				constend

				constvar mods_arr = this.aura.mods or {this.aura.mod}
				local mod_count = #mods_arr

				for i = 1, #targets do
					local target = targets[i]

					local d = E:create_entity("damage")

					d.source_id = this.id
					d.target_id = target.id
					d.value = math.random(dmin, dmax) * this.aura.damage_factor
					d.damage_type = this.aura.damage_type

					constif(this.aura.track_damage)
					d.track_damage = this.aura.track_damage
					constend

					constif(this.aura.xp_dest_id)
					d.xp_dest_id = this.aura.xp_dest_id
					constend

					constif(this.aura.xp_gain_factor)
					d.xp_gain_factor = this.aura.xp_gain_factor
					constend

					queue_damage(store, d)

					for j = 1, mod_count do
						local m = E:create_entity(mods_arr[j])

						m.modifier.level = this.aura.level
						m.modifier.target_id = target.id
						m.modifier.source_id = this.id
						m.modifier.damage_factor = this.aura.damage_factor

						constif(this.aura.hide_source_fx)
						if target.id == this.aura.source_id then
							m.render = nil
						end
						constend

						queue_insert(store, m)
					end
				end
			end
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end
]]

return aura_apply_damage
