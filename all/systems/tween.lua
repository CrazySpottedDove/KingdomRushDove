local M = {}

local perf = require("dove_modules.perf.perf")
local U = require("utils")
local V = require("lib.klua.vector")

local cos = math.cos
local PI = math.pi

local function queue_remove(store, e)
	simulation:queue_remove_entity(e)
end

--- LERP FUNCTIONS BEGIN
local function lerp_boolean_multiply(a, b, t, s, key)
	s[key] = a[2] and s[key]
end

local function lerp_boolean(a, b, t, s, key)
	s[key] = a[2]
end

local function lerp_number_step_multiply(a, b, t, s, key)
	s[key] = a[2] * s[key]
end

local function lerp_number_step(a, b, t, s, key)
	s[key] = a[2]
end

local function lerp_number_linear_multiply(a, b, t, s, key)
	s[key] = a == b and (a[2] * s[key]) or ((a[2] + (b[2] - a[2]) * (t - a[1]) / (b[1] - a[1])) * s[key])
end

local function lerp_number_linear(a, b, t, s, key)
	s[key] = a == b and a[2] or (a[2] + (b[2] - a[2]) * (t - a[1]) / (b[1] - a[1]))
end

local function lerp_number_quad_multiply(a, b, t, s, key)
	if a == b then
		s[key] = a[2] * s[key]

		return
	end

	local tt = (t - a[1]) / (b[1] - a[1])

	s[key] = (a[2] + (b[2] - a[2]) * tt * tt) * s[key]
end

local function lerp_number_quad(a, b, t, s, key)
	if a == b then
		s[key] = a[2]

		return
	end

	local tt = (t - a[1]) / (b[1] - a[1])

	s[key] = a[2] + (b[2] - a[2]) * tt * tt
end

local function lerp_number_sine_multiply(a, b, t, s, key)
	s[key] = a == b and (a[2] * s[key]) or (a[2] + (b[2] - a[2]) * (0.5 * (1 - cos((t - a[1]) / (b[1] - a[1]) * PI))) * s[key])
end

local function lerp_number_sine(a, b, t, s, key)
	s[key] = a == b and a[2] or (a[2] + (b[2] - a[2]) * (0.5 * (1 - cos((t - a[1]) / (b[1] - a[1]) * PI))))
end

local function lerp_table_step(a, b, t, s, key)
	s[key].x = a[2].x
	s[key].y = a[2].y
end

local function lerp_table_step_multiply(a, b, t, s, key)
	s[key].x = a[2].x * s[key].x
	s[key].y = a[2].y * s[key].y
end

local function lerp_table_linear(a, b, t, s, key)
	if a == b then
		s[key].x = a[2].x
		s[key].y = a[2].y

		return
	end

	local tt = (t - a[1]) / (b[1] - a[1])
	local av = a[2]
	local bv = b[2]

	s[key].x = av.x + (bv.x - av.x) * tt
	s[key].y = av.y + (bv.y - av.y) * tt
end

local function lerp_table_linear_multiply(a, b, t, s, key)
	if a == b then
		s[key].x = a[2].x * s[key].x
		s[key].y = a[2].y * s[key].y

		return
	end

	local tt = (t - a[1]) / (b[1] - a[1])
	local av = a[2]
	local bv = b[2]

	s[key].x = (av.x + (bv.x - av.x) * tt) * s[key].x
	s[key].y = (av.y + (bv.y - av.y) * tt) * s[key].y
end

local function lerp_table_quad(a, b, t, s, key)
	if a == b then
		s[key].x = a[2].x
		s[key].y = a[2].y

		return
	end

	local tt = (t - a[1]) / (b[1] - a[1])
	local av = a[2]
	local bv = b[2]

	s[key].x = av.x + (bv.x - av.x) * tt * tt
	s[key].y = av.y + (bv.y - av.y) * tt * tt
end

local function lerp_table_quad_multiply(a, b, t, s, key)
	if a == b then
		s[key].x = a[2].x * s[key].x
		s[key].y = a[2].y * s[key].y

		return
	end

	local tt = (t - a[1]) / (b[1] - a[1])
	local av = a[2]
	local bv = b[2]

	s[key].x = (av.x + (bv.x - av.x) * tt * tt) * s[key].x
	s[key].y = (av.y + (bv.y - av.y) * tt * tt) * s[key].y
end

local function lerp_table_sine_multiply(a, b, t, s, key)
	if a == b then
		s[key].x = a[2].x * s[key].x
		s[key].y = a[2].y * s[key].y

		return
	end

	local ft = 0.5 * (1 - cos((t - a[1]) / (b[1] - a[1]) * PI))
	local av = a[2]
	local bv = b[2]

	s[key].x = (av.x + (bv.x - av.x) * ft) * s[key].x
	s[key].y = (av.y + (bv.y - av.y) * ft) * s[key].y
end

