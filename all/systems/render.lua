local M = {}
local log = require("lib.klua.log"):new("render")
local perf = require("dove_modules.perf.perf")
local A = require("animation_db")
local I = require("lib.klove.image_db")
local SH = require("klove.shader_db")
local V = require("lib.klua.vector")
local U = require("utils")
local EXO = require("all.exoskeleton")
local ffi = require("ffi")

require("all.constants")
local table_clear = require("table.clear")
MISSED_SS = {}

ffi.cdef[[
typedef struct {
    float sort_y;
    int z;
    int draw_order;
    int lua_index;
} RenderFrameFFI;
void ffi_sort(RenderFrameFFI* arr, RenderFrameFFI* tmp, int n);
]]

local lib_render_sort
local libname

if IS_ANDROID then
	libname = "librender_sort_android.so"
else
	if jit and jit.os == "Windows" then
		libname = "all/librender_sort.dll"
	else
		libname = "all/librender_sort.so"
	end
end

local ok, lib = pcall(ffi.load, libname)

if ok and lib then
	lib_render_sort = lib
else
	local function cmp(a, b)
		if a.z ~= b.z then
			return a.z < b.z
		end

		if a.sort_y ~= b.sort_y then
			return a.sort_y > b.sort_y
		end

		if a.draw_order ~= b.draw_order then
			return a.draw_order < b.draw_order
		end

		return false
	end

	local function merge(arr, tmp, left, mid, right)
		for i = left, right do
			tmp[i] = arr[i]
		end

		local i, j, k = left, mid + 1, left

		while i <= mid and j <= right do
			if not cmp(tmp[j], tmp[i]) then
				arr[k] = tmp[i]
				i = i + 1
			else
				arr[k] = tmp[j]
				j = j + 1
			end

			k = k + 1
		end

		while i <= mid do
			arr[k] = tmp[i]
			i = i + 1
			k = k + 1
		end

		while j <= right do
			arr[k] = tmp[j]
			j = j + 1
			k = k + 1
		end
	end

	local function merge_sort(arr, tmp, left, right)
		if left < right then
			local mid = math.floor((left + right) / 2)

			merge_sort(arr, tmp, left, mid)
			merge_sort(arr, tmp, mid + 1, right)
			merge(arr, tmp, left, mid, right)
		end
	end

	lib_render_sort = {
		ffi_sort = function(arr, tmp, n)
			merge_sort(arr, tmp, 0, n - 1)
		end
	}
end

