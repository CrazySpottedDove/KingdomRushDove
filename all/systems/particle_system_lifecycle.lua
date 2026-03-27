local M = {}

function M.register(sys, deps)
	function sys.particle_system:on_insert(entity, store)
		if entity.particle_system then
			local ps = entity.particle_system

			ps.emit_ts = (ps.emit_ts and ps.emit_ts or store.tick_ts) + ps.ts_offset
			ps.ts = store.tick_ts
			ps.last_pos = {
				x = 0,
				y = 0
			}
		end

		return true
	end

	function sys.particle_system:on_remove(entity, store)
		if entity.particle_system then
			local ps = entity.particle_system

			for i = ps.particle_count, 1, -1 do
				ps.particles[i] = nil
				ps.frames[i].marked_to_remove = true
				ps.frames[i] = nil
			end
		end

		return true
	end
end

return M
