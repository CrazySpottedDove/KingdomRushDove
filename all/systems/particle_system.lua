local M = {}

-- Dependencies
local V = require("lib.klua.vector")
local perf = require("dove_modules.perf.perf")
local ffi = require("ffi")
local km = require("lib.klua.macros")
local A = require("animation_db")
local I = require("lib.klove.image_db")
local floor = math.floor
local random = math.random
local cos = math.cos
local sin = math.sin

-- FFI Definition for particle_t
ffi.cdef[[
    typedef struct {
        double pos_x;
        double pos_y;
        double r;
        double speed_x;
        double speed_y;
        double spin;
        double scale_x;
        double scale_y;
        double ts;
        double last_ts;
        double lifetime;
        int name_idx;
    } particle_t;
]]

function M.register(sys)
	sys.particle_system = {}
	sys.particle_system.name = "particle_system"

	local phase_interp = function(values, phase, default)
		if not values or #values == 0 then
			return default
		end

		if #values == 1 then
			return values[1]
		end

		local intervals = #values - 1
		local interval = floor(phase * intervals)
		local interval_phase = phase * intervals - interval
		local a = values[interval + 1]
		local b = values[interval + 2]
		local ta = type(a)

		if ta == "table" then
			local out = {}

			for i = 1, #a do
				out[i] = a[i] + (b[i] - a[i]) * interval_phase
			end

			return out
		elseif ta == "boolean" then
			return a
		elseif a ~= nil and b ~= nil then
			return a + (b - a) * interval_phase
		end

		return default
	end

	function sys.particle_system:init(store)
		self.phase_interp = phase_interp
	end

	function sys.particle_system:on_insert(entity, store)
		if entity.particle_system then
			local ps = entity.particle_system

			ps.ts = store.tick_ts
			ps.emit_ts = store.tick_ts + ps.ts_offset
		-- ps.last_pos = V.v(0, 0)
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

	function sys.particle_system:on_render_update(dt, ts, store)
		perf.start("particle_system")
		local particle_systems = store.particle_systems

		for _, e in pairs(particle_systems) do
			local ps = e.particle_system
			local e_pos = e.pos
			local target_rot
			local particles = ps.particles
			local frames = ps.frames

			if ps.track_id then
				local target = store.entities[ps.track_id]

				if target then
					ps.last_pos.x, ps.last_pos.y = e.pos.x, e.pos.y
					e_pos.x, e_pos.y = target.pos.x, target.pos.y

					if ps.track_offset then
						e_pos.x, e_pos.y = e_pos.x + ps.track_offset.x, e_pos.y + ps.track_offset.y
					end

					if target.render and target.render.sprites[1] then
						target_rot = target.render.sprites[1].r
					end
				else
					ps.emit = false
					ps.source_lifetime = 0
				end
			end

			if ps.emit_duration and ps.emit then
				if not ps.emit_duration_ts then
					ps.emit_duration_ts = ts
				end

				if ts - ps.emit_duration_ts > ps.emit_duration then
					ps.emit = false
				end
			end

			if not ps.emit then
				ps.emit_ts = ts + ps.ts_offset
			elseif ts - ps.emit_ts > 1 / ps.emission_rate then
				local count = floor((ts - ps.emit_ts) * ps.emission_rate)
				local particle_lifetime = (ps.particle_lifetime[1] + ps.particle_lifetime[2]) * 0.5

				for i = 1, count do
					local pts = ps.emit_ts + i / ps.emission_rate
					ps.particle_count = ps.particle_count + 1

					local p = ffi.new("particle_t", 0, 0, ps.emit_rotation and ps.emit_rotation or (ps.track_rotation and target_rot) or (ps.emit_direction + (random() - 0.5) * ps.emit_rotation_spread), 0, 0, ps.spin and random() * (ps.spin[2] - ps.spin[1]) + ps.spin[1] or 0, 1, 1, pts, pts, particle_lifetime, 0)

					particles[ps.particle_count] = p

					local f = {
						ss = nil,
						flip_x = false,
						flip_y = false,
						pos = V.v(0, 0),
						r = 0,
						scale = V.v(1, 1),
						anchor = V.v(ps.anchor.x, ps.anchor.y),
						offset = V.v(0, 0),
						_draw_order = ps.draw_order and 100000 * ps.draw_order + e.id or floor(pts * 100),
						z = ps.z,
						sort_y = ps.sort_y,
						sort_y_offset = ps.sort_y_offset,
						alpha = 255,
						hidden = nil
					}

					frames[ps.particle_count] = f
					store.render_frames[#store.render_frames + 1] = f

					if ps.track_id then
						local factor = (i - 1) / count
						p.pos_x, p.pos_y = ps.last_pos.x + (e_pos.x - ps.last_pos.x) * factor, ps.last_pos.y + (e_pos.y - ps.last_pos.y) * factor
					else
						p.pos_x, p.pos_y = e_pos.x, e_pos.y
					end

					if ps.emit_area_spread then
						local sp = ps.emit_area_spread
						p.pos_x = p.pos_x + (random() - 0.5) * sp.x * 0.5
						p.pos_y = p.pos_y + (random() - 0.5) * sp.y * 0.5
					end

					if ps.emit_offset then
						p.pos_x = p.pos_x + ps.emit_offset.x
						p.pos_y = p.pos_y + ps.emit_offset.y
					end

					if ps.emit_speed then
						local angle = ps.emission_rate + (random() - 0.5) * ps.emit_spread
						local len = random() * (ps.emit_speed[2] - ps.emit_speed[1]) + ps.emit_speed[1]

						p.speed_x = cos(angle) * len
						p.speed_y = sin(angle) * len
					end

					if ps.scale_var then
						local factor = random() * (ps.scale_var[2] - ps.scale_var[1]) + ps.scale_var[1]
						p.scale_x = factor
						p.scale_y = factor
					end

					if ps.names then
						if ps.cycle_names then
							if not ps._last_name_idx then
								ps._last_name_idx = 0
							end

							ps._last_name_idx = km.zmod(ps._last_name_idx + 1, #ps.names)
							p.name_idx = ps._last_name_idx
						else
							p.name_idx = random(1, #ps.names)
						end
					end
				end

				ps.emit_ts = ps.emit_ts + count * 1 / ps.emission_rate
			end

			for i = ps.particle_count, 1, -1 do
				do
					local p = particles[i]
					local f = frames[i]
					local phase = (ts - p.ts) / p.lifetime

					if phase >= 1 then
						local last_count = ps.particle_count

						particles[i] = particles[last_count]
						frames[i] = frames[last_count]
						particles[last_count] = nil
						frames[last_count] = nil
						ps.particle_count = last_count - 1
						f.marked_to_remove = true

						goto label_51_0
					elseif phase < 0 then
						phase = 0
					end

					local tp = ts - p.last_ts

					p.last_ts = ts
					p.pos_x, p.pos_y = p.pos_x + p.speed_x * tp, p.pos_y + p.speed_y * tp
					f.pos.x, f.pos.y = p.pos_x, p.pos_y
					p.r = p.r + p.spin * tp
					f.r = p.r
					f.scale.x, f.scale.y = phase_interp(ps.scales_x, phase, 1) * p.scale_x, phase_interp(ps.scales_y, phase, 1) * p.scale_y
					f.alpha = phase_interp(ps.alphas, phase, 255)

					if ps.sort_y_offsets then
						f.sort_y_offset = phase_interp(ps.sort_y_offsets, phase, 1)
					end

					if ps.color then
						f.color = ps.color
					end

					local fn

					if ps.animated then
						local to = ts - p.ts

						if ps.animation_fps then
							to = to * ps.animation_fps / FPS
						end

						if p.name_idx > 0 then
							fn = A:fn(ps.names[p.name_idx], to, ps.loop)
						else
							fn = A:fn(ps.name, to, ps.loop)
						end
					elseif p.name_idx > 0 then
						fn = ps.names[p.name_idx]
					else
						fn = ps.name
					end

					f.ss = I:s(fn)
				end

				::label_51_0::
			end

			if ps.source_lifetime and ts - ps.ts > ps.source_lifetime then
				ps.emit = false

				if ps.particle_count == 0 then
					simulation:queue_remove_entity(e)
				end
			end
		end
		perf.stop("particle_system")
	end
end

return M

