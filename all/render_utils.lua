-- chunkname: @./all/render_utils.lua
local log = require("lib.klua.log"):new("render_utils")
local I = require("klove.image_db")
local EXO = require("exoskeleton")
local G = love.graphics
local RU = {}

RU.BATCHES_COUNT = 30
RU.BATCH_SIZE = 90
RU.batches = {}
RU.bi = 1

function RU.init()
	local temp_canvas = G.newCanvas(2, 2)

	for i = 1, RU.BATCHES_COUNT do
		table.insert(RU.batches, G.newSpriteBatch(temp_canvas, RU.BATCH_SIZE, "stream"))
	end

	RU.bi = 1
	RU.last_texture = nil
end

function RU.destroy()
	RU.batches = {}
	RU.last_texture = nil
end

--- get frame draw params
---@param f table sprite
---@return userdata quad, number x, number y, number r, number sx, number sy, number ox, number oy
function RU.frame_draw_params(f)
	local ss = f.ss
	local ref_scale = ss.ref_scale or 1
	local sy = (f.flip_y and -1 or 1) * ref_scale
	local sx = (f.flip_x and -1 or 1) * ref_scale

	if f.scale then
		sy = sy * f.scale.y
		sx = sx * f.scale.x
	end

	return ss.quad, f.pos.x + f.offset.x, REF_H - (f.pos.y + f.offset.y), -f.r, sx, sy, f.anchor.x * ss.size[1] - ss.trim[1], (1 - f.anchor.y) * ss.size[2] - ss.trim[2]
end

