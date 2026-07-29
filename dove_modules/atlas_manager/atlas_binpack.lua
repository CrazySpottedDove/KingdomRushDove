-- MAXRECTS-BSSF with MINW split and full prune.
-- Reference: "A Thousand Ways to Pack the Bin" (Jylänky 2010)

local binpack = {}

local function fits(rect, w, h)
	return w <= rect.w and h <= rect.h
end

-- remove any rect that is fully contained by another in the list
local function prune(free)
	for i = #free, 1, -1 do
		local ri = free[i]
		for j = #free, 1, -1 do
			if i ~= j then
				local rj = free[j]
				if rj.x <= ri.x and rj.y <= ri.y and rj.x + rj.w >= ri.x + ri.w and rj.y + rj.h >= ri.y + ri.h then
					table.remove(free, i)
					break
				end
			end
		end
	end
end

---@param frames table: array of {w, h, frame_name}
---@param W number: atlas width
---@param H number: atlas height
function binpack.pack(frames, W, H)
	local sorted = {}
	for i, f in ipairs(frames) do
		sorted[i] = {
			w = f.w,
			h = f.h,
			frame_name = f.frame_name,
			data = f
		}
	end
	table.sort(sorted, function(a, b)
		return a.w * a.h > b.w * b.h
	end)

	-- reserve health bar corner-dot block: HEALTH_BAR_CORNER_DOT_QUAD = {0,0,1,1,1024,1024}
	-- For an atlas of size W×H, the quad samples ceil(W/1024) × ceil(H/1024) pixels.
	-- Bilinear filtering at the stretched bar's last pixel also samples the next texel
	-- beyond that range, so add 1 pixel margin.
	local hb_rw = math.ceil(W / 1024) + 1
	local hb_rh = math.ceil(H / 1024) + 1
	local free = {}
	if W > hb_rw then
		free[#free + 1] = {
			x = hb_rw,
			y = 0,
			w = W - hb_rw,
			h = H
		}
	end
	if H > hb_rh then
		free[#free + 1] = {
			x = 0,
			y = hb_rh,
			w = hb_rw,
			h = H - hb_rh
		}
	end
	if W <= hb_rw and H <= hb_rh then
		free[#free + 1] = {
			x = 0,
			y = 0,
			w = W,
			h = H
		}
	end
	local placed = {}

	for _, f in ipairs(sorted) do
		-- BSSF: find the best free rect
		local best_idx = nil
		local best_short = math.huge

		for i, fr in ipairs(free) do
			if fits(fr, f.w, f.h) then
				local short = math.min(fr.w - f.w, fr.h - f.h)
				if short < best_short then
					best_short = short
					best_idx = i
				end
			end
		end

		if not best_idx then
			return nil, string.format("Cannot fit '%s' (%dx%d) into %dx%d", f.frame_name or "?", f.w, f.h, W, H)
		end

		local GAP = 4
		local fr = free[best_idx]
		local px, py = fr.x, fr.y
		local rw, bh = fr.w - f.w - GAP, fr.h - f.h - GAP

		placed[#placed + 1] = {
			x = px,
			y = py,
			w = f.w,
			h = f.h,
			frame_name = f.frame_name,
			data = f.data
		}
		table.remove(free, best_idx)

		-- MINW split with 1-pixel gap between frames (prevents bilinear texture bleeding)
		if rw > 0 and bh > 0 then
			if rw > bh then
				-- more width leftover → right rect full height, bottom rect placed width
				free[#free + 1] = {
					x = px + f.w + GAP,
					y = py,
					w = rw,
					h = fr.h
				}
				free[#free + 1] = {
					x = px,
					y = py + f.h + GAP,
					w = f.w,
					h = bh
				}
			else
				-- more height leftover → right rect placed height, bottom rect full width
				free[#free + 1] = {
					x = px + f.w + GAP,
					y = py,
					w = rw,
					h = f.h
				}
				free[#free + 1] = {
					x = px,
					y = py + f.h + GAP,
					w = fr.w,
					h = bh
				}
			end
		elseif rw > 0 then
			free[#free + 1] = {
				x = px + f.w + GAP,
				y = py,
				w = rw,
				h = fr.h
			}
		elseif bh > 0 then
			free[#free + 1] = {
				x = px,
				y = py + f.h + GAP,
				w = fr.w,
				h = bh
			}
		end

		prune(free)
	end

	return placed
end

return binpack