function M.register(sys)
	sys.render = {}
	sys.render.name = "render"

	function sys.render:init(store)
		store.render_frames = {}
		store.render_frames_swapper = {}
		store.render_frames_count = 0
		store.render_frames_ffi = ffi.new("RenderFrameFFI[16384]")
		store.render_frames_ffi_tmp = ffi.new("RenderFrameFFI[16384]")

		local hb_quad = love.graphics.newQuad(unpack(HEALTH_BAR_CORNER_DOT_QUAD))

		self._hb_ss = {
			ref_scale = 1,
			quad = hb_quad,
			trim = {0, 0},
			size = {1, 1}
		}
		self._hb_sizes = HEALTH_BAR_SIZES[store.texture_size] or HEALTH_BAR_SIZES.default
		self._hb_colors = HEALTH_BAR_COLORS
	end

	function sys.render:on_insert_unconditional(entity, store)
		local render_frames = store.render_frames

		if entity.render then
			local track_e_pos = nil
			for i = 1, #entity.render.sprites do
				local s = entity.render.sprites[i]

				s.marked_to_remove = false
				s._render_e_id = entity.id
				s._draw_order = 100000 * (s.draw_order or i) + entity.id

				if s.random_ts then
					s.ts = U.frandom(-1 * s.random_ts, 0)
				end

				if not s.pos then
					if not track_e_pos then
						s.pos = V.v(entity.pos.x, entity.pos.y)
						track_e_pos = s.pos
						s._track_e = true
					else
						s.pos = track_e_pos
					end
				end

				if s.shader then
					s._shader = SH:get(s.shader)
				end

				store.render_frames_count = store.render_frames_count + 1
				render_frames[store.render_frames_count] = s
			end

			if entity.health_bar then
				local hb = entity.health_bar
				local hbsize = self._hb_sizes[hb.type]
				local fb = {
					flip_x = false,
					pos = V.vv(0),
					r = 0,
					alpha = 255,
					anchor = V.vv(0),
					offset = V.v(hb.offset.x - hbsize.x * 0.5, hb.offset.y),
					_draw_order = (hb.draw_order and 100000 * hb.draw_order + 1 or 200002) + entity.id,
					z = Z_OBJECTS,
					sort_y_offset = hb.sort_y_offset,
					ss = self._hb_ss,
					color = hb.colors and hb.colors.bg or self._hb_colors.bg,
					bar_width = hbsize.x,
					scale = V.v(hbsize.x, hbsize.y),
					hidden = true
				}

				local ff = {
					flip_x = false,
					pos = fb.pos,
					r = 0,
					alpha = 255,
					anchor = V.vv(0),
					offset = V.v(hb.offset.x - hbsize.x * 0.5, hb.offset.y),
					_draw_order = (hb.draw_order and 100000 * hb.draw_order + 2 or 200003) + entity.id,
					z = Z_OBJECTS,
					sort_y_offset = hb.sort_y_offset,
					ss = self._hb_ss,
					color = hb.colors and hb.colors.fg or self._hb_colors.fg,
					bar_width = hbsize.x,
					scale = V.v(hbsize.x, hbsize.y),
					hidden = true
				}

				for i = #hb.frames, 1, -1 do
					hb.frames[i].marked_to_remove = true
				end

				hb.frames[1] = fb
				hb.frames[2] = ff
				store.render_frames_count = store.render_frames_count + 1
				render_frames[store.render_frames_count] = fb
				store.render_frames_count = store.render_frames_count + 1
				render_frames[store.render_frames_count] = ff

				if hb.black_bar_hp then
					local fk = {
						flip_x = false,
						pos = fb.pos,
						r = 0,
						alpha = 255,
						anchor = V.vv(0),
						offset = V.v(hb.offset.x - hbsize.x * 0.5, hb.offset.y),
						_draw_order = (hb.draw_order and 100000 * hb.draw_order or 200001) + entity.id,
						z = Z_OBJECTS,
						sort_y_offset = hb.sort_y_offset,
						ss = self._hb_ss,
						color = hb.colors and hb.colors.black or self._hb_colors.black,
						bar_width = hbsize.x,
						scale = V.v(hbsize.x, hbsize.y),
						hidden = true
					}

					hb.frames[3] = fk
					store.render_frames_count = store.render_frames_count + 1
					render_frames[store.render_frames_count] = fk
				end
			end
		end
	end

	function sys.render:on_remove_unconditional(entity, store)
		if entity.render then
			for i = #entity.render.sprites, 1, -1 do
				local s = entity.render.sprites[i]

				s.marked_to_remove = true
			end

			if entity.health_bar then
				for i = #entity.health_bar.frames, 1, -1 do
					local f = entity.health_bar.frames[i]

					f.marked_to_remove = true
					entity.health_bar.frames[i] = nil
				end
			end
		end
	end

	function sys.render:on_render_update(dt, ts, store)
		perf.start("render")

		local render_frames = store.render_frames
		local render_frames_ffi = store.render_frames_ffi
		local n = 0

		for i = 1, store.render_frames_count do
			local s = render_frames[i]

			if not s.marked_to_remove then
				if s._render_e_id then
					if s.ts > ts then
						s.hidden = true
						s._hidden_for_ts = true
					elseif s._hidden_for_ts then
						s.hidden = false
						s._hidden_for_ts = false
					end

					do
						local fn
						local last_runs = s.runs

						if s.animated then
							fn, s.runs, s.frame_idx = A:fn(s.prefix and (s.prefix .. "_" .. s.name) or s.name, ts - s.ts + s.time_offset, s.loop, s.fps)

							s.frame_name = fn
						else
							s.runs = 0
							s.frame_idx = 1
							fn = s.name
						end

						if s.exo then
							local exo_frame = EXO:f(fn)

							if exo_frame then
								s.exo_frame = exo_frame
								local exo = EXO:get_exo_by_frame(exo_frame)

								if s.exo_hide_prefix then
									for i = 1, #exo_frame do
										local p = exo_frame[i]
										if p[1] == 1 then
											local pname = exo.parts[p[2]][1]

											p.hidden = false

											for j = 1, #s.exo_hide_prefix do
												if string.find(pname, s.exo_hide_prefix[j], 1, true) then
													p.hidden = true

													break
												end
											end
										end
									end
								end
							else
								-- if not MISSED_SS[fn] then
								-- 	-- fallback, 仅在开发时启用，用于检查美术资源
								-- 	log.error("Failed to get EXO frame for entity %s, frame id: %d", e.template_name, i)
								-- 	log.error("EXO name: %s", fn)
								-- 	MISSED_SS[fn] = true
								-- end
								s.exo_frame = {}
							end
						else
							s.sync_flag = last_runs ~= s.runs
							s.ss = I:s(fn)

						-- DEBUG:仅在开发时启用，用于检查美术资源
						-- if s.ss == nil then
						-- 	local e = store.entities[s._render_e_id]
						-- 	if s.animation then
						-- 		if not MISSED_SS[s.animation] then
						-- 			log.error("Failed to get sprite for entity %s, frame id: %d", e.template_name or e.id, i)
						-- 			log.error("Animation name: %s", s.animation)
						-- 			MISSED_SS[s.animation] = true
						-- 		end

						-- 	elseif s.animated then
						-- 		if not MISSED_SS[(s.prefix or "nil") .. "_" .. s.name] then
						-- 			log.error("Failed to get sprite for entity %s, frame id: %d", e.template_name or e.id, i)
						-- 			log.error("Animated prefix: %s", s.prefix)
						-- 			log.error("Animated name: %s", s.name)
						-- 			MISSED_SS[(s.prefix or "nil") .. "_" .. s.name] = true
						-- 		end
						-- 	else
						-- 		if not MISSED_SS[s.name] then
						-- 			log.error("Failed to get sprite for entity %s, frame id: %d", e.template_name or e.id, i)
						-- 			log.error("Static sprite name: %s", s.name)
						-- 			MISSED_SS[s.name] = true
						-- 		end
						-- 	end
						-- end
						end
					end

					if s.hide_after_runs and s.runs >= s.hide_after_runs then
						s.hidden = true
					end

					local e = store.entities[s._render_e_id]

					if s._track_e then
						s.pos.x, s.pos.y = e.pos.x, e.pos.y
					end

					if e.health_bar and e.health_bar._last_ts ~= ts then
						local hb = e.health_bar
						hb._last_ts = ts
						local fb = hb.frames[1]
						local ff = hb.frames[2]
						local fk = hb.black_bar_hp and hb.frames[3] or nil

						if e.health.hp == e.health.hp_max or hb.hidden then
							fb.hidden = true
							ff.hidden = true

							if fk then
								fk.hidden = true
							end
						else
							fb.hidden = false
							ff.hidden = false
							fb.pos.x, fb.pos.y = e.pos.x, e.pos.y

							if fk then
								fk.hidden = false
								ff.scale.x = e.health.hp / hb.black_bar_hp * ff.bar_width
								fb.scale.x = e.health.hp_max / hb.black_bar_hp * fb.bar_width
							else
								if e.health.hp > e.health.hp_max then
									ff.scale.x = ff.bar_width
									ff.color = hb.colors and hb.colors.fg2 or self._hb_colors.fg2
								else
									ff.scale.x = e.health.hp / e.health.hp_max * ff.bar_width
									ff.color = hb.colors and hb.colors.fg or self._hb_colors.fg
								end
							end
						end
					end
				end

				local ffi_f = render_frames_ffi[n]
				ffi_f.z = s.z
				ffi_f.sort_y = s.sort_y or (s.sort_y_offset or 0) + s.pos.y
				ffi_f.draw_order = s._draw_order
				ffi_f.lua_index = i

				n = n + 1
			end
		end

		lib_render_sort.ffi_sort(render_frames_ffi, store.render_frames_ffi_tmp, n)

		local new_frames = store.render_frames_swapper
		-- 必须保留该行！怀疑对象的写入更替引发了一些 GC 问题，导致性能暴跌。在清理后可以恢复正常
		table_clear(new_frames)

		local i = 0
		while i < n do
			local ffi_f = render_frames_ffi[i]
			i = i + 1
			new_frames[i] = render_frames[ffi_f.lua_index]
		end

		store.render_frames = new_frames
		store.render_frames_swapper = render_frames
		store.render_frames_count = n
		perf.set_frames(n)
		perf.stop("render")
	end
end

return M