local function lerp_table_sine(a, b, t, s, key)
	if a == b then
		s[key].x = a[2].x
		s[key].y = a[2].y

		return
	end

	local ft = 0.5 * (1 - cos((t - a[1]) / (b[1] - a[1]) * PI))
	local av = a[2]
	local bv = b[2]

	s[key].x = av.x + (bv.x - av.x) * ft
	s[key].y = av.y + (bv.y - av.y) * ft
end
--- LERP FUNCTIONS END

function M.register(sys)
	sys.tween = {}
	sys.tween.name = "tween"

	function sys.tween:init(store)
		store.entities_with_tween = {}
	end

	function sys.tween:on_insert_unconditional(entity, store)
		if entity.tween then
			store.entities_with_tween[entity.id] = entity
			for i = 1, #entity.tween.props do
				local p = entity.tween.props[i]
				for j = 1, #p.keys do
					local n = p.keys[j]
					for k = 1, 2 do
						if type(n[k]) == "string" then
							local nf = loadstring("return " .. n[k])
							local env = {}

							env.this = entity
							env.store = store
							env.math = math
							env.U = U
							env.V = V

							setfenv(nf, env)

							n[k] = nf()
						end
					end
				end

				do
					local sprite = entity.render.sprites[p.sprite_id]
					local key_type

					if #p.keys == 0 then
						if sprite[p.name] then
							key_type = type(sprite[p.name])
						else
							error(entity.template_name .. " tween_prop " .. p.name .. " has no keys and sprite has no such property")
						end
					else
						key_type = type(p.keys[1][2])
					end

					local interp_type = p.interp or "linear"
					local multiply = p.multiply

					if not sprite[p.name] then
						if key_type == "table" or key_type == "cdata" then
							sprite[p.name] = V.vclone(p.keys[1][2])
						else
							sprite[p.name] = p.keys[1][2]
						end
					end

					if key_type == "boolean" then
						p.interp_fn = multiply and lerp_boolean_multiply or lerp_boolean

						goto continue
					end

					if key_type == "number" then
						if interp_type == "linear" then
							p.interp_fn = multiply and lerp_number_linear_multiply or lerp_number_linear
						elseif interp_type == "sine" then
							p.interp_fn = multiply and lerp_number_sine_multiply or lerp_number_sine
						elseif interp_type == "step" then
							p.interp_fn = multiply and lerp_number_step_multiply or lerp_number_step
						elseif interp_type == "quad" then
							p.interp_fn = multiply and lerp_number_quad_multiply or lerp_number_quad
						end
					elseif key_type == "table" or key_type == "cdata" then
						if interp_type == "linear" then
							p.interp_fn = multiply and lerp_table_linear_multiply or lerp_table_linear
						elseif interp_type == "sine" then
							p.interp_fn = multiply and lerp_table_sine_multiply or lerp_table_sine
						elseif interp_type == "step" then
							p.interp_fn = multiply and lerp_table_step_multiply or lerp_table_step
						elseif interp_type == "quad" then
							p.interp_fn = multiply and lerp_table_quad_multiply or lerp_table_quad
						end
					end
				end

				::continue::
			end

			if entity.tween.random_ts then
				entity.tween.ts = U.frandom(-1 * entity.tween.random_ts, 0)
			end
		end
	end

	function sys.tween:on_render_update(dt, ts, store)
		perf.start("tween_system")
		local entities = store.entities_with_tween

		for _, e in pairs(entities) do
			if not e.tween.disabled then
				local finished = true
				local sprites = e.render.sprites
				local tween = e.tween

				for i = 1, #tween.props do
					local tween_prop = tween.props[i]
					if not tween_prop.disabled then
						local s = sprites[tween_prop.sprite_id]
						local keys = tween_prop.keys
						local ka = keys[1]
						local kb = keys[#keys]
						local start_time = ka[1]
						local end_time = kb[1]
						local duration = end_time - start_time
						local time = ts - (tween_prop.ts or tween.ts or s.ts)

						if tween_prop.time_offset then
							time = time + tween_prop.time_offset
						end

						if tween_prop.loop then
							time = time % duration
						end

						if tween.reverse and not tween_prop.ignore_reverse then
							time = duration - time
							if time <= start_time then
								time = start_time
							else
								if time > end_time then
									time = end_time
								end

								finished = finished and tween_prop.loop
							end
						else
							if time >= end_time then
								time = end_time
							else
								if time < start_time then
									time = start_time
								end

								finished = finished and tween_prop.loop
							end
						end

						for i = 2, #keys do
							local ki = keys[i]

							if time <= ki[1] then
								kb = ki
								ka = time == ki[1] and ki or keys[i - 1]

								break
							end
						end

						tween_prop.interp_fn(ka, kb, time, s, tween_prop.name)
					end
				end

				if finished then
					if tween.remove then
						queue_remove(store, e)
					end

					if tween.run_once then
						tween.disabled = true
					end
				end
			end
		end
		perf.stop("tween_system")
	end

	function sys.tween:on_remove_unconditional(entity, store)
		if entity.tween then
			store.entities_with_tween[entity.id] = nil
		end
	end
end

return M
