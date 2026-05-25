local mod_track_target = {}

mod_track_target.insert = [[
return function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if not target or target.health.dead then
		return false
	end

	if band(m.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0 then
		return false
	end

	constif(this.render)
		if target.unit and target.render then
			constfor i = 1, #this.render.sprites do
				local s = this.render.sprites[i]
				s.flip_x = target.render.sprites[1].flip_x
				s.ts = store.tick_ts
				@constif(this.render.sprites[i].size_names)
				s.name = s.size_names[target.unit.size]
			constend
		end
	constend
	return true
end
]]

mod_track_target.update = [[
return function(this, store)
	local m = this.modifier

	this.modifier.ts = store.tick_ts

	local target = store.entities[m.target_id]

	if not target or not target.pos then
		queue_remove(store, this)

		return
	end

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead
			@constif(this.modifier.duration >= 0)
			or store.tick_ts - m.ts > m.duration
			@constif(this.modifier.last_node)
			or target.nav_path.ni > m.last_node
		then
			queue_remove(store, this)

			return
		end


		constif(this.render)
			if target.unit then
				local s = this.render.sprites[1]
				local flip_sign = 1

				if target.render then
					flip_sign = target.render.sprites[1].flip_x and -1 or 1
				end

				constif(this.modifier.health_bar_offset)
					if target.health_bar then
						local hb = target.health_bar.offset
						local hbo = m.health_bar_offset
						s.offset.x, s.offset.y = hb.x + hbo.x * flip_sign, hb.y + hbo.y

					constif(this.modifier.use_mod_offset)
					elseif target.unit.mod_offset then
						s.offset.x, s.offset.y = target.unit.mod_offset.x * flip_sign, target.unit.mod_offset.y
					constend
					end
				constelseif(this.modifier.use_mod_offset)
					s.offset.x, s.offset.y = target.unit.mod_offset.x * flip_sign, target.unit.mod_offset.y
				constend
			end
		constend

		coroutine.yield()
	end
end
]]

return mod_track_target
