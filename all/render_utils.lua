-- chunkname: @./all/render_utils.lua

local log = require("klua.log"):new("render_utils")
local I = require("klove.image_db")
local G = love.graphics
local RU = {}

RU.BATCHES_COUNT = 30
RU.BATCH_SIZE = 30
RU.batches = {}
RU.bi = 1
local function norm_component(c)
    if not c then
        return 1
    end
    if c > 1 then
        return c / 255
    end
    return c
end
local function norm_color(r, g, b, a)
    return norm_component(r), norm_component(g), norm_component(b), norm_component(a)
end

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

function RU.frame_draw_params(f)
	local ss = f.ss
	local x = f.pos.x + f.offset.x
	local y = REF_H - (f.pos.y + f.offset.y)
	local r = -f.r
	local ref_scale = ss.ref_scale or 1
	local sy = (f.flip_y and -1 or 1) * ref_scale
	local sx = (f.flip_x and -1 or 1) * ref_scale

	if f.scale then
		sy = sy * f.scale.y
		sx = sx * f.scale.x
	end

	local ox = f.anchor.x * ss.size[1] - ss.trim[1]
	local oy = (1 - f.anchor.y) * ss.size[2] - ss.trim[2]

	return ss.quad, x, y, r, sx, sy, ox, oy
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

		if not f.ss or f.hidden then
			-- block empty
		else
			local ss = f.ss

			if batch_count == BATCH_SIZE or f._shader ~= current_shader or ss.atlas and ss.atlas ~= current_atlas then
				if batch_count > 0 then
					G.draw(batch)

					bi = bi_count < bi + 1 and 1 or bi + 1
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
				r, g, b = f.color[1] /255, f.color[2] / 255, f.color[3] / 255
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

		bi = bi_count < bi + 1 and 1 or bi + 1
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

return RU
