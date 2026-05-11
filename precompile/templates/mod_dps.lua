local mod_dps = {}
mod_dps.insert = [[
return function(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		return false
	end

	if band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0 then
		return false
	end

    constif(this.render)
	if target.unit then
		local s = this.render.sprites[1]

		s.ts = store.tick_ts

        constif(this.render.sprites[1].size_names)
			s.name = s.size_names[target.unit.size]
        constend

		constif(this.render.sprites[1].size_scales)
			s.scale = s.size_scales[target.unit.size]
		constend

		if target.render then
			s.z = target.render.sprites[1].z
		end
	end
    constend

	this.dps.ts = store.tick_ts - this.dps.damage_every
	this.modifier.ts = store.tick_ts

	signal.emit("mod-applied", this, target)

	return true
end
]]

mod_dps.update = [[
return function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		queue_remove(store, this)

		return
	end

    constvar dps = this.dps

    @constif(dps.damage_first)
    local cycles = 0

	local dps = this.dps

    constif(dps.damage_inc ~= 0)
	local dmin = dps.damage_min + m.level * dps.damage_inc
	local dmax = dps.damage_max + m.level * dps.damage_inc
    constelse
    local dmin, dmax = dps.damage_min, dps.damage_max
    constend

	local fx_ts = 0

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead then
			break
		end

		if store.tick_ts - m.ts >= m.duration - 1e-09 then
            constif(dps.damage_last)
                local d = E:create_entity("damage")

                d.source_id = this.id
                d.target_id = target.id
                d.value = dps.damage_last * m.damage_factor
                d.damage_type = dps.damage_type
                d.pop = dps.pop
                d.pop_chance = dps.pop_chance
                d.pop_conds = dps.pop_conds

                queue_damage(store, d)
            constend
			break
		end

        constif(this.render and this.modifier.use_mod_offset)
		if target.unit.mod_offset then
			local so = this.render.sprites[1].offset

			so.x, so.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end
        constend

        constif(dps.damage_every)
		if store.tick_ts - dps.ts >= dps.damage_every then
			dps.ts = dps.ts + dps.damage_every

			local damage_value = math.random(dmin, dmax)

            constif(dps.damage_first)
			    cycles = cycles + 1
                if cycles == 1 then
                    damage_value = dps.damage_first
                end
            constend

            damage_value = damage_value * m.damage_factor

            @constif(not dps.kill)
			damage_value = km.clamp(0, target.health.hp - 1, damage_value)

			local d = E:create_entity("damage")

            d.source_id = this.id
            d.target_id = target.id
            d.value = damage_value
            d.damage_type = dps.damage_type
            d.pop = dps.pop
            d.pop_chance = dps.pop_chance
            d.pop_conds = dps.pop_conds

            queue_damage(store, d)

            constif(dps.fx)
                @constif(dps.fx_every)
                if store.tick_ts - fx_ts >= dps.fx_every then
                    fx_ts = store.tick_ts

                    local fx = E:create_entity(dps.fx)

                    constif(dps.fx_tracks_target)
                        fx.pos = target.pos

                        constif(this.modifier.use_mod_offset)
                        if target.unit.mod_offset then
                            fx.render.sprites[1].offset.x = target.unit.mod_offset.x
                            fx.render.sprites[1].offset.y = target.unit.mod_offset.y
                        end
                        constend
                    constelse
                        fx.pos = V.vclone(this.pos)

                        constif(this.modifier.use_mod_offset)
                        if target.unit.mod_offset then
                            fx.pos.x, fx.pos.y = fx.pos.x + target.unit.mod_offset.x, fx.pos.y + target.unit.mod_offset.y
                        end
                        constend
                    constend

                    fx.render.sprites[1].ts = store.tick_ts
                    fx.render.sprites[1].runs = 0

                    @constif(E:get_template(dps.fx).render.sprites[1].size_names)
                    fx.render.sprites[1].name = fx.render.sprites[1].size_names[target.unit.size]

                    constif(dps.fx_target_flip)
                    if target.render then
                        fx.render.sprites[1].flip_x = target.render.sprites[1].flip_x
                    end
                    constend

                    queue_insert(store, fx)
                @constif(dps.fx_every)
                end
            constend
		end
        constend

		coroutine.yield()
	end

	queue_remove(store, this)
end
]]

return mod_dps