function RU.draw_frames_range(frames, start_idx, max_z)
	local current_atlas, lr, lg, lb, la
	local r, g, b, a = 255, 255, 255, 255
	local batch_count = 0
	local batches_count = 0
	local BATCH_SIZE = RU.BATCH_SIZE
	local last_idx = start_idx
	local frame_draw_params = RU.frame_draw_params
	local batches = RU.batches
	local bi = RU.bi
	local bi_count = #RU.batches
	local batch = batches[bi]
	local last_texture = RU.last_texture
	local current_shader

	batch:clear()

	if last_texture then
		batch:setTexture(last_texture)
	end

	G.setColor(1, 1, 1, 1)

	for i = start_idx, #frames do
		local f = frames[i]

		if max_z <= f.z then
			break
		end

		last_idx = i

		if f.hidden then
		-- block empty
		elseif f.exo then
			for part_idx, part in ipairs(f.exo_frame) do
				do
					local part_type, part_name_idx, alpha, x, y, sx, sy, r, kx, ky = unpack(part)

					if part.hidden then
					-- block empty
					else
						if part_type == 8 then
							local flipf = (f.flip_x and -1 or 1) * (f.flip_y and -1 or 1)

							sy = sy * (f.flip_y and -1 or 1)
							sx = sx * (f.flip_x and -1 or 1)

							local f_sx = f.flip_x and -1 or 1
							local f_sy = f.flip_y and -1 or 1

							if f.scale then
								sy = sy * f.scale.y
								sx = sx * f.scale.x
								f_sx = f_sx * f.scale.x
								f_sy = f_sy * f.scale.y
							end

							local p_x_s = x * f_sx
							local p_y_s = y * f_sy

							r = -f.r * flipf + r

							if f.r ~= 0 then
								local cr = math.cos(-f.r)
								local sr = math.sin(-f.r)
								local p_x = p_x_s * cr - p_y_s * sr
								local p_y = p_x_s * sr + p_y_s * cr

								x = p_x + f.pos.x + f.offset.x
								y = -p_y + f.pos.y + f.offset.y
							else
								x = p_x_s + f.pos.x + f.offset.x
								y = -p_y_s + f.pos.y + f.offset.y
							end

							if not f.last_attach_point_xform then
								f.last_attach_point_xform = {}
							end

							if not f.last_attach_point_xform[part_name_idx] then
								f.last_attach_point_xform[part_name_idx] = {}
							end

							local l = f.last_attach_point_xform[part_name_idx]

							l.x, l.y = x, y
							l.r = r * flipf
							l.sx, l.sy = sx, sy

							goto label_6_0
						end

						local part_name, pox, poy = unpack(f.exo.parts[part_name_idx])
						local ss = I:s(part_name)

						if batch_count == BATCH_SIZE or f.shader ~= current_shader or ss.atlas and ss.atlas ~= current_atlas then
							if batch_count > 0 then
								G.draw(batch)

								bi = bi + 1

								if bi_count < bi then
									RU.add_batches(10)

									bi_count = #RU.batches
								end

								batch = batches[bi]

								if last_texture then
									batch:setTexture(last_texture)
								end
							end

							batch:clear()

							lr, lg, lb, la = nil, nil, nil, nil

							if ss.atlas then
								local im, w, h = I:i(ss.atlas)

								current_atlas = ss.atlas
								last_texture = im

								batch:setTexture(im)
							end

							batch_count = 0
							batches_count = batches_count + 1

							if f.shader ~= current_shader then
								G.setShader(f.shader)

								if f.shader_args then
									for k, v in pairs(f.shader_args) do
										f.shader:send(k, v)
									end
								end

								current_shader = f.shader
							end
						end

						local cr, cg, cb = 1, 1, 1

						if f.color then
							cr, cg, cb = f.color[1] / 255, f.color[2] / 255, f.color[3] / 255
						end

						local ca = f.alpha * (alpha or 1)

						if ca ~= la or cr ~= lr or cg ~= lg or cb ~= lb then
							batch:setColor(cr, cg, cb, ca / 255)

							lr, lg, lb, la = cr, cg, cb, ca
						end

						local quad = ss.quad
						local ref_scale = ss.ref_scale or 1
						local flipf = (f.flip_x and -1 or 1) * (f.flip_y and -1 or 1)

						sy = sy * (f.flip_y and -1 or 1) * ref_scale
						sx = sx * (f.flip_x and -1 or 1) * ref_scale

						local f_sx = f.flip_x and -1 or 1
						local f_sy = f.flip_y and -1 or 1

						if f.scale then
							sy = sy * f.scale.y
							sx = sx * f.scale.x
							f_sx = f_sx * f.scale.x
							f_sy = f_sy * f.scale.y
						end

						local ox = 0.5 * ss.size[1] - ss.trim[1] - pox / ref_scale
						local oy = 0.5 * ss.size[2] - ss.trim[2] - poy / ref_scale

						if ss.textureRotated then
							r = r - math.pi / 2
							ox = 0.5 * ss.size[2] - ss.trim[4] + poy / ref_scale
							oy = 0.5 * ss.size[1] - ss.trim[1] - pox / ref_scale
							-- sy = xf.sx * (f.flip_y and -1 or 1) * ref_scale
							-- sx = xf.sy * (f.flip_x and -1 or 1) * ref_scale
							sy = sx * (f.flip_y and -1 or 1) * ref_scale
							sx = sy * (f.flip_x and -1 or 1) * ref_scale

							if f.scale then
								sy = sy * f.scale.x
								sx = sx * f.scale.y
							end
						end

						local p_x_s = x * f_sx
						local p_y_s = y * f_sy

						r = -f.r * flipf + r

						if f.r ~= 0 then
							local cr = math.cos(-f.r)
							local sr = math.sin(-f.r)
							local p_x = p_x_s * cr - p_y_s * sr
							local p_y = p_x_s * sr + p_y_s * cr

							x = p_x + f.pos.x + f.offset.x
							y = REF_H - (-p_y + f.pos.y + f.offset.y)
						else
							x = p_x_s + f.pos.x + f.offset.x
							y = REF_H - (-p_y_s + f.pos.y + f.offset.y)
						end

						batch:add(quad, x, y, r * flipf, sx, sy, ox, oy, kx, ky)

						batch_count = batch_count + 1
					end
				end

				::label_6_0::
			end
		elseif f.ss then
			local ss = f.ss

			if batch_count == BATCH_SIZE or f._shader ~= current_shader or ss.atlas and ss.atlas ~= current_atlas then
				if batch_count > 0 then
					G.draw(batch)

					bi = bi % bi_count + 1
					batch = batches[bi]

					if last_texture then
						batch:setTexture(last_texture)
					end
				end

				batch:clear()

				lr = nil
				lg = nil
				lb = nil
				la = nil

				if ss.atlas then
					local im, w, h = I:i(ss.atlas)

					current_atlas = ss.atlas
					last_texture = im

					batch:setTexture(im)
				end

				batch_count = 0
				batches_count = batches_count + 1

				if f._shader ~= current_shader then
					G.setShader(f._shader)

					if f.shader_args then
						for k, v in pairs(f.shader_args) do
							f._shader:send(k, v)
						end
					end

					current_shader = f._shader
				end
			end

			if f.color then
				r, g, b = f.color[1] / 255, f.color[2] / 255, f.color[3] / 255
			else
				r, g, b = 1, 1, 1
			end

			a = f.alpha

			if a ~= la or r ~= lr or g ~= lg or b ~= lb then
				batch:setColor(r, g, b, a / 255)

				lr, lg, lb, la = r, g, b, a
			end

			batch:add(frame_draw_params(f))

			batch_count = batch_count + 1
		end
	end

	if batch_count > 0 then
		G.draw(batch)

		bi = bi % bi_count + 1
		batch = batches[bi]
		batches_count = batches_count + 1
	end

	G.setColor(1, 1, 1, 1)

	if current_shader then
		G.setShader()
	end

	RU.bi = bi
	RU.last_texture = last_texture

	return last_idx
end

function RU.add_batches(count)
	local temp_canvas = G.newCanvas(2, 2)

	for i = 1, count do
		table.insert(RU.batches, G.newSpriteBatch(temp_canvas, RU.BATCH_SIZE, "stream"))
	end
end

return RU
