local P = require("path_db")
local E = require("entity_db")
local U = require("utils")
local V = require("lib.klua.vector")
local log = require("lib.klua.log"):new("level218")
local signal = require("lib.hump.signal")
local S = require("sound_db")
local scripts = require("scripts")
local v = V.v
local vv = V.vv
local r = V.r
local function fts(t)
	return t / 30
end
local function find_all_t(store, template_name, contains, fn)
	if not store or not store.entities then
		return {}
	end
	return table.filter(store.entities, function(k, val)
		return (contains and string.find(val.template_name, template_name) or val.template_name == template_name) and (not fn or fn(k, val))
	end)
end
local function queue_insert(store, e)
	simulation:queue_insert_entity(e)
end
local function queue_remove(store, e)
	simulation:queue_remove_entity(e)
end
local function queue_damage(store, damage)
	store.damage_queue[#store.damage_queue + 1] = damage
end
local band, bnot, bor = bit.band, bit.bnot, bit.bor
local band, bnot, bor = bit.band, bit.bnot, bit.bor
local function get_random_round_robin(mutable_history, n, m)
	if not m then
		m = n
		n = 1
	end
	if m < n then
		log.error("ERROR: Random round robin needs M to be bigger or equal than N")
	end
	if #mutable_history == 0 then
		for i = n, m do
			table.insert(mutable_history, i)
		end
	end
	local pos = math.random(1, #mutable_history)
	local v = mutable_history[pos]
	table.remove(mutable_history, pos)
	return v
end
local S18 = {}
local stage218_I = require("lib.klove.image_db")
local function stage218_frame_quad(sd)
	if not sd or not sd.quad then
		return nil
	end
	return sd.quad:getViewport()
end
local function stage218_find_towers(store, pos, radius, filter_fn)
	local towers = table.filter(store.entities, function(k, v)
		return v.tower and not v.pending_removal and U.is_inside_ellipse(v.pos, pos, radius) and (not filter_fn or filter_fn(v, pos))
	end)
	if not towers or #towers == 0 then
		return nil
	end
	return towers
end
S18.nightfall_dissolve = {}
function S18.nightfall_dissolve.quad_screen_rect(pos, s)
	if not s or not s.name or s.animated or s.exo then
		return nil
	end
	local sd = stage218_I:s(s.name)
	local vx, _, vw, vh = stage218_frame_quad(sd)
	if not sd or not vx or not sd.size then
		return nil
	end
	local rs = sd.ref_scale or 1
	local sx = rs * (s.scale and s.scale.x or 1)
	local sy = rs * (s.scale and s.scale.y or 1)
	local ax = s.anchor and s.anchor.x or 0.5
	local ay = s.anchor and s.anchor.y or 0.5
	local trim = sd.trim or {0, 0, 0, 0}
	local x = pos.x + (s.offset and s.offset.x or 0)
	local y = REF_H - (pos.y + (s.offset and s.offset.y or 0))
	return x - (ax * sd.size[1] - trim[1]) * sx, y - ((1 - ay) * sd.size[2] - trim[2]) * sy, vw * sx, vh * sy
end
function S18.nightfall_dissolve.front_noise(px, py)
	local n = 0.5 + 0.3 * math.sin(px * 2.1 + py * 1.3) + 0.2 * math.sin(px * 1 - py * 2.6 + 1.7)
	return math.max(0, math.min(1, n))
end
function S18.nightfall_dissolve.refresh_view_args(args, store)
	local gs = game.game_scale
	local rox, roy
	if game.camera then
		local c = game.camera
		rox = -(c.x * c.zoom - game.screen_w / 2)
		roy = -(c.y * c.zoom - game.screen_h / 2)
		gs = gs * c.zoom
	else
		rox = game.game_ref_origin.x
		roy = game.game_ref_origin.y
	end
	if store.world_offset then
		rox = rox + store.world_offset.x
		roy = roy + store.world_offset.y
	end
	args.view_off = args.view_off or {0, 0}
	args.view_off[1], args.view_off[2] = rox, roy
	args.view_scale = gs
end
function S18.nightfall_dissolve.find_swap_from(this, store)
	for _, e in pairs(store.entities) do
		if e.template_name == this.swap_from and e.pos and (not this.holder_id or e.tower and e.tower.holder_id == this.holder_id) and V.dist(e.pos.x, e.pos.y, this.pos.x, this.pos.y) < 8 then
			return e
		end
	end
	return nil
end
function S18.nightfall_dissolve.find_tower_over(this, store)
	local from_tpl = this.swap_from and E:get_template(this.swap_from)
	local from_style = from_tpl and from_tpl.tower and from_tpl.tower.terrain_style
	for _, e in pairs(store.entities) do
		if e.tower and e.pos and (not this.holder_id or e.tower.holder_id == this.holder_id) and V.dist(e.pos.x, e.pos.y, this.pos.x, this.pos.y) < 8 and (e.tower.holder_template == this.swap_from or from_style and e.tower.terrain_style == from_style) then
			return e
		end
	end
	return nil
end
function S18.nightfall_dissolve.find_replace_from(this, store)
	for _, e in pairs(store.entities) do
		if e.template_name == this.replace_from and e.pos and V.dist(e.pos.x, e.pos.y, this.pos.x, this.pos.y) < 8 then
			return e
		end
	end
	return nil
end
function S18.nightfall_dissolve.do_swap(this, store, insert_fn)
	local tpl = E:get_template(this.swap_to)
	local swap_style = tpl and tpl.tower and tpl.tower.terrain_style
	local best = S18.nightfall_dissolve.find_swap_from(this, store)
	if best then
		local h = E:create_entity(this.swap_to)
		h.pos = V.vclone(best.pos)
		if h.tower and best.tower then
			h.tower.default_rally_pos = best.tower.default_rally_pos
			h.tower.holder_id = best.tower.holder_id
		end
		if h.ui and best.ui then
			h.ui.nav_mesh_id = best.ui.nav_mesh_id
		end
		if insert_fn then
			insert_fn(h)
			for _, s in ipairs(best.render.sprites) do
				s.hidden = true
			end
		else
			queue_insert(store, h)
		end
		queue_remove(store, best)
	else
		local tw = S18.nightfall_dissolve.find_tower_over(this, store)
		if tw then
			tw.tower.holder_template = this.swap_to
			if swap_style then
				U.set_terrain_style(tw, swap_style)
			end
		elseif this.swap_from then
			log.warning("nightfall_dissolve: no encontré \"%s\" ni torre encima en (%s,%s)", tostring(this.swap_from), tostring(this.pos.x), tostring(this.pos.y))
		end
	end
end
function S18.nightfall_dissolve.update(this, store)
	if this._final_applied then
		return
	end
	local SH = require("klove.shader_db")
	local qrect = S18.nightfall_dissolve.quad_screen_rect
	local find_swap_from = S18.nightfall_dissolve.find_swap_from
	local find_tower_over = S18.nightfall_dissolve.find_tower_over
	local find_replace_from = S18.nightfall_dissolve.find_replace_from
	local function find_driver()
		if this.transition_id then
			return store.entities[this.transition_id]
		end
		local name = this.nightfall_name or "decal_stage_218_nightfall"
		for _, e in pairs(store.entities) do
			if e.template_name == name then
				return e
			end
		end
		return nil
	end
	local function full_cover_fire(driver_args, e)
		e = e or this
		local br = driver_args and (driver_args.mask_rect or driver_args.bg_rect)
		if not br or not br[3] or br[3] == 0 or not br[4] or br[4] == 0 then
			return 1
		end
		local bx, by, bw, bh = br[1], br[2], br[3], br[4]
		local amp = driver_args.noise_amp or 0
		local max_fire = 0
		for _, s in ipairs(e.render.sprites) do
			if not s.hidden and (e ~= this or s.shader) then
				local qx, qy, qw, qh = qrect(e.pos, s)
				if qx then
					for _, c in ipairs({{qx, qy}, {qx + qw, qy}, {qx, qy + qh}, {qx + qw, qy + qh}}) do
						local bluvx = (c[1] - bx) / bw
						local bluvy = (c[2] - by) / bh
						local prog
						if driver_args.origin and driver_args.dist_scale then
							local dx = (bluvx - driver_args.origin[1]) * driver_args.dist_scale[1]
							local dy = (bluvy - driver_args.origin[2]) * driver_args.dist_scale[2]
							prog = math.sqrt(dx * dx + dy * dy)
						else
							local dir = driver_args.dir or {0, 1}
							local dl = math.sqrt(dir[1] * dir[1] + dir[2] * dir[2])
							if dl == 0 then
								dl = 1
							end
							prog = (bluvx - 0.5) * dir[1] / dl + (bluvy - 0.5) * dir[2] / dl + 0.5
						end
						local fire = (prog + amp) / (1 + amp)
						if max_fire < fire then
							max_fire = fire
						end
					end
				end
			end
		end
		if max_fire <= 0 then
			return 1
		end
		return math.min(max_fire, 1)
	end
	local function share_driver(driver, sid)
		local ns = driver.render.sprites[sid]
		local na = ns and ns.shader_args
		if not na then
			return nil
		end
		for _, s in ipairs(this.render.sprites) do
			if s.shader and not s.hidden then
				s.shader_args = na
				if ns.shader then
					s.shader = ns.shader
				end
			end
		end
		return na
	end
	local tpl = this.swap_to and E:get_template(this.swap_to)
	local swap_style = tpl and tpl.tower and tpl.tower.terrain_style
	local sid = this.transition_sid or 1
	local function config_holder()
		for i = 1, #this.render.sprites do
			local ts = tpl.render.sprites[i]
			local s = this.render.sprites[i]
			if ts then
				s.name = ts.name
				s.offset = V.v(ts.offset.x, ts.offset.y)
				s.z = ts.z
				s.flip_x = ts.flip_x
				s.hidden = ts.hidden
				s.sort_y_offset = (ts.sort_y_offset or 0) - 0.1
			else
				s.hidden = true
				s.shader_args = nil
				s._shader = nil
			end
		end
	end
	local function config_tower(tw)
		local twt = E:get_template(tw.template_name)
		local pt = twt and twt.render and twt.render.sprites[1] and twt.render.sprites[1].name
		local live = tw.render and tw.render.sprites[1]
		if not swap_style or not live or type(pt) ~= "string" or not string.find(pt, "%%") then
			return false
		end
		local s = this.render.sprites[1]
		s.name = TERRAIN_STYLE_SPRITE_DICT[swap_style]
		s.offset = V.v(live.offset.x, live.offset.y)
		s.z = live.z
		s.flip_x = live.flip_x
		s.hidden = false
		s.sort_y_offset = (live.sort_y_offset or 0) - 0.1
		for i = 2, #this.render.sprites do
			this.render.sprites[i].hidden = true
		end
		return true
	end
	local function config_none()
		for _, s in ipairs(this.render.sprites) do
			if s.shader then
				s.hidden = true
			end
		end
	end
	if tpl then
		config_holder()
	else
		for _, s in ipairs(this.render.sprites) do
			if s.shader then
				s.sort_y_offset = (s.sort_y_offset or 0) - 0.1
			end
		end
	end
	coroutine.yield()
	local fire, driver, driver_args, replaced, replaced_args
	local hide_target = this.hide_from and find_replace_from({
		replace_from = this.hide_from,
		pos = this.pos
	}, store) or nil
	local hide_args
	if hide_target then
		hide_args = {
			invert = 1
		}
		local tsh = this.transition_shader or "p_dissolve_reveal"
		local hsh = SH:clone(tsh, tsh .. "#invert:" .. this.id)
		U.entity_insert_shader(hide_target, hsh, hide_args, "nightfall_hide")
	end
	local cut_args, cut_sh, cut_target
	if this.swap_from then
		cut_args = {
			invert = 1
		}
		local tsh = this.transition_shader or "p_dissolve_reveal"
		cut_sh = SH:clone(tsh, tsh .. "#swapcut:" .. this.id)
	end
	local function unwire_swap_cut()
		if cut_target and store.entities[cut_target.id] then
			U.entity_remove_shader(cut_target, "nightfall_cut")
			for _, s in ipairs(cut_target.render.sprites) do
				if s._shader == cut_sh then
					s._shader = nil
					s.shader_args = nil
				end
			end
		end
		cut_target = nil
	end
	local function wire_swap_cut(target, only)
		if cut_target == target then
			return
		end
		unwire_swap_cut()
		if not target then
			return
		end
		cut_target = target
		if only then
			for i, s in ipairs(target.render.sprites) do
				if not s.hidden and only[i] then
					s._shader = cut_sh
					s.shader_args = cut_args
				end
			end
		else
			U.entity_insert_shader(target, cut_sh, cut_args, "nightfall_cut")
		end
	end
	local function tower_terrain_indices(tw)
		local twt = E:get_template(tw.template_name)
		local only, any = {}, false
		for i = 1, 2 do
			local ts = twt and twt.render and twt.render.sprites[i]
			if ts and type(ts.name) == "string" and string.find(ts.name, "%%") then
				only[i] = true
				any = true
			end
		end
		return any and only or nil
	end
	local function visual_fire()
		local f = full_cover_fire(driver_args)
		if hide_target and store.entities[hide_target.id] then
			f = math.max(f, full_cover_fire(driver_args, hide_target))
		end
		return math.min(1, f + ((driver_args.edge_width or 0) + (driver_args.edge_softness or 0)) / (1 + (driver_args.noise_amp or 0)))
	end
	local function resync()
		driver = find_driver()
		driver_args = driver and share_driver(driver, sid) or nil
		if tpl then
			fire = driver_args and full_cover_fire(driver_args) or nil
			if fire and cut_target and store.entities[cut_target.id] then
				fire = math.max(fire, full_cover_fire(driver_args, cut_target))
			end
		elseif this.replace_from then
			fire = 1
		else
			fire = driver_args and visual_fire() or nil
		end
	end
	if cut_args then
		wire_swap_cut(find_swap_from(this, store))
	end
	resync()
	if this.replace_from then
		replaced = find_replace_from(this, store)
		if replaced then
			replaced_args = {
				invert = 1
			}
			local rsh = SH:clone("p_corrupt_reveal", "p_corrupt_reveal#replace:" .. this.id)
			U.entity_insert_shader(replaced, rsh, replaced_args, "nightfall_replace")
		end
	end
	local mode_key = "holder"
	while true do
		if tpl and this.swap_from and (not this._next_mode_check or store.tick_ts >= this._next_mode_check) then
			this._next_mode_check = store.tick_ts + 0.25
			local holder = find_swap_from(this, store)
			local tw = not holder and find_tower_over(this, store) or nil
			local key = holder and "holder" or tw and "tower:" .. tw.id or "none"
			if holder then
				wire_swap_cut(holder)
			elseif tw then
				local only = tower_terrain_indices(tw)
				if only then
					wire_swap_cut(tw, only)
				else
					unwire_swap_cut()
				end
			else
				unwire_swap_cut()
			end
			if key ~= mode_key then
				mode_key = key
				if holder then
					config_holder()
				elseif not tw or not config_tower(tw) then
					config_none()
				end
				resync()
			end
		end
		if not driver or not store.entities[driver.id] then
			driver = find_driver()
			driver_args = driver and share_driver(driver, sid) or nil
		end
		if driver_args and (driver_args.mask_rect or driver_args.bg_rect) then
			if tpl then
				fire = full_cover_fire(driver_args)
				if cut_target and store.entities[cut_target.id] then
					fire = math.max(fire, full_cover_fire(driver_args, cut_target))
				end
			elseif not this.replace_from then
				fire = visual_fire()
			end
		end
		if replaced_args and driver_args then
			for k, v in pairs(driver_args) do
				if k ~= "invert" then
					replaced_args[k] = v
				end
			end
			replaced_args.invert = 1
		end
		if hide_args and driver_args then
			for k, v in pairs(driver_args) do
				if k ~= "invert" then
					hide_args[k] = v
				end
			end
			hide_args.invert = 1
		end
		if cut_args and driver_args then
			for k, v in pairs(driver_args) do
				if k ~= "invert" then
					cut_args[k] = v
				end
			end
			cut_args.invert = 1
		end
		local th = driver_args and driver_args.threshold or 0
		if fire and fire <= th then
			break
		end
		coroutine.yield()
	end
	local function strip(e)
		if not e or not e.render or not e.render.sprites then
			return
		end
		e.render._runtime_shaders = nil
		for _, efr in ipairs(e.render.sprites) do
			efr.shader = nil
			efr.shader_args = nil
			efr._shader = nil
		end
	end
	strip(this)
	if this.replace_from then
		if replaced and store.entities[replaced.id] then
			for _, s in ipairs(replaced.render.sprites) do
				s.hidden = true
			end
			strip(replaced)
			queue_remove(store, replaced)
		elseif not replaced then
			log.warning("nightfall_dissolve: no encontré \"%s\" en (%s,%s)", tostring(this.replace_from), tostring(this.pos.x), tostring(this.pos.y))
		end
		return
	end
	if not tpl then
		if this.hide_from then
			if hide_target and store.entities[hide_target.id] then
				for _, s in ipairs(hide_target.render.sprites) do
					s.hidden = true
				end
				strip(hide_target)
			else
				log.warning("nightfall_dissolve: no encontré \"%s\" en (%s,%s)", tostring(this.hide_from), tostring(this.pos.x), tostring(this.pos.y))
			end
		end
		return
	end
	S18.nightfall_dissolve.do_swap(this, store)
	if cut_target and store.entities[cut_target.id] and not cut_target.pending_removal then
		unwire_swap_cut()
	end
	if this.swap_to then
		queue_remove(store, this)
	end
end
S18.decal_stage_218_spawner = {}
function S18.decal_stage_218_spawner.on_nightfall(this, store)
	this.render.sprites[1].name = "stage218_1_spawner_noche"
end
S18.stage_218_nightfall = {}
function S18.stage_218_nightfall.set_day_bg_hidden(this, store, hidden)
	for _, e in pairs(store.entities) do
		if e.template_name == "decal_background" and e.render then
			for _, s in ipairs(e.render.sprites) do
				s.hidden = hidden
			end
		end
	end
end
function S18.stage_218_nightfall.apply_final(this, store)
	local function insert_now(e)
		for _, sys in ipairs(simulation.systems_on_queue_unconditional) do
			sys:on_queue_unconditional(e, store)
		end
		simulation:insert_entity(e)
	end
	if this._final_applied then
		return
	end
	this._final_applied = true
	local direct_swaps = not this._swap_spawned
	this._swap_spawned = true
	this.triggered = false
	this.skip_anim = false
	this.render.sprites[1].hidden = false
	for _, s in ipairs(this.render.sprites) do
		s.shader = nil
		s.shader_args = nil
		s._shader = nil
	end
	S18.stage_218_nightfall.set_day_bg_hidden(this, store, true)
	for _, e in pairs(store.entities) do
		if e.template_name == "decal_nightfall_overlay" and not e.swap_to and not e.replace_from and (e.nightfall_name or "decal_stage_218_nightfall") == this.template_name then
			e._final_applied = true
			for _, s in ipairs(e.render.sprites) do
				s.hidden = false
				s.shader = nil
				s.shader_args = nil
				s._shader = nil
			end
			if e.hide_from then
				local day = S18.nightfall_dissolve.find_replace_from({
					replace_from = e.hide_from,
					pos = e.pos
				}, store)
				if day then
					for _, s in ipairs(day.render.sprites) do
						s.hidden = true
					end
				end
			end
		end
	end
	if direct_swaps then
		for _, pair in ipairs(this.swap_list or {}) do
			for _, t in ipairs(find_all_t(store, pair.from)) do
				S18.nightfall_dissolve.do_swap({
					swap_from = pair.from,
					swap_to = pair.to,
					pos = t.pos
				}, store, insert_now)
			end
			local from_tpl = E:get_template(pair.from)
			local from_style = from_tpl and from_tpl.tower and from_tpl.tower.terrain_style
			if from_style then
				for _, tw in ipairs(store.towers or {}) do
					if tw.tower.terrain_style == from_style then
						S18.nightfall_dissolve.do_swap({
							swap_from = pair.from,
							swap_to = pair.to,
							pos = tw.pos,
							holder_id = tw.tower.holder_id
						}, store, insert_now)
					end
				end
			end
		end
	end
end
function S18.stage_218_nightfall.update(this, store)
	if this._final_applied then
		return
	end
	local SH = require("klove.shader_db")
	local args = this.render.sprites[1].shader_args
	local refresh_view_args = S18.nightfall_dissolve.refresh_view_args
	local front_noise = S18.nightfall_dissolve.front_noise
	coroutine.yield()
	local fr = this.render.sprites and this.render.sprites[1]
	local bx, by, bw, bh = S18.nightfall_dissolve.quad_screen_rect(this.pos, this.render.sprites[1])
	if bx then
		args.bg_rect = {bx, by, bw, bh}
	end
	args.view_off = args.view_off or {0, 0}
	args.view_scale = args.view_scale or 1
	local cuts = {}
	local function refresh_cuts()
		for _, c in ipairs(cuts) do
			for k, v in pairs(args) do
				if k ~= "invert" then
					c.args[k] = v
				end
			end
			c.args.invert = 1
		end
	end
	local function refresh_view()
		refresh_view_args(args, store)
		refresh_cuts()
	end
	local function wire_cuts()
		for _, name in ipairs(this.cut_list or {}) do
			local sh = SH:clone("p_dissolve_reveal", "p_dissolve_reveal#invert:" .. name)
			for _, e in ipairs(find_all_t(store, name)) do
				local cargs = {
					invert = 1
				}
				local key = "nightfall_cut:" .. name
				U.entity_insert_shader(e, sh, cargs, key)
				cuts[#cuts + 1] = {
					id = e.id,
					args = cargs,
					key = key
				}
			end
		end
		refresh_cuts()
	end
	local function strip_cuts()
		for _, c in ipairs(cuts) do
			local e = store.entities[c.id]
			if e and e.render then
				if c.key then
					U.entity_remove_shader(e, c.key)
				end
				for _, s in ipairs(e.render.sprites) do
					s.hidden = true
				end
			end
		end
		cuts = {}
	end
	local function resolve_targets()
		local out = {}
		local list = this.notify_list
		if not list or #list == 0 then
			return out
		end
		local br = args.bg_rect
		if not br or not br[3] or br[3] == 0 or not br[4] or br[4] == 0 then
			return out
		end
		local bx, by, bw, bh = br[1], br[2], br[3], br[4]
		local amp = args.noise_amp or 0
		local nscale = args.noise_scale or 6
		local dir = args.dir or {0, 1}
		local dl = math.sqrt(dir[1] * dir[1] + dir[2] * dir[2])
		if dl == 0 then
			dl = 1
		end
		local dnx, dny = dir[1] / dl, dir[2] / dl
		for _, item in ipairs(list) do
			local best, bestd
			for _, e in pairs(store.entities) do
				if e.pos and (not item.name or e.template_name == item.name) then
					local d = V.dist(e.pos.x, e.pos.y, item.x, item.y)
					if not bestd or d < bestd then
						best, bestd = e, d
					end
				end
			end
			if best then
				local bluvx = (item.x - bx) / bw
				local bluvy = (REF_H - item.y - by) / bh
				local prog = (bluvx - 0.5) * dnx + (bluvy - 0.5) * dny + 0.5
				local n = front_noise(bluvx * nscale, bluvy * nscale)
				out[#out + 1] = {
					notified = false,
					id = best.id,
					fire = (prog + amp * (1 - n)) / (1 + amp)
				}
				if not best.on_nightfall then
					log.warning("stage_218_nightfall: \"%s\" en (%s,%s) no tiene on_nightfall", tostring(item.name), tostring(item.x), tostring(item.y))
				end
			else
				log.warning("stage_218_nightfall: no encontré \"%s\" cerca de (%s,%s)", tostring(item.name), tostring(item.x), tostring(item.y))
			end
		end
		table.sort(out, function(a, b)
			return a.fire < b.fire
		end)
		return out
	end
	refresh_view()
	local front_fx_total = 0
	for _, it in ipairs(this.front_fx or {}) do
		front_fx_total = front_fx_total + (it.weight or 1)
	end
	local function pick_front_fx()
		local r = math.random() * front_fx_total
		for _, it in ipairs(this.front_fx) do
			r = r - (it.weight or 1)
			if r <= 0 then
				return it.fx
			end
		end
		return this.front_fx[#this.front_fx].fx
	end
	local function emit_front_fx(threshold, count)
		local br = args.bg_rect
		if not br or front_fx_total <= 0 then
			return
		end
		local amp = args.noise_amp or 0
		local nscale = args.noise_scale or 6
		local band = this.front_fx_band or 0
		local lead = this.front_fx_lead or 0
		local smin = this.front_fx_scale_min or 1
		local smax = this.front_fx_scale_max or 1
		local dir = args.dir or {0, 1}
		local dl = math.sqrt(dir[1] * dir[1] + dir[2] * dir[2])
		if dl == 0 then
			dl = 1
		end
		local dnx, dny = dir[1] / dl, dir[2] / dl
		for _ = 1, count do
			local s = math.random() - 0.5
			local p = threshold
			local luvx, luvy
			for _ = 1, 2 do
				luvx = 0.5 - dny * s + dnx * (p - 0.5)
				luvy = 0.5 + dnx * s + dny * (p - 0.5)
				local n = front_noise(luvx * nscale, luvy * nscale)
				p = threshold * (1 + amp) - amp * (1 - n)
			end
			p = p + lead + (math.random() * 2 - 1) * band
			luvx = 0.5 - dny * s + dnx * (p - 0.5)
			luvy = 0.5 + dnx * s + dny * (p - 0.5)
			if luvx >= 0 and luvx <= 1 and luvy >= 0 and luvy <= 1 then
				local fx = E:create_entity(pick_front_fx())
				fx.pos.x = br[1] + luvx * br[3]
				fx.pos.y = REF_H - (br[2] + luvy * br[4])
				local fs = fx.render.sprites[1]
				fs.flip_x = this.front_fx_flip and math.random() < 0.5
				fs.scale = V.vv(U.frandom(smin, smax))
				fs.ts = store.tick_ts
				queue_insert(store, fx)
			end
		end
	end
	if this.swap_list and not this._swap_spawned then
		this._swap_spawned = true
		local function spawn_swap_overlay(pair, pos)
			local o = E:create_entity("decal_nightfall_overlay")
			o.pos = V.vclone(pos)
			o.swap_from = pair.from
			o.swap_to = pair.to
			o.nightfall_name = this.template_name
			queue_insert(store, o)
		end
		for _, pair in ipairs(this.swap_list) do
			for _, t in ipairs(find_all_t(store, pair.from)) do
				spawn_swap_overlay(pair, t.pos)
			end
			local from_tpl = E:get_template(pair.from)
			local from_style = from_tpl and from_tpl.tower and from_tpl.tower.terrain_style
			if from_style then
				for _, tw in ipairs(store.towers or {}) do
					if tw.tower.terrain_style == from_style then
						S18.nightfall_dissolve.do_swap({
							swap_from = pair.from,
							swap_to = pair.to,
							pos = tw.pos,
							holder_id = tw.tower.holder_id
						}, store)
					end
				end
			end
		end
	end
	while true do
		args.threshold = 0
		while not this.triggered do
			refresh_view()
			coroutine.yield()
		end
		this.triggered = false
		if fr then
			U.entity_insert_shader(this, SH:get("p_dissolve_reveal"), args, "nightfall_self")
		end
		this.render.sprites[1].hidden = false
		S18.stage_218_nightfall.set_day_bg_hidden(this, store, false)
		wire_cuts()
		local targets = resolve_targets()
		local function notify(phase)
			for _, t in ipairs(targets) do
				if phase < t.fire then
					break
				end
				if not t.notified then
					t.notified = true
					local e = store.entities[t.id]
					if e and e.on_nightfall then
						e.on_nightfall(e, store)
					end
				end
			end
		end
		if this.skip_anim then
			this.skip_anim = false
			args.threshold = 1
			refresh_view()
			notify(1)
		else
			local ffx_rate = this.front_fx_rate or 0
			this._ffx_accum = 0
			this._ffx_last_dt = 0
			U.y_ease_key(store, args, "threshold", 0, 1, this.reveal_time, this.reveal_ease, function(dt, phase)
				refresh_view()
				notify(phase)
				if ffx_rate > 0 then
					local delta = dt - this._ffx_last_dt
					this._ffx_last_dt = dt
					this._ffx_accum = this._ffx_accum + ffx_rate * delta
					local n = math.floor(this._ffx_accum)
					if n > 0 then
						this._ffx_accum = this._ffx_accum - n
						emit_front_fx(args.threshold, n)
					end
				end
			end)
			args.threshold = 1
			refresh_view()
			notify(1)
		end
		if fr then
			fr.shader = nil
			fr.shader_args = nil
			fr._shader = nil
		end
		strip_cuts()
		S18.stage_218_nightfall.set_day_bg_hidden(this, store, true)
		while not this.triggered do
			refresh_view()
			coroutine.yield()
		end
	end
end
S18.decal_stage_218_portal = {}
local function y_portal_apply_want(this, store)
	if this._want and this._want ~= this._state then
		this._state = this._want
		local sound = not this._mute_sfx and (this._state == "open" and this.sound_open or this.sound_close)
		this._mute_sfx = nil
		if sound then
			S:queue(sound)
		end
		if this._state == "open" then
			U.y_animation_play(this, "on_in", nil, store.tick_ts, 1, 1)
			U.animation_start(this, "on_loop", nil, store.tick_ts, true, 1, true)
		else
			U.y_animation_play(this, "off_in", nil, store.tick_ts, 1, 1)
			U.animation_start(this, "off_idle", nil, store.tick_ts, true, 1, true)
		end
	end
end
function S18.decal_stage_218_portal.on_event(this, store, event_name, portal, action)
	if tonumber(portal) ~= this.portal_idx then
		return
	end
	if action ~= "open" and action ~= "close" then
		log.error("stage_218_portal: action invalida %s (portal %s)", action, portal)
		return
	end
	this._want = action
end
function S18.decal_stage_218_portal.fire(store, portal, action)
	local handlers = store.event_handlers and store.event_handlers.stage_218_portal
	if not handlers then
		return
	end
	for _, ev in pairs(handlers) do
		ev.on_event(store.entities[ev.entity_id], store, ev.name, portal, action)
	end
end
function S18.decal_stage_218_portal.update(this, store)
	this._state = "close"
	while true do
		y_portal_apply_want(this, store)
		coroutine.yield()
	end
end
function S18.decal_stage_218_portal.update_auto(this, store)
	this._state = "close"
	local tunnels = {}
	local empty_ts
	while true do
		if #tunnels == 0 then
			for _, e in pairs(store.entities) do
				if e.tunnel then
					for _, pi in ipairs(this.tunnel_place_pis or {}) do
						if e.tunnel.place_pi == pi then
							tunnels[#tunnels + 1] = e
							break
						end
					end
				end
			end
		end
		local occupied = false
		for _, tu in ipairs(tunnels) do
			if tu.tunnel.picked_enemies and #tu.tunnel.picked_enemies > 0 then
				occupied = true
				break
			end
		end
		if this._force_open then
			empty_ts = nil
			this._want = "open"
		elseif occupied then
			empty_ts = nil
			this._want = "open"
		else
			empty_ts = empty_ts or store.tick_ts
			if store.tick_ts - empty_ts >= this.close_delay then
				this._want = "close"
			end
		end
		y_portal_apply_want(this, store)
		coroutine.yield()
	end
end
S18.decal_stage_218_puerta = {}
function S18.decal_stage_218_puerta.on_event(this, store, event_name, action)
	if action ~= "open" and action ~= "close" then
		log.error("stage_218_puerta: action invalida %s", action)
		return
	end
	this._want = action
end
function S18.decal_stage_218_puerta.fire(store, action)
	local handlers = store.event_handlers and store.event_handlers.stage_218_puerta
	if not handlers then
		return
	end
	for _, ev in pairs(handlers) do
		ev.on_event(store.entities[ev.entity_id], store, ev.name, action)
	end
end
function S18.decal_stage_218_puerta.on_nightfall(this, store)
	this.render.sprites[1].prefix = "animations_puerta_st_218_terreno_2Def"
	local anim = this._state == "open" and "open_idle" or "closed_idle"
	U.animation_start(this, anim, nil, store.tick_ts, true, 1, true)
end
function S18.decal_stage_218_puerta.update(this, store)
	this._state = "close"
	while true do
		if this._want and this._want ~= this._state then
			this._state = this._want
			if this._state == "open" then
				if this.sound_open then
					S:queue(this.sound_open, {
						delay = fts(this.sound_open_frame)
					})
				end
				U.y_animation_play(this, "open_in", nil, store.tick_ts, 1, 1)
				U.animation_start(this, "open_idle", nil, store.tick_ts, true, 1, true)
			else
				if this.sound_close then
					S:queue(this.sound_close, {
						delay = fts(this.sound_close_frame)
					})
				end
				U.y_animation_play(this, "open_out", nil, store.tick_ts, 1, 1)
				U.animation_start(this, "closed_idle", nil, store.tick_ts, true, 1, true)
			end
		end
		coroutine.yield()
	end
end
S18.bullet_stage_218_veznan_bolt = {}
function S18.bullet_stage_218_veznan_bolt.insert(this, store, script)
	local b = this.bullet
	if b.target_id then
		local target = store.entities[b.target_id]
		if not target or band(target.vis.bans, F_RANGED) ~= 0 then
			if this.keep_on_target_loss then
				b.target_id = nil
			else
				return false
			end
		end
	end
	b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)
	local s = this.render.sprites[1]
	if not b.ignore_rotation then
		s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
	end
	return true
end
function S18.bullet_stage_218_veznan_bolt.update(this, store)
	local b = this.bullet
	local fm = this.force_motion
	local target = store.entities[b.target_id]
	local ps
	local function move_step(dest)
		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)
		if this.straight_flight then
			fm.v.x, fm.v.y = V.mul(fm.max_v, V.normalize(dx, dy))
			this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
			return dist <= fm.max_v * store.tick_length
		end
		local nx, ny = V.mul(fm.max_v, V.normalize(dx, dy))
		local stx, sty = V.sub(nx, ny, fm.v.x, fm.v.y)
		if dist <= 4 * fm.max_v * store.tick_length then
			stx, sty = V.mul(fm.max_a, V.normalize(stx, sty))
		end
		fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step, stx, sty)))
		fm.v.x, fm.v.y = V.trim(fm.max_v, V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y)))
		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
		fm.a.x, fm.a.y = 0, 0
		return dist <= fm.max_v * store.tick_length
	end
	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.emit = true
		ps.particle_system.track_id = this.id
		queue_insert(store, ps)
	end
	local iix, iiy = V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y)
	local last_pos = V.vclone(this.pos)
	local target_is_flying = false
	b.ts = store.tick_ts
	while true do
		target = store.entities[b.target_id]
		if target and target.health and not target.health.dead and band(target.vis.bans, F_RANGED) == 0 then
			local hit_offset = V.v(0, 0)
			target_is_flying = band(target.vis.flags, F_FLYING) ~= 0
			if not b.ignore_hit_offset or target_is_flying then
				hit_offset.x = target.unit.hit_offset.x
				hit_offset.y = target.unit.hit_offset.y
			end
			local d = math.max(math.abs(target.pos.x + hit_offset.x - b.to.x), math.abs(target.pos.y + hit_offset.y - b.to.y))
			if d > b.max_track_distance then
				target = nil
				b.target_id = nil
			else
				b.to.x, b.to.y = target.pos.x + hit_offset.x, target.pos.y + hit_offset.y
			end
		end
		if this.initial_impulse and store.tick_ts - b.ts < this.initial_impulse_duration then
			local t = store.tick_ts - b.ts
			local angle = this.initial_impulse_angle
			if this.initial_impulse_side then
				angle = angle * this.initial_impulse_side
			elseif iix < 0 then
				angle = angle * -1
			end
			fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(angle, iix, iiy))
			fm.v.x, fm.v.y = V.trim(fm.max_v, V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y)))
			this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
		else
			last_pos.x, last_pos.y = this.pos.x, this.pos.y
			if move_step(b.to) then
				break
			end
		end
		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - last_pos.x, this.pos.y - last_pos.y)
		end
		coroutine.yield()
	end
	if target and not target.health.dead then
		local d = SU.create_bullet_damage(b, target.id, this.id)
		queue_damage(store, d)
	end
	this.render.sprites[1].hidden = true
	local hit_fx = target_is_flying and b.hit_fx_air or b.hit_fx
	if hit_fx then
		local fx = E:create_entity(hit_fx)
		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].runs = 0
		queue_insert(store, fx)
	end
	if this.hit_sfx then
		S:queue(this.hit_sfx)
	end
	if ps and ps.particle_system.emit then
		ps.particle_system.emit = false
		U.y_wait(store, ps.particle_system.particle_lifetime[2])
	end
	queue_remove(store, this)
end
S18.bullet_stage_218_veznan_soul = {}
function S18.bullet_stage_218_veznan_soul.insert(this, store, script)
	local b = this.bullet
	b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)
	U.animation_start(this, "in", nil, store.tick_ts, false)
	return true
end
function S18.bullet_stage_218_veznan_soul.update(this, store, script)
	local b = this.bullet
	local ts = store.tick_ts
	while store.tick_ts - ts < (this.soul_in_time or 0) do
		b.speed.x, b.speed.y = V.mul(b.min_speed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
		end
		coroutine.yield()
	end
	U.animation_start(this, "flying", nil, store.tick_ts, true)
	scripts.bolt_enemy.update(this, store, script)
	if this.arrive_fx then
		local fx = E:create_entity(this.arrive_fx)
		fx.pos = V.vclone(this.pos)
		fx.render.sprites[1].ts = store.tick_ts
		queue_insert(store, fx)
	end
	if this.arrive_pump_fx then
		local src = store.entities[this.bullet.source_id]
		local pfx = E:create_entity(this.arrive_pump_fx)
		pfx.pos = V.vclone(src and src.pos or this.pos)
		pfx.render.sprites[1].ts = store.tick_ts
		queue_insert(store, pfx)
	end
end
S18.bullet_stage_218_veznan_soul_reveal = {}
function S18.bullet_stage_218_veznan_soul_reveal.update(this, store, script)
	local b = this.bullet
	local flight_time = V.dist(b.from.x, b.from.y, b.to.x, b.to.y) / b.min_speed
	local mx, my = (b.from.x + b.to.x) / 2, (b.from.y + b.to.y) / 2
	local nx, ny = V.normalize(b.from.y - b.to.y, b.to.x - b.from.x)
	local curve = U.frandom(this.curve_offset[1], this.curve_offset[2]) * (math.random(2) == 1 and 1 or -1)
	local cx, cy = mx + nx * curve, my + ny * curve
	local ts = store.tick_ts
	local flying, ps
	while true do
		local elapsed = store.tick_ts - ts
		local s = math.min(1, elapsed / flight_time)
		local oms = 1 - s
		this.pos.x = oms * oms * b.from.x + 2 * s * oms * cx + s * s * b.to.x
		this.pos.y = oms * oms * b.from.y + 2 * s * oms * cy + s * s * b.to.y
		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(2 * oms * (cx - b.from.x) + 2 * s * (b.to.x - cx), 2 * oms * (cy - b.from.y) + 2 * s * (b.to.y - cy))
		end
		if ps then
			ps.particle_system.emit_direction = this.render.sprites[1].r
		end
		if not flying and elapsed >= (this.soul_in_time or 0) then
			flying = true
			U.animation_start(this, "flying", nil, store.tick_ts, true)
			if b.particles_name then
				ps = E:create_entity(b.particles_name)
				ps.particle_system.track_id = this.id
				queue_insert(store, ps)
			end
		end
		if s >= 1 then
			break
		end
		coroutine.yield()
	end
	local src = store.entities[this.bullet.source_id]
	if this.arrive_fx then
		local fx = E:create_entity(this.arrive_fx)
		fx.pos = V.vclone(this.pos)
		fx.render.sprites[1].ts = store.tick_ts
		queue_insert(store, fx)
	end
	if this.arrive_pump_fx then
		local pfx = E:create_entity(this.arrive_pump_fx)
		pfx.pos = V.vclone(src and src.pos or this.pos)
		pfx.render.sprites[1].ts = store.tick_ts
		queue_insert(store, pfx)
	end
	if src and this.reveal_heal and this.reveal_heal > 0 then
		src.health.hp = km.clamp(0, src.health.hp_max, src.health.hp + this.reveal_heal)
	end
	queue_remove(store, this)
end
S18.controller_stage_218_veznan = {}
function S18.controller_stage_218_veznan.on_disable_towers(this, store, event_name, count, holder_group, duration)
	this._queue = this._queue or {}
	table.insert(this._queue, {
		skill = "disable_towers",
		count = tonumber(count) or this.disable_default_count,
		holder_group = holder_group ~= nil and holder_group ~= "" and tostring(holder_group) or this.disable_default_group,
		duration = tonumber(duration)
	})
end
function S18.controller_stage_218_veznan.on_summon_demons(this, store, event_name, path, group)
	this._queue = this._queue or {}
	local g = tonumber(group) or this.summon_default_group
	if not this.summon_groups[g] then
		g = this.summon_default_group
	end
	table.insert(this._queue, {
		skill = "summon_demons",
		path = tonumber(path) or this.summon_default_path,
		group = g
	})
end
function S18.controller_stage_218_veznan.on_bolts_off(this, store, event_name)
	this._bolts_off = true
	if this._queue then
		for i = #this._queue, 1, -1 do
			if this._queue[i].skill == "gem_blast" then
				table.remove(this._queue, i)
			end
		end
	end
end
function S18.controller_stage_218_veznan.on_explode_statue(this, store, event_name, x, y)
	this._queue = this._queue or {}
	table.insert(this._queue, {
		skill = "explode_statue",
		x = tonumber(x),
		y = tonumber(y)
	})
end
function S18.controller_stage_218_veznan.update(this, store, script)
	this._queue = this._queue or {}
	local body, sigil_pi, sigil_ni
	local function body_idle()
		if body then
			U.animation_start(body, "idle", nil, store.tick_ts, true)
		end
	end
	local function y_body_cast(sound, animation, time)
		S:queue(sound)
		if body then
			U.animation_start(body, animation, nil, store.tick_ts, false)
		end
		U.y_wait(store, time or this.cast_time)
	end
	local function y_body_recover()
		if body then
			U.y_animation_wait(body)
			U.animation_start(body, "idle", nil, store.tick_ts, true, nil, true)
		end
	end
	local function y_cast_gem_blast()
		local gb = this.gem_blast
		local targets = U.find_soldiers_in_range(store.entities, this.sigil_pos, 0, gb.radius, this.gem_blast_vis_flags, this.gem_blast_vis_bans)
		if not targets then
			return false
		end
		S:queue(this.gem_blast_sound)
		if body then
			U.animation_start(body, this.gem_blast_animation, nil, store.tick_ts, false)
		end
		local function muzzle_for(pos)
			local off = this.gem_blast_muzzle_offsets.center
			if pos.x < this.gem_blast_zone_left_x then
				off = this.gem_blast_muzzle_offsets.left
			elseif pos.x > this.gem_blast_zone_right_x then
				off = this.gem_blast_muzzle_offsets.right
			end
			return V.v(this.pos.x + off.x, this.pos.y + off.y)
		end
		targets = table.random_order(targets)
		local attacked = {}
		local last_pos = V.vclone(targets[1].pos)
		local last_hit_pos = V.vclone(last_pos)
		if targets[1].unit and targets[1].unit.hit_offset then
			last_hit_pos.x = last_hit_pos.x + targets[1].unit.hit_offset.x
			last_hit_pos.y = last_hit_pos.y + targets[1].unit.hit_offset.y
		end
		local prev_frame = 0
		for i, frame in ipairs(this.gem_blast_shot_frames) do
			U.y_wait(store, fts(frame - prev_frame))
			prev_frame = frame
			targets = U.find_soldiers_in_range(store.entities, this.sigil_pos, 0, gb.radius, this.gem_blast_vis_flags, this.gem_blast_vis_bans)
			local target
			if targets then
				targets = table.random_order(targets)
				target = targets[1]
				for _, t in ipairs(targets) do
					if not attacked[t.id] then
						target = t
						break
					end
				end
			end
			if target then
				attacked[target.id] = true
				last_pos = V.vclone(target.pos)
				last_hit_pos = V.vclone(last_pos)
				if target.unit and target.unit.hit_offset then
					last_hit_pos.x = last_hit_pos.x + target.unit.hit_offset.x
					last_hit_pos.y = last_hit_pos.y + target.unit.hit_offset.y
				end
			end
			local muzzle = muzzle_for(last_pos)
			if this.gem_blast_release_sound then
				S:queue(this.gem_blast_release_sound)
			end
			local bullet = E:create_entity(this.gem_blast_bullet_t)
			if this.gem_blast_curve_sides then
				bullet.initial_impulse_side = this.gem_blast_curve_sides[i]
			end
			bullet.pos = V.vclone(muzzle)
			bullet.bullet.from = V.vclone(muzzle)
			bullet.bullet.to = V.vclone(last_hit_pos)
			bullet.bullet.target_id = target and target.id
			bullet.keep_on_target_loss = true
			bullet.bullet.source_id = this.id
			if this.gem_blast_spawn_fx then
				local sfx = E:create_entity(this.gem_blast_spawn_fx)
				sfx.pos = V.vclone(muzzle)
				sfx.render.sprites[1].ts = store.tick_ts
				local sfx_angle = V.angleTo(bullet.bullet.to.x - muzzle.x, bullet.bullet.to.y - muzzle.y)
				if bullet.initial_impulse_side and bullet.initial_impulse_angle then
					sfx_angle = sfx_angle + bullet.initial_impulse_angle * bullet.initial_impulse_side
				end
				sfx.render.sprites[1].r = sfx_angle
				queue_insert(store, sfx)
			end
			queue_insert(store, bullet)
		end
		y_body_recover()
		return true
	end
	local function y_cast_disable_towers(cmd)
		local all = cmd.holder_group == "*"
		local groups = {}
		for g in string.gmatch(cmd.holder_group, "[^+]+") do
			groups[g] = true
		end
		local towers = table.filter(store.entities, function(k, v)
			return not v.pending_removal and v.tower and not v.tower.blocked and v.tower.type ~= "holder" and v.tower.type ~= "build_animation" and v.tower.can_be_mod and (all or v.tower.holder_id ~= nil and groups[tostring(v.tower.holder_id)]) and (not v.tower_holder or not v.tower_holder.blocked) and not U.has_modifier_types(store, v, MOD_TYPE_PROTECTION)
		end)
		if not towers or #towers == 0 then
			return false
		end
		y_body_cast(this.disable_cast_sound, this.disable_animation)
		towers = table.random_order(towers)
		for i = 1, math.min(cmd.count, #towers) do
			local m = E:create_entity(this.disable_mod_t)
			m.modifier.target_id = towers[i].id
			m.modifier.source_id = this.id
			if cmd.duration then
				m.modifier.duration = cmd.duration
			end
			queue_insert(store, m)
		end
		y_body_recover()
		return true
	end
	local function y_cast_summon(cmd)
		local circle = this._circle
		if this.summon_circle_t then
			if not circle or not store.entities[circle.id] then
				circle = E:create_entity(this.summon_circle_t)
				circle.pos = V.vclone(this.sigil_pos)
				circle.render.sprites[1].ts = store.tick_ts
				queue_insert(store, circle)
				this._circle = circle
			end
			circle._cast = true
		end
		y_body_cast(this.summon_cast_sound, this.summon_animation, fts(this.summon_shot_frame))
		local body_idle_restored = false
		local function y_wait_restore_idle(time)
			local ts = store.tick_ts
			while time > store.tick_ts - ts do
				if not body_idle_restored and body and U.animation_finished(body) then
					body_idle_restored = true
					U.animation_start(body, "idle", nil, store.tick_ts, true, nil, true)
				end
				coroutine.yield()
			end
		end
		local fx = E:create_entity(this.sigil_burst_fx)
		fx.pos = V.vclone(this.sigil_pos)
		fx.render.sprites[1].ts = store.tick_ts
		queue_insert(store, fx)
		local pi, ni = sigil_pi, sigil_ni
		local n = P:nearest_nodes(this.sigil_pos.x, this.sigil_pos.y, {cmd.path})[1]
		if n then
			pi, ni = n[1], n[3]
		else
			log.error("controller_stage_218_veznan: path %s sin nodos cerca del sigil, uso path %s", cmd.path, pi)
		end
		local ranged_holds = {}
		for _, row in ipairs(this.summon_groups[cmd.group]) do
			local subpath, delay, template = unpack(row)
			y_wait_restore_idle(math.max(0, delay - fts(5)))
			if this.summon_spawn_fx then
				local sfx = E:create_entity(this.summon_spawn_fx)
				sfx.pos = V.vclone(this.sigil_pos)
				sfx.render.sprites[1].ts = store.tick_ts
				queue_insert(store, sfx)
			end
			if this.summon_spawn_sound then
				S:queue(this.summon_spawn_sound)
			end
			y_wait_restore_idle(fts(5))
			if not U.is_seen(store, template) then
				signal.emit("wave-notification", "icon", template)
				U.mark_seen(store, template)
			end
			local e = E:create_entity(template)
			e.nav_path.pi = pi
			e.nav_path.spi = subpath
			e.nav_path.ni = ni
			e.pos.x, e.pos.y = this.sigil_pos.x, this.sigil_pos.y
			if this.summon_ranged_delay and e.ranged then
				for _, a in pairs(e.ranged.attacks) do
					a.ts = store.tick_ts + this.summon_ranged_delay - (a.cooldown or 0)
					if a.hold_advance then
						a.hold_advance = nil
						table.insert(ranged_holds, a)
					end
				end
			end
			queue_insert(store, e)
		end
		if circle then
			circle._out = true
		end
		if #ranged_holds > 0 then
			y_wait_restore_idle(this.summon_ranged_delay)
			for _, a in ipairs(ranged_holds) do
				a.hold_advance = true
			end
		end
		if not body_idle_restored then
			y_body_recover()
		end
	end
	local function y_cast_explode_statue(cmd)
		if not body or body.render.sprites[1].prefix ~= "veznan_fase2_balconDef" then
			log.error("controller_stage_218_veznan: veznan_explode_statue con exo %s (necesita veznan_fase2_balconDef), evento descartado", body and body.render.sprites[1].prefix or "nil")
			return false
		end
		S:queue(this.statue_cast_sound)
		U.animation_start(body, this.statue_animation, nil, store.tick_ts, false)
		U.y_wait(store, fts(this.statue_shot_frame))
		if this.statue_bolt_sound then
			S:queue(this.statue_bolt_sound)
		end
		local bullet = E:create_entity(this.statue_bullet_t)
		bullet.pos = V.v(this.pos.x + this.statue_muzzle_offset.x, this.pos.y + this.statue_muzzle_offset.y)
		bullet.bullet.from = V.vclone(bullet.pos)
		bullet.bullet.to = V.v(cmd.x or this.statue_target_pos.x, cmd.y or this.statue_target_pos.y)
		bullet.bullet.source_id = this.id
		queue_insert(store, bullet)
		y_body_recover()
		return true
	end
	local taunt_history = {}
	local function y_play_random_taunt()
		local sprite = body.render.sprites[1]
		local pool = this.taunt_animations[sprite.prefix]
		if not pool then
			return
		end
		local hist = taunt_history[sprite.prefix]
		if not hist then
			hist = {}
			taunt_history[sprite.prefix] = hist
		end
		local name = pool[get_random_round_robin(hist, #pool)]
		local ts = store.tick_ts
		U.animation_start(body, name, nil, ts, false)
		while sprite.name == name and sprite.ts == ts do
			if U.animation_finished(body) then
				U.animation_start(body, "idle", nil, store.tick_ts, true, nil, true)
				return
			end
			coroutine.yield()
		end
	end
	U.y_wait(store, 1e+99, function()
		return store.wave_group_number > 0
	end)
	body = find_all_t(store, this.body_decal_t)[1]
	body_idle()
	local nodes = P:nearest_nodes(this.sigil_pos.x, this.sigil_pos.y)
	if #nodes < 1 then
		log.error("controller_stage_218_veznan: no path nodes near sigil %s,%s", this.sigil_pos.x, this.sigil_pos.y)
		queue_remove(store, this)
		return
	end
	sigil_pi, sigil_spi, sigil_ni = unpack(nodes[1])
	local gem_ts = store.tick_ts
	local taunt_ts = store.tick_ts
	local taunt_wait = U.frandom(this.taunt_cooldown_min, this.taunt_cooldown_max)
	while true do
		if store.level_mode == GAME_MODE_CAMPAIGN or store.level_mode == GAME_MODE_HEROIC then
			if not this._bolts_off and store.wave_group_number >= this.gem_blast.start_wave and store.tick_ts - gem_ts >= this.gem_blast.cooldown and #this._queue == 0 then
				table.insert(this._queue, {
					skill = "gem_blast"
				})
			end
			local cmd = not this.hold_casts and table.remove(this._queue, 1) or nil
			if cmd then
				local casted = false
				if cmd.skill == "gem_blast" then
					casted = y_cast_gem_blast()
					gem_ts = casted and store.tick_ts or store.tick_ts - math.max(0, this.gem_blast.cooldown - 2)
				elseif cmd.skill == "disable_towers" then
					casted = y_cast_disable_towers(cmd)
				elseif cmd.skill == "summon_demons" then
					y_cast_summon(cmd)
					casted = true
				elseif cmd.skill == "explode_statue" then
					casted = y_cast_explode_statue(cmd)
				end
				if casted then
					U.y_wait(store, this.global_cooldown)
					taunt_ts = store.tick_ts
				end
			end
		end
		if this.hold_casts then
			taunt_ts = store.tick_ts
		elseif body and #this._queue == 0 and body.render.sprites[1].name == "idle" and taunt_wait < store.tick_ts - taunt_ts then
			y_play_random_taunt()
			taunt_ts = store.tick_ts
			taunt_wait = U.frandom(this.taunt_cooldown_min, this.taunt_cooldown_max)
		end
		coroutine.yield()
	end
end
S18.fx_stage_218_explosion_estatua = {}
function S18.fx_stage_218_explosion_estatua.update(this, store, script)
	if this.screenshake_amplitude then
		local shake = E:create_entity("aura_screen_shake")
		shake.aura.amplitude = this.screenshake_amplitude
		shake.aura.duration = this.screenshake_duration
		shake.aura.freq_factor = this.screenshake_freq_factor
		queue_insert(store, shake)
	end
	U.y_wait(store, this.mask_off_time)
	for _, e in pairs(store.entities) do
		if e.template_name == "decal_stage_218_statue_mask" or e.template_name == "decal_stage_218_statue_mask_noche" or e.template_name == "decal_nightfall_overlay" and e.swap_from == "decal_stage_218_statue_mask" then
			queue_remove(store, e)
		end
	end
end
S18.fx_stage_218_campana = {}
function S18.fx_stage_218_campana.update(this, store)
	S:queue(this.sound_bell_in)
	local cam_end_x = 750
	local cam_step = (cam_end_x - this.ray_cam_start.x) / #this.ray_positions
	local prev = 0
	for i, f in ipairs(this.sound_bell_frames) do
		local pos = this.ray_positions[i]
		U.y_wait(store, fts(f - prev))
		prev = f
		S:queue(this.sound_bell)
		if pos then
			U.y_wait(store, fts(this.ray_delay_frames))
			prev = f + this.ray_delay_frames
			local ray = E:create_entity(this.ray_fx_t)
			ray.pos = V.v(pos.x, pos.y)
			ray.render.sprites[1].flip_x = math.random() < 0.5
			ray.render.sprites[1].ts = store.tick_ts
			if REF_H - pos.y > ray.image_h then
				ray.render.sprites[1].scale = V.v(1, (REF_H - pos.y) / ray.image_h)
			end
			queue_insert(store, ray)
			local exp = E:create_entity(this.ray_explosion_fx)
			exp.pos = V.v(pos.x, pos.y)
			exp.render.sprites[1].ts = store.tick_ts
			queue_insert(store, exp)
			S:queue(this.sound_ray)
			local grieta = E:create_entity(this.grieta_fx_t)
			grieta.pos = V.v(pos.x, pos.y)
			grieta.render.sprites[1].ts = store.tick_ts
			queue_insert(store, grieta)
			local shake = E:create_entity("aura_screen_shake")
			shake.aura.amplitude = this.ray_shake.amplitude
			shake.aura.duration = this.ray_shake.duration
			shake.aura.freq_factor = this.ray_shake.freq_factor
			queue_insert(store, shake)
			U.y_wait(store, fts(this.ray_cam_delay_frames))
			prev = prev + this.ray_cam_delay_frames
			signal.emit("pan-zoom-camera", this.ray_cam_speed, {
				x = this.ray_cam_start.x + i * cam_step,
				y = this.ray_cam_start.y
			}, this.ray_cam_zoom)
		end
	end
	local ADB = require("animation_db")
	local aname = this.render.sprites[1].prefix .. "_" .. this.render.sprites[1].name
	local total = ADB:has_animation(aname) and ADB:animation_duration(aname) or 0
	U.y_wait(store, math.max(0, total - fts(prev)))
	S:queue(this.sound_bell_out)
end
S18.decal_stage_218_demon_circle = {}
function S18.decal_stage_218_demon_circle.update(this, store, script)
	while true do
		while not this._cast do
			coroutine.yield()
		end
		this._cast = nil
		U.y_animation_play(this, "in", nil, store.tick_ts, 1)
		U.animation_start(this, "loop", nil, store.tick_ts, true)
		while not this._out do
			coroutine.yield()
		end
		this._out = nil
		U.y_animation_play(this, "out", nil, store.tick_ts, 1)
	end
end
S18.mod_stage_218_veznan_tower_jail = {}
function S18.mod_stage_218_veznan_tower_jail.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if not target then
		queue_remove(store, this)
		return
	end
	U.animation_start(this, this.anim_tap[1], nil, store.tick_ts, nil, 1)
	U.y_animation_wait(this)
	U.animation_start(this, this.anim_tap[2], nil, store.tick_ts, true)
	local tap_tut = E:create_entity(this.tap_tutorial)
	tap_tut.pos = v(this.pos.x + this.tut_offset.x, this.pos.y + this.tut_offset.y)
	tap_tut.render.sprites[1].ts = store.tick_ts
	queue_insert(store, tap_tut)
	local taps = 0
	local tap_ts = store.tick_ts
	local window_ts = store.tick_ts
	local freed = false
	while store.tick_ts - window_ts < this.click_time do
		if this.ui and this.ui.clicked and store.tick_ts - tap_ts > 0.11 then
			taps = taps + 1
			tap_ts = store.tick_ts
			local shake = E:create_entity("mod_shake_sprite")
			shake.modifier.target_id = this.id
			shake.modifier.duration = 0.1
			shake.modifier.intensity = 4
			queue_insert(store, shake)
			if taps >= this.taps_to_thaw then
				freed = true
				S:queue(this.sound_events.interrupted)
				break
			end
		end
		this.ui.clicked = false
		coroutine.yield()
	end
	queue_remove(store, tap_tut)
	if not freed then
		S:queue(this.sound_events.locked)
		local lock_ts = store.tick_ts
		U.y_animation_play(this, this.anim_locked[1], nil, store.tick_ts, 1)
		U.animation_start(this, this.anim_locked[2], nil, store.tick_ts, true)
		U.y_wait(store, math.max(0, this.lock_duration - (store.tick_ts - lock_ts)))
		S:queue(this.sound_events.free_tower)
	end
	U.y_animation_play(this, this.anim_end, nil, store.tick_ts, 1)
	queue_remove(store, this)
end
S18.bullet_stage_218_moloch_lava_ball = {}
function S18.bullet_stage_218_moloch_lava_ball.update(this, store, script)
	scripts.enemy_bomb.update(this, store, script)
	if this.spawn_data then
		this.spawn_data.die_after_spawn = store.ephemeral.stage_218_final_cinematic
	end
	if this.screenshake_amplitude then
		local shake = E:create_entity("aura_screen_shake")
		shake.aura.amplitude = this.screenshake_amplitude
		shake.aura.duration = this.screenshake_duration
		shake.aura.freq_factor = this.screenshake_freq_factor
		queue_insert(store, shake)
	end
end
S18.controller_stage_218_moloch = {}
function S18.controller_stage_218_moloch.on_claw_slam(this, store, event_name)
	this._queue = this._queue or {}
	table.insert(this._queue, {
		skill = "claw_slam"
	})
end
function S18.controller_stage_218_moloch.on_lava_ball(this, store, event_name, area, count)
	this._queue = this._queue or {}
	local a = tonumber(area)
	if not a or a < 1 or a > #this.lava_ball.areas then
		a = 1
	end
	table.insert(this._queue, {
		skill = "lava_ball",
		area = a,
		count = tonumber(count)
	})
end
function S18.controller_stage_218_moloch.on_hellspawn_boost(this, store, event_name, duration)
	this._queue = this._queue or {}
	table.insert(this._queue, {
		skill = "hellspawn_boost",
		duration = tonumber(duration)
	})
end
function S18.controller_stage_218_moloch.mod_tower_stun_update(this, store)
	local m = this.modifier
	U.animation_start(this, "loop", nil, store.tick_ts, true)
	while store.tick_ts - m.ts < m.duration - this.fade_time do
		coroutine.yield()
	end
	local s = this.render.sprites[1]
	while store.tick_ts - m.ts < m.duration do
		s.alpha = 255 * km.clamp(0, 1, (m.duration - (store.tick_ts - m.ts)) / this.fade_time)
		coroutine.yield()
	end
	queue_remove(store, this)
end
function S18.controller_stage_218_moloch.bullet_target_update(this, store)
	local start_ts = store.tick_ts
	U.animation_start(this, "in2", nil, store.tick_ts, false)
	while store.tick_ts - start_ts < this.duration - this.out_time do
		if this.render.sprites[1].name == "in2" and U.animation_finished(this) then
			U.animation_start(this, "loop2", nil, store.tick_ts, true)
		end
		coroutine.yield()
	end
	U.y_animation_play(this, "out2", nil, store.tick_ts, 1)
	queue_remove(store, this)
end
function S18.controller_stage_218_moloch.mod_buff_update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if target then
		this.pos = target.pos
	end
	U.animation_start(this, "in", nil, store.tick_ts, false)
	U.y_animation_wait(this)
	U.animation_start(this, "loop", nil, store.tick_ts, true)
	local expired = false
	while true do
		local target = store.entities[m.target_id]
		if not target or target.health and target.health.dead then
			break
		end
		if store.tick_ts - m.ts >= m.duration - this.out_time then
			expired = true
			break
		end
		coroutine.yield()
	end
	if expired then
		U.y_animation_play(this, "out", nil, store.tick_ts, 1)
	end
	queue_remove(store, this)
end
function S18.controller_stage_218_moloch.update(this, store, script)
	this._queue = this._queue or {}
	local body
	local function body_shake(duration, intensity)
		if not body then
			return
		end
		local shake = E:create_entity("mod_shake_sprite")
		shake.modifier.target_id = body.id
		shake.modifier.duration = duration
		shake.modifier.intensity = intensity
		queue_insert(store, shake)
	end
	local function y_body_cast(sound, anim, hit_time, sound_frame)
		S:queue(sound, sound_frame and {
			delay = fts(sound_frame)
		} or nil)
		U.animation_start(body, anim, nil, store.tick_ts, false)
		U.y_wait(store, hit_time)
	end
	local function y_body_recover()
		U.y_animation_wait(body)
		U.animation_start(body, "idle", nil, store.tick_ts, true, nil, true)
	end
	local function screen_shake(cfg)
		local shake = E:create_entity("aura_screen_shake")
		shake.aura.amplitude = cfg.amplitude
		shake.aura.duration = cfg.duration
		shake.aura.freq_factor = cfg.freq_factor
		queue_insert(store, shake)
	end
	local function y_cast_claw_slam()
		local cs = this.claw_slam
		S:queue(this.claw_cast_sound)
		if this.claw_hit_time >= cs.telegraph_time then
			U.animation_start(body, this.claw_animation, nil, store.tick_ts, false)
			U.y_wait(store, this.claw_hit_time - cs.telegraph_time, function()
				return this._abort
			end)
			if this._abort then
				U.animation_start(body, "idle", nil, store.tick_ts, true, nil, true)
				return
			end
		end
		local target_pos = V.v(cs.pos.x, cs.pos.y)
		local tele = E:create_entity(this.claw_telegraph_t)
		tele.pos = V.vclone(target_pos)
		tele.render.sprites[1].ts = store.tick_ts
		queue_insert(store, tele)
		U.animation_start(tele, "in", nil, store.tick_ts, false)
		local anim_started = this.claw_hit_time >= cs.telegraph_time
		local anim_delay = cs.telegraph_time - this.claw_hit_time
		local start_ts = store.tick_ts
		while store.tick_ts - start_ts < cs.telegraph_time - tele.out_time do
			if this._abort then
				queue_remove(store, tele)
				U.animation_start(body, "idle", nil, store.tick_ts, true, nil, true)
				return
			end
			if not anim_started and anim_delay <= store.tick_ts - start_ts then
				U.animation_start(body, this.claw_animation, nil, store.tick_ts, false)
				anim_started = true
			end
			if tele.render.sprites[1].name == "in" and U.animation_finished(tele) then
				U.animation_start(tele, "loop", nil, store.tick_ts, true)
			end
			coroutine.yield()
		end
		if not anim_started then
			U.animation_start(body, this.claw_animation, nil, store.tick_ts, false)
		end
		U.y_animation_play(tele, "out", nil, store.tick_ts, 1)
		queue_remove(store, tele)
		S:queue(this.claw_hit_sound)
		local shake = E:create_entity("aura_screen_shake")
		shake.aura.amplitude = 1
		shake.aura.duration = 0.5
		shake.aura.freq_factor = 2
		queue_insert(store, shake)
		local fx = E:create_entity(this.claw_hit_fx)
		fx.pos = V.vclone(target_pos)
		fx.render.sprites[1].ts = store.tick_ts
		queue_insert(store, fx)
		local sdecal = E:create_entity(this.claw_decal_t)
		sdecal.pos = V.vclone(target_pos)
		sdecal.render.sprites[1].ts = store.tick_ts
		queue_insert(store, sdecal)
		local kills = 0
		local killed = {}
		local targets = U.find_soldiers_in_range(store.entities, target_pos, 0, cs.damage_radius, F_INSTAKILL, bor(F_ENEMY, F_HERO))
		if targets then
			for _, e in ipairs(targets) do
				local d = E:create_entity("damage")
				d.source_id = this.id
				d.target_id = e.id
				d.damage_type = DAMAGE_INSTAKILL
				queue_damage(store, d)
				killed[e.id] = true
				kills = kills + 1
			end
		end
		local shock_targets = U.find_soldiers_in_range(store.entities, target_pos, 0, cs.shock_radius, 0, bor(F_ENEMY))
		if shock_targets then
			for _, e in ipairs(shock_targets) do
				if not killed[e.id] then
					local dist_factor = U.dist_factor_inside_ellipse(e.pos, target_pos, cs.shock_radius)
					local d = E:create_entity("damage")
					d.source_id = this.id
					d.target_id = e.id
					d.damage_type = DAMAGE_TRUE
					d.value = math.floor(cs.shock_damage_max - (cs.shock_damage_max - cs.shock_damage_min) * dist_factor)
					queue_damage(store, d)
				end
			end
		end
		local stuns = 0
		local towers = stage218_find_towers(store, target_pos, cs.damage_radius, function(v, o)
			return not v.pending_removal and not v.tower.blocked and v.tower.type ~= "holder" and v.tower.type ~= "build_animation" and v.tower.can_be_mod and (not v.tower_holder or not v.tower_holder.blocked) and not U.has_modifier_types(store, v, MOD_TYPE_PROTECTION)
		end)
		if towers then
			for _, t in ipairs(towers) do
				local m = E:create_entity(this.claw_stun_mod_t)
				m.modifier.target_id = t.id
				m.modifier.source_id = this.id
				queue_insert(store, m)
				stuns = stuns + 1
			end
		end
		y_body_recover()
	end
	local function lava_safe(pi, ni)
		local sp = P.paths[pi] and P.paths[pi][1]
		if not sp or #sp < 2 then
			return false
		end
		local a, b = sp[1], sp[2]
		local spacing = math.sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y))
		return (#sp - ni) * spacing >= this.lava_ball.exit_safezone
	end
	local function lava_node_onscreen(pi, ni)
		local n = P.paths[pi][1][ni]
		return n.x > 40 and n.x < 984 and n.y > 60 and n.y < 700
	end
	local function find_lava_unit_nodes(area)
		local result = {}
		local lb = this.lava_ball
		local units = U.find_soldiers_in_range(store.entities, area.pos, 0, area.range, 0, bor(F_ENEMY))
		if not units then
			return result
		end
		for _, u in ipairs(units) do
			local nodes = P:nearest_nodes(u.pos.x, u.pos.y, lb.paths)
			if #nodes > 0 then
				local pi, _, ni, dist = unpack(nodes[1])
				if dist and dist <= lb.unit_snap_radius and P:is_path_active(pi) and lava_safe(pi, ni) and lava_node_onscreen(pi, ni) then
					local n = P.paths[pi][1][ni]
					table.insert(result, {
						pi = pi,
						ni = ni,
						pos = V.v(n.x, n.y)
					})
				end
			end
		end
		return result
	end
	local function random_lava_node(area)
		local lb = this.lava_ball
		local candidates = {}
		for _, pi in ipairs(lb.paths) do
			local sp = P:is_path_active(pi) and P.paths[pi] and P.paths[pi][1]
			if sp then
				for ni = 1, #sp do
					if U.is_inside_ellipse(sp[ni], area.pos, area.range) and lava_safe(pi, ni) and lava_node_onscreen(pi, ni) then
						table.insert(candidates, {
							pi = pi,
							ni = ni,
							pos = V.v(sp[ni].x, sp[ni].y)
						})
					end
				end
			end
		end
		if #candidates == 0 then
			return nil
		end
		return candidates[math.random(#candidates)]
	end
	local function y_cast_lava_ball(cmd)
		local lb = this.lava_ball
		S:queue(this.lava_cast_sound, this.lava_cast_sound_frame and {
			delay = fts(this.lava_cast_sound_frame)
		} or nil)
		U.animation_start(body, this.throw_animation, nil, store.tick_ts, false)
		local count = cmd.count and cmd.count > 0 and cmd.count or lb.count
		local area = lb.areas[cmd.area]
		local unit_nodes = table.random_order(find_lava_unit_nodes(area)) or {}
		local from = V.v(this.pos.x + this.throw_offset.x, this.pos.y + this.throw_offset.y)
		local targeted = 0
		local impacts = {}
		for i = 1, count do
			local target = table.remove(unit_nodes, 1)
			if target then
				targeted = targeted + 1
			else
				target = random_lava_node(area)
			end
			if target then
				target.ft = V.dist(from.x, from.y, target.pos.x, target.pos.y) / lb.speed
				table.insert(impacts, target)
			end
		end
		local events = {}
		for _, s in ipairs(this.throw_shakes) do
			table.insert(events, {
				time = math.min(s.time, this.throw_hit_time),
				shake = s
			})
		end
		for i, im in ipairs(impacts) do
			local t_impact = this.throw_hit_time + (i - 1) * fts(2) + im.ft
			local t_show = math.min(math.max(0, t_impact - lb.target_warn_time), this.throw_hit_time)
			table.insert(events, {
				time = t_show,
				impact = im,
				duration = t_impact - t_show
			})
		end
		table.sort(events, function(a, b)
			return a.time < b.time
		end)
		local elapsed = 0
		for _, ev in ipairs(events) do
			U.y_wait(store, ev.time - elapsed, function()
				return this._abort
			end)
			if this._abort then
				U.animation_start(body, "idle", nil, store.tick_ts, true, nil, true)
				return
			end
			elapsed = ev.time
			if ev.shake then
				screen_shake(ev.shake)
			else
				local marker = E:create_entity(this.bullet_target_t)
				marker.pos = V.vclone(ev.impact.pos)
				marker.render.sprites[1].ts = store.tick_ts
				marker.duration = ev.duration
				queue_insert(store, marker)
			end
		end
		U.y_wait(store, this.throw_hit_time - elapsed, function()
			return this._abort
		end)
		if this._abort then
			U.animation_start(body, "idle", nil, store.tick_ts, true, nil, true)
			return
		end
		S:queue(this.throw_sound)
		local max_ft = 0
		for _, im in ipairs(impacts) do
			local shadow = E:create_entity(this.lava_shadow_t)
			shadow.pos = V.vclone(im.pos)
			shadow.render.sprites[1].ts = store.tick_ts
			shadow.tween.props[1].keys[2][1] = im.ft
			queue_insert(store, shadow)
			local ball = E:create_entity(this.lava_ball_t)
			ball.pos = V.vclone(from)
			ball.bullet.from = V.vclone(from)
			ball.bullet.to = V.vclone(im.pos)
			ball.bullet.flight_time = im.ft
			ball.bullet.source_id = this.id
			ball.spawn_data = im
			queue_insert(store, ball)
			max_ft = math.max(max_ft, im.ft)
			U.y_wait(store, fts(2))
		end
		if #impacts > 0 then
			U.y_wait(store, max_ft)
			for _, im in ipairs(impacts) do
				local sfx = E:create_entity(this.lava_spawn_fx)
				sfx.pos = V.vclone(im.pos)
				sfx.render.sprites[1].ts = store.tick_ts
				queue_insert(store, sfx)
				if not U.is_seen(store, lb.spawn_template) then
					signal.emit("wave-notification", "icon", lb.spawn_template)
					U.mark_seen(store, lb.spawn_template)
				end
				local e = E:create_entity(lb.spawn_template)
				e.play_spawn_animation = true
				e.die_after_spawn = im.die_after_spawn
				e.nav_path.pi = im.pi
				e.nav_path.spi = 1
				e.nav_path.ni = im.ni
				e.pos.x, e.pos.y = im.pos.x, im.pos.y
				if e.enemy then
					e.enemy.gold = 0
				end
				queue_insert(store, e)
			end
			local pis = {}
			for _, im in ipairs(impacts) do
				table.insert(pis, im.pi)
			end
			log.debug("stage_218 moloch: lava ball x%s (%s elementales, %s sobre unidades, paths %s)", count, #impacts, targeted, table.concat(pis, ","))
		else
			log.debug("stage_218 moloch: lava ball sin nodos validos")
		end
		y_body_recover()
	end
	local function y_cast_hellspawn(cmd)
		local hb = this.hellspawn_boost
		y_body_cast(this.hellspawn_cast_sound, this.yell_animation, this.yell_shake.time, this.yell_sound_frame)
		screen_shake(this.yell_shake)
		U.y_wait(store, this.yell_hit_time - this.yell_shake.time)
		local targets = table.filter(store.entities, function(_, v)
			return v.enemy and v.unit and v.health and not v.health.dead and v.vis and not U.flag_has(v.vis.flags, F_FLYING) and table.contains(hb.allowed_templates, v.template_name)
		end)
		local count = 0
		if targets then
			for _, e in ipairs(targets) do
				local m = E:create_entity(this.hellspawn_mod_t)
				m.modifier.target_id = e.id
				m.modifier.source_id = this.id
				if cmd.duration and cmd.duration > 0 then
					m.modifier.duration = cmd.duration
				end
				queue_insert(store, m)
				count = count + 1
			end
		end
		log.debug("stage_218 moloch: hellspawn boost a %s demonios", count)
		y_body_recover()
	end
	U.y_wait(store, 1e+99, function()
		return this._appear
	end)
	local fx = E:create_entity(this.appear_fx)
	fx.pos = V.vclone(this.pos)
	fx.render.sprites[1].ts = store.tick_ts
	queue_insert(store, fx)
	S:queue(this.appear_sound)
	for _, name in ipairs(this.masks_off_on_appear or {}) do
		for _, e in pairs(store.entities) do
			if e.template_name == name or e.template_name == "decal_nightfall_overlay" and e.hide_from == name then
				queue_remove(store, e)
			end
		end
	end
	local mascara = E:create_entity(this.mascara_fondo_decal_t)
	queue_insert(store, mascara)
	body = E:create_entity(this.body_decal_t)
	body.pos = V.vclone(this.pos)
	body.render.sprites[1].ts = store.tick_ts
	body.render.sprites[2].ts = store.tick_ts
	body.render.sprites[3].ts = store.tick_ts
	queue_insert(store, body)
	U.animation_start(body, this.appear_animation, nil, store.tick_ts, false)
	if this.appear_roar_sound then
		S:queue(this.appear_roar_sound, {
			delay = fts(this.appear_roar_frame)
		})
	end
	local events = {}
	for _, s in ipairs(this.appear_shakes) do
		table.insert(events, {
			time = s.time,
			shake = s
		})
	end
	table.insert(events, {
		mascara = true,
		time = this.mascara_time
	})
	table.insert(events, {
		camino = true,
		time = this.camino_time
	})
	table.sort(events, function(a, b)
		return a.time < b.time
	end)
	local elapsed = 0
	for _, ev in ipairs(events) do
		U.y_wait(store, ev.time - elapsed)
		elapsed = ev.time
		if ev.shake then
			screen_shake(ev.shake)
		elseif ev.mascara then
			mascara.render.sprites[1].hidden = false
		elseif ev.camino then
			local camino = E:create_entity(this.camino_decal_t)
			queue_insert(store, camino)
			mascara.render.sprites[2].hidden = false
		end
	end
	U.y_animation_wait(body)
	if math.random() < 0.5 then
		U.animation_start(body, "idle", nil, store.tick_ts, true, nil, true)
	else
		U.animation_start(body, "idle2", nil, store.tick_ts, false)
	end
	log.debug("stage_218 moloch: aparece (wave %s)", store.wave_group_number)
	while true do
		local s1 = body.render.sprites[1]
		if s1.name == "idle2" and U.animation_finished(body) then
			U.animation_start(body, "idle", nil, store.tick_ts, true)
		elseif s1.name == "idle" and s1.sync_flag and math.random() < this.idle2_chance then
			U.animation_start(body, "idle2", nil, store.tick_ts, false)
		end
		local cmd = table.remove(this._queue, 1)
		if cmd and not this._abort then
			this._casting = true
			if cmd.skill == "claw_slam" then
				y_cast_claw_slam()
			elseif cmd.skill == "lava_ball" then
				y_cast_lava_ball(cmd)
			elseif cmd.skill == "hellspawn_boost" then
				y_cast_hellspawn(cmd)
			end
			this._casting = false
			U.y_wait(store, this.global_cooldown)
		end
		coroutine.yield()
	end
end
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local tt = E:register_t_hot("ps_bullet_trail_stage_218_moloch", "particle_system", true)
tt.particle_system.name = "molochproyectiletrail_run"
tt.particle_system.scales_x = {1.6, 1.6}
tt.particle_system.scales_y = {1.6, 1.6}
tt.particle_system.emission_rate = 20
tt.particle_system.track_rotation = true
tt.particle_system.particle_lifetime = {fts(22), fts(22)}
tt.particle_system.emit_offset = v(0, 50)
tt.particle_system.animated = true
tt.particle_system.loop = false
tt = E:register_t_hot("tunnel_stage_218", "tunnel_KR6", true)
tt.tunnel.pick_sound = "Stage218PortalCreepPassage"
tt.tunnel.fx_use_unit_offset = true
tt = E:register_t_hot("decal_stage_218_water_1", "decal_tween", true)
tt.fade_time = 2
tt.render.sprites[1].prefix = "st_218_anims_agua_1Def"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {2, 0}}
tt = E:register_t_hot("decal_stage_218_water_2", "decal_stage_218_water_1", true)
tt.render.sprites[1].prefix = "st_218_anims_agua_2Def"
tt.render.sprites[1].flip_x = true
tt = E:register_t_hot("fx_stage_218_nightfall_flare", "fx", true)
tt.render.sprites[1].prefix = "vfx_transition_stage_flares"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("fx_stage_218_nightfall_fire_01", "fx", true)
tt.render.sprites[1].name = "vfx_transition_stage_desintegrate_01"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("fx_stage_218_nightfall_fire_02", "fx", true)
tt.render.sprites[1].name = "vfx_transition_stage_desintegrate_02"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("fx_stage_218_nightfall_fire_03", "fx", true)
tt.render.sprites[1].name = "vfx_transition_stage_desintegrate_03"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("fx_stage_218_nightfall_fire_04", "fx", true)
tt.render.sprites[1].name = "vfx_transition_stage_desintegrate_04"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("decal_stage_218_nightfall", "decal_scripted", true)
tt.set_day_bg_hidden = S18.stage_218_nightfall.set_day_bg_hidden
tt.apply_final = S18.stage_218_nightfall.apply_final
tt.pos = v(512, 384)
tt.render.sprites[1].name = "Stage218_0002"
tt.render.sprites[1].animated = false
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN
tt.render.sprites[1].shader = "p_dissolve_reveal"
tt.render.sprites[1].shader_args = {
	edge_width = 0.05,
	edge_softness = 0.01,
	edge_core_blend = 0.01,
	threshold = 0,
	edge_core_width = 0.05,
	noise_scale = 6,
	noise_amp = 0.18,
	dir = {0, 1},
	edge_color = {1, 0.403, 0.972, 1},
	edge_color_core = {1, 0.866, 0.992, 1}
}
tt.main_script.update = S18.stage_218_nightfall.update
tt.reveal_time = 8
tt.reveal_ease = "linear"
tt.front_fx = {{
	fx = "fx_stage_218_nightfall_flare",
	weight = 20
}, {
	fx = "fx_stage_218_nightfall_fire_01",
	weight = 20
}, {
	fx = "fx_stage_218_nightfall_fire_02",
	weight = 20
}, {
	fx = "fx_stage_218_nightfall_fire_03",
	weight = 20
}, {
	fx = "fx_stage_218_nightfall_fire_04",
	weight = 20
}}
tt.front_fx_rate = 700
tt.front_fx_flip = true
tt.front_fx_band = 0.02
tt.front_fx_lead = 0
tt.front_fx_scale_min = 0.7
tt.front_fx_scale_max = 1.7
tt = E:register_t_hot("decal_nightfall_overlay", "decal_scripted", true)
tt.pos = v(512, 384)
tt.nightfall_name = "decal_stage_218_nightfall"
tt.render.sprites[1].name = "stage218_1_spawner_noche"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -10
tt.render.sprites[1].shader = "p_dissolve_reveal"
tt.main_script.update = S18.nightfall_dissolve.update
tt = E:register_t_hot("decal_stage_218_bg_overlay", "decal", true)
tt.pos = v(512, 384)
tt.render.sprites[1].name = "Stage218_0003"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN
tt.render.sprites[1].sort_y_offset = -10
tt = E:register_t_hot("decal_stage_218_camino_moloch", "decal", true)
tt.pos = v(512, 384)
tt.render.sprites[1].name = "stage_218_10_camino_moloch"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS + 10
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "stage_218_10_camino_moloch_2"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_BACKGROUND_COVERS + 10
tt = E:register_t_hot("decal_stage_218_mascara_fondo_moloch", "decal", true)
tt.pos = v(512, 384)
tt.render.sprites[1].name = "stage_218_12_mascara_fondo_moloch"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN
tt.render.sprites[1].scale = vv(2)
tt.render.sprites[1].hidden = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "stage_218_12_mascara_fondo_moloch_2"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_BACKGROUND_BETWEEN
tt.render.sprites[2].scale = vv(2)
tt.render.sprites[2].hidden = true
tt = E:register_t_hot("decal_stage_218_spawner", "decal", true)
tt.render.sprites[1].name = "stage218_1_spawner"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 128
tt = E:register_t_hot("decal_stage_218_balcon_layer", "decal", true)
tt.render.sprites[1].name = "stage_218_balcon_layer_01"
tt.render.sprites[1].animated = false
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y = 500
tt = E:register_t_hot("fx_stage_218_explosion_entrada_denas", "fx", true)
tt.timed.runs = INT_32_MAX
tt.render.sprites[1].prefix = "st_218_explosion_entrada_denasDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt = E:register_t_hot("decal_stage_218_statue_mask", "decal", true)
tt.render.sprites[1].name = "stage_218_6"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -10
tt = E:register_t_hot("decal_stage_218_statue_mask_noche", "decal_stage_218_statue_mask", true)
tt.render.sprites[1].name = "stage_218_9"
tt = E:register_t_hot("decal_stage_218_mask_arbol_1", "decal", true)
tt.render.sprites[1].name = "stage_218_4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("decal_stage_218_mask_arbol_2", "decal", true)
tt.render.sprites[1].name = "stage_218_3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("decal_stage_218_mask_ciudad_1", "decal", true)
tt.render.sprites[1].name = "stage_218_7"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("decal_stage_218_mask_ciudad_2", "decal", true)
tt.render.sprites[1].name = "stage_218_8"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("decal_stage_218_puerta_mask", "decal", true)
tt.pos = v(512, 384)
tt.render.sprites[1].name = "stage_218_17_puerta_terreno_1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS + 1
tt = E:register_t_hot("fx_stage_218_campana", "fx", true)
AC(tt, "main_script")
tt.main_script.update = S18.fx_stage_218_campana.update
tt.sound_bell = "Stage218MolochBigBell"
tt.sound_bell_in = "Stage218MolochBigBellIn"
tt.sound_bell_out = "Stage218MolochBigBellOut"
tt.sound_bell_frames = {34, 76, 119, 162, 205, 247}
tt.sound_ray = "Stage218MolochEntranceLightningStrike"
tt.ray_delay_frames = 10
tt.ray_fx_t = "fx_stage_218_moloch_ray"
tt.ray_explosion_fx = "fx_stage_218_moloch_ray_explosion"
tt.grieta_fx_t = "fx_stage_218_grieta"
tt.ray_positions = {{
	x = 638,
	y = 390
}, {
	x = 826,
	y = 439
}, {
	x = 988,
	y = 493
}}
tt.ray_shake = {
	freq_factor = 6,
	duration = 0.5,
	amplitude = 0.6
}
tt.ray_cam_zoom = 1.3
tt.ray_cam_speed = 0.8
tt.ray_cam_delay_frames = 25
tt.ray_cam_start = {
	x = 512,
	y = 768
}
tt.render.sprites[1].prefix = "campanaDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt = E:register_t_hot("fx_stage_218_moloch_ray", "decal_tween", true)
tt.image_h = 722
tt.render.sprites[1].name = "ray_1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.5
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[1].scale = vv(2)
tt.tween.props[1].keys = {{0, 255}, {fts(3), 255}, {fts(8), 0}}
tt = E:register_t_hot("fx_stage_218_moloch_ray_explosion", "fx", true)
tt.render.sprites[1].prefix = "ray_exp"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].scale = vv(2)
tt = E:register_t_hot("fx_stage_218_grieta", "fx", true)
tt.render.sprites[1].prefix = "grietaDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = 1200
tt = E:register_t_hot("fx_stage_218_explosion_estatua", "fx", true)
AC(tt, "main_script")
tt.main_script.update = S18.fx_stage_218_explosion_estatua.update
tt.mask_off_time = fts(7)
tt.screenshake_amplitude = 0.7
tt.screenshake_duration = 1.2
tt.screenshake_freq_factor = 3
tt.render.sprites[1].prefix = "explosion_estatuaDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].offset = v(0, -20)
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt = E:register_t_hot("decal_stage_218_portal_1", "decal_scripted", true)
tt.main_script.update = S18.decal_stage_218_portal.update_auto
tt.tunnel_place_pis = {17}
tt.close_delay = 1
tt.sound_open = "Stage218PortalOpen"
tt.sound_close = "Stage218PortalClose"
tt.render.sprites[1].prefix = "st_218_animations_portal_1Def"
tt.render.sprites[1].name = "off_idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t_hot("decal_stage_218_portal_2", "decal_stage_218_portal_1", true)
AC(tt, "events")
tt.main_script.update = S18.decal_stage_218_portal.update
tt.events.list[1].name = "stage_218_portal"
tt.events.list[1].on_event = S18.decal_stage_218_portal.on_event
tt.portal_idx = 1
tt.tunnel_place_pis = nil
tt.render.sprites[1].prefix = "st_218_animations_portal_2Def"
tt = E:register_t_hot("decal_stage_218_portal_3", "decal_stage_218_portal_1", true)
tt.tunnel_place_pis = {20}
tt.render.sprites[1].prefix = "st_218_animations_portal_3Def"
tt = E:register_t_hot("decal_stage_218_portal_4", "decal_stage_218_portal_2", true)
tt.portal_idx = 2
tt.render.sprites[1].prefix = "st_218_animations_portal_4Def"
tt = E:register_t_hot("decal_stage_218_portal_back", "decal_stage_218_portal_1", true)
tt.tunnel_place_pis = {18, 19}
tt.render.sprites[1].prefix = "st_218_animations_portal_backDef"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("decal_stage_218_puerta", "decal_scripted", true)
AC(tt, "events")
tt.main_script.update = S18.decal_stage_218_puerta.update
tt.events.list[1].name = "stage_218_puerta"
tt.events.list[1].on_event = S18.decal_stage_218_puerta.on_event
tt.on_nightfall = S18.decal_stage_218_puerta.on_nightfall
tt.sound_open = "Stage218VeznanTowerDoorOpen"
tt.sound_open_frame = 6
tt.sound_close = "Stage218VeznanTowerDoorClose"
tt.sound_close_frame = 10
tt.render.sprites[1].prefix = "animations_puerta_st_218_terreno_1Def"
tt.render.sprites[1].name = "closed_idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t_hot("decal_stage_218_demon_circle", "decal_scripted", true)
tt.main_script.update = S18.decal_stage_218_demon_circle.update
tt.render.sprites[1].prefix = "demon_circleDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t_hot("controller_stage_218_veznan", nil, true)
AC(tt, "main_script", "events", "pos")
tt.pos = v(518, 677)
tt.sigil_pos = v(506, 372)
tt.cast_time = 1
tt.global_cooldown = 2
tt.taunt_cooldown_min = 12
tt.taunt_cooldown_max = 24
tt.body_decal_t = "decal_stage_218_veznan_body"
tt.gem_blast = {
	start_wave = 2,
	cooldown = 15,
	count = 4,
	radius = 300,
	damage_min = 180,
	damage_max = 240
}
tt.gem_blast_bullet_t = "bullet_stage_218_veznan_gem_blast"
tt.gem_blast_spawn_fx = "fx_veznan_f1_bolt_spawn"
tt.gem_blast_shot_frames = {51, 68, 82}
tt.gem_blast_muzzle_offsets = {
	left = v(0, -60),
	center = v(0, -60),
	right = v(0, -60)
}
tt.gem_blast_zone_left_x = 400
tt.gem_blast_zone_right_x = 630
tt.gem_blast_curve_sides = {1, -1, 1}
tt.gem_blast_vis_flags = bor(F_RANGED)
tt.gem_blast_vis_bans = 0
tt.gem_blast_sound = "Stage218TowerVeznanBoltCharge"
tt.gem_blast_release_sound = "Stage218TowerVeznanBoltRelease"
tt.gem_blast_animation = "bolt"
tt.disable_animation = "tower_stun"
tt.summon_animation = "summondemon_in"
tt.summon_shot_frame = 76
tt.summon_ranged_delay = 1
tt.summon_circle_t = "decal_stage_218_demon_circle"
tt.disable_mod_t = "mod_stage_218_veznan_tower_jail"
tt.disable_default_count = 2
tt.disable_default_group = "*"
tt.disable_cast_sound = "Stage218TowerVeznanDisableTowersCast"
tt.summon_groups = {{{2, 0, "enemy_demon_spawn"}, {1, 0.8, "enemy_demon_spawn"}, {3, 1, "enemy_demon_spawn"}, {2, 0.8, "enemy_demon_spawn"}, {1, 1.2, "enemy_demon_spawn"}}, {{2, 0, "enemy_demon_hound"}, {1, 1.6, "enemy_demon_hound"}, {3, 1, "enemy_demon_hound"}, {2, 0.8, "enemy_demon_hound"}}, {{2, 0, "enemy_demon_spawn"}, {1, 0.8, "enemy_demon_spawn"}, {3, 0.8, "enemy_demon_lord"}, {2, 1, "enemy_demon_flareon_kr6"}, {1, 1.2, "enemy_demon_flareon_kr6"}}, {{2, 0, "enemy_demon_imp_kr6"}, {1, 1, "enemy_demon_imp_kr6"}, {3, 1, "enemy_demon_imp_kr6"}}}
tt.summon_default_group = 1
tt.summon_default_path = 1
tt.summon_cast_sound = "Stage218DemonsPentagramAppear"
tt.sigil_burst_fx = "fx_demon_flareon_explosion"
tt.summon_spawn_fx = "fx_veznan_summon_explosion"
tt.summon_spawn_sound = "Stage218DemonsPentagramIn"
tt.statue_animation = "break_statue"
tt.statue_shot_frame = 175
tt.statue_bullet_t = "bullet_stage_218_veznan_statue"
tt.statue_muzzle_offset = v(-4, -58)
tt.statue_target_pos = v(512, 384)
tt.statue_cast_sound = "Stage218TowerVeznanStatueBreakCast"
tt.statue_bolt_sound = "Stage218BossVeznanBoltRelease"
tt.taunt_animations = {
	veznan_fase1Def = {"taunt1", "taunt2", "taunt3_in"},
	veznan_fase2_balconDef = {"taunt1", "taunt2", "taunt3"}
}
tt.main_script.update = S18.controller_stage_218_veznan.update
tt.events.list[1].name = "veznan_disable_towers"
tt.events.list[1].on_event = S18.controller_stage_218_veznan.on_disable_towers
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "veznan_summon_demons"
tt.events.list[2].on_event = S18.controller_stage_218_veznan.on_summon_demons
tt.events.list[3] = E:clone_c("event")
tt.events.list[3].name = "veznan_bolts_off"
tt.events.list[3].on_event = S18.controller_stage_218_veznan.on_bolts_off
tt.events.list[4] = E:clone_c("event")
tt.events.list[4].name = "veznan_explode_statue"
tt.events.list[4].on_event = S18.controller_stage_218_veznan.on_explode_statue
tt = E:register_t_hot("decal_stage_218_veznan_body", "decal", true)
tt.render.sprites[1].prefix = "veznan_fase1Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].offset = v(-6, -251)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y = 505
tt = E:register_t_hot("mod_stage_218_veznan_tower_jail", "mod_tower_stun", true)
AC(tt, "render", "ui")
tt.main_script.update = S18.mod_stage_218_veznan_tower_jail.update
tt.modifier.duration = 4 + 6
tt.click_time = 4
tt.lock_duration = 6
tt.taps_to_thaw = IS_PHONE_OR_TABLET and 5 or 3
tt.tut_offset = v(17, 5)
tt.anim_tap = {"tap_in", "tap_loop"}
tt.anim_locked = {"stun_in", "stun_loop"}
tt.anim_end = "stun_out"
tt.tap_tutorial = "decal_tapping_hand"
tt.sound_events.locked = "EnemyDarkDiscipleTowerTetherSummon"
tt.render.sprites[1].prefix = "veznan_stuntowerDef"
tt.render.sprites[1].name = "tap_in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -10
tt.ui.click_rect = r(-50, -15, 100, 100)
tt.sound_events.insert = "Stage218TowerVeznanDisableTowersDisable"
tt.sound_events.interrupted = "Stage218TowerVeznanDisableTowersInterrupt"
tt.sound_events.free_tower = "EnemyDarkDiscipleTowerTetherCastUnlock"
tt = E:register_t_hot("mod_stage_218_veznan_reveal_stun", "mod_stun", true)
tt.modifier.duration = 14
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_ENEMY)
tt = E:register_t_hot("bullet_stage_218_veznan_gem_blast", "bullet_dark_disciple_basic", true)
AC(tt, "force_motion")
tt.main_script.insert = S18.bullet_stage_218_veznan_bolt.insert
tt.main_script.update = S18.bullet_stage_218_veznan_bolt.update
tt.render.sprites[1].prefix = "veznan_fx_f1_bolt_projectile"
tt.render.sprites[1].name = "flying"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.bullet.damage_min = 180
tt.bullet.damage_max = 240
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.particles_name = "ps_veznan_f1_bolt_trail"
tt.bullet.hit_fx = "fx_veznan_bolt_hit"
tt.hit_sfx = "Stage218TowerVeznanBoltImpact"
tt.initial_impulse = 15000
tt.initial_impulse_duration = 0.15
tt.initial_impulse_angle = math.pi / 3
tt.force_motion.a_step = 5
tt.force_motion.max_a = 3750
tt.force_motion.max_v = 375
tt = E:register_t_hot("bullet_stage_218_veznan_gem_blast_f2", "bullet_stage_218_veznan_gem_blast", true)
tt.render.sprites[1].prefix = "veznan_fx_f2_bolt_projectile"
tt.bullet.particles_name = "ps_veznan_f2_bolt_trail"
tt.bullet.hit_fx = "fx_veznan_explosion_bolt"
tt.bullet.hit_fx_air = "fx_veznan_hit_rojo"
tt.bullet.ignore_hit_offset = true
tt.initial_impulse = nil
tt.straight_flight = true
tt.bullet.pop = {"pop_lightning1"}
tt.hit_sfx = "Stage218BossVeznanBoltImpact"
tt = E:register_t_hot("bullet_stage_218_veznan_statue", "bullet_stage_218_veznan_gem_blast_f2", true)
tt.bullet.hit_fx = "fx_stage_218_explosion_estatua"
tt.hit_sfx = "Stage218TowerVeznanStatueBreakBreak"
tt.force_motion.max_v = 480
tt = E:register_t_hot("bullet_stage_218_veznan_soul", "bullet_necromancer", true)
tt.render.sprites[1].prefix = "veznan_fx_ghost_projectile"
tt.bullet.particles_name = "ps_veznan_ghost_trail"
tt.main_script.insert = S18.bullet_stage_218_veznan_soul.insert
tt.main_script.update = S18.bullet_stage_218_veznan_soul.update
tt.soul_in_time = fts(4)
tt.arrive_fx = "fx_veznan_ghost_out"
tt.arrive_pump_fx = "fx_veznan_healpump"
tt = E:register_t_hot("bullet_stage_218_veznan_soul_reveal", "bullet_stage_218_veznan_soul", true)
AC(tt, "tween")
tt.tween.remove = false
tt.tween.run_once = true
tt.tween.props[1].keys = {{0, 0}, {0.3, 255}}
tt.main_script.update = S18.bullet_stage_218_veznan_soul_reveal.update
tt.curve_offset = {60, 120}
tt = E:register_t_hot("bullet_stage_218_veznan_soul_release", "bullet_stage_218_veznan_soul_reveal", true)
tt.tween.props[1].keys = {{0, 255}, {1, 255}, {2, 0}}
tt.arrive_fx = false
tt.arrive_pump_fx = false
tt = E:register_t_hot("bullet_stage_218_veznan_soul_escape", "bullet_stage_218_veznan_soul_release", true)
tt.tween.disabled = true
tt = E:register_t_hot("controller_stage_218_moloch", nil, true)
AC(tt, "main_script", "events", "pos")
tt.pos = v(1000, 470)
tt.body_decal_t = "decal_stage_218_moloch_body"
tt.appear_fx = "fx_demon_flareon_explosion"
tt.appear_sound = "Stage218MolochEntrance"
tt.appear_roar_sound = "Stage218MolochRoar"
tt.appear_roar_frame = 248
tt.global_cooldown = 2
tt.appear_animation = "start"
tt.mascara_fondo_decal_t = "decal_stage_218_mascara_fondo_moloch"
tt.masks_off_on_appear = {"decal_stage_218_mask_arbol_1"}
tt.camino_decal_t = "decal_stage_218_camino_moloch"
tt.camino_time = fts(163)
tt.mascara_time = fts(45)
tt.claw_animation = "smash"
tt.claw_hit_time = fts(100)
tt.throw_animation = "throw"
tt.throw_hit_time = fts(167)
tt.throw_offset = v(300, 70)
tt.throw_shakes = {{
	amplitude = 0.6,
	freq_factor = 6,
	time = fts(58),
	duration = fts(15)
}, {
	amplitude = 0.6,
	freq_factor = 6,
	time = fts(93),
	duration = fts(30)
}}
tt.appear_shakes = {{
	amplitude = 0.6,
	freq_factor = 6,
	time = fts(44),
	duration = fts(15)
}, {
	amplitude = 0.6,
	freq_factor = 6,
	time = fts(90),
	duration = fts(15)
}, {
	amplitude = 0.6,
	freq_factor = 6,
	time = fts(162),
	duration = fts(30)
}, {
	amplitude = 1.5,
	freq_factor = 3,
	time = fts(251),
	duration = fts(60)
}}
tt.yell_animation = "yell"
tt.yell_hit_time = fts(45)
tt.yell_shake = {
	amplitude = 1,
	freq_factor = 3,
	time = fts(33),
	duration = fts(60)
}
tt.idle2_chance = 0.2
tt.lava_spawn_fx = "fx_stage_218_moloch_explosion"
tt.claw_slam = {
	pos = v(812, 348),
	telegraph_time = 4.3,
	damage_radius = 280,
	tower_stun_duration = 3.5,
	shock_radius = 450,
	shock_damage_max = 700,
	shock_damage_min = 100
}
tt.claw_telegraph_t = "decal_stage_218_moloch_telegraph"
tt.claw_hit_fx = "fx_dark_sapper_bomb_hit"
tt.claw_decal_t = "decal_stage_218_moloch_smash_decal"
tt.claw_stun_mod_t = "mod_stage_218_moloch_tower_stun"
tt.claw_cast_sound = nil
tt.claw_hit_sound = "Stage218MolochSlam"
tt.lava_ball = {
	count = 1,
	damage_min = 200,
	damage_max = 250,
	damage_radius = 90,
	speed = 1500,
	target_warn_time = 4,
	areas = {{
		range = 150,
		pos = v(383, 333)
	}, {
		range = 100,
		pos = v(198, 355)
	}, {
		range = 150,
		pos = v(415, 441)
	}},
	fire_duration = 5,
	fire_radius = 70,
	fire_cycle_time = 0.4,
	burn_duration = 3,
	burn_damage_min = 8,
	burn_damage_max = 12,
	spawn_template = "enemy_magma_elemental",
	exit_safezone = 300,
	unit_snap_radius = 80,
	paths = {9, 13, 15, 17, 22}
}
tt.lava_ball_t = "bullet_stage_218_moloch_lava_ball"
tt.lava_shadow_t = "decal_stage_218_moloch_shadow"
tt.bullet_target_t = "decal_stage_218_moloch_bullet_target"
tt.lava_cast_sound = "Stage218MolochMoltenRockCast"
tt.lava_cast_sound_frame = 59
tt.throw_sound = "Stage218MolochMoltenRockThrow"
tt.hellspawn_boost = {
	dmg_factor = 1.5,
	duration = 8,
	allowed_templates = {"enemy_demon_spawn", "enemy_demon_hound", "enemy_demon_imp_kr6", "enemy_demon_flareon_kr6", "enemy_demon_lord", "enemy_magma_elemental"}
}
tt.hellspawn_mod_t = "mod_stage_218_moloch_hellspawn_buff"
tt.hellspawn_cast_sound = "Stage218MolochRoar"
tt.yell_sound_frame = 33
tt.main_script.update = S18.controller_stage_218_moloch.update
tt.events.list[1].name = "moloch_claw_slam"
tt.events.list[1].on_event = S18.controller_stage_218_moloch.on_claw_slam
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "moloch_lava_ball"
tt.events.list[2].on_event = S18.controller_stage_218_moloch.on_lava_ball
tt.events.list[3] = E:clone_c("event")
tt.events.list[3].name = "moloch_hellspawn_boost"
tt.events.list[3].on_event = S18.controller_stage_218_moloch.on_hellspawn_boost
tt = E:register_t_hot("decal_stage_218_moloch_body", "decal", true)
tt.render.sprites[1].prefix = "moloch_bottomDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "molochDef"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].exo = true
tt.render.sprites[2].loop = true
tt.render.sprites[2].z = Z_OBJECTS + 1
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "moloch_handDef"
tt.render.sprites[3].name = "idle"
tt.render.sprites[3].exo = true
tt.render.sprites[3].loop = true
tt.render.sprites[3].z = Z_BACKGROUND_COVERS + 11
tt.death_sound = "Stage218BossVeznanMolochDefeatFullSeq"
tt = E:register_t_hot("decal_stage_218_moloch_telegraph", "decal", true)
tt.render.sprites[1].prefix = "molochtargetDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.out_time = fts(12)
tt = E:register_t_hot("decal_stage_218_moloch_bullet_target", "decal_scripted", true)
tt.render.sprites[1].prefix = "molochtargetDef"
tt.render.sprites[1].name = "in2"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.out_time = fts(13)
tt.main_script.update = S18.controller_stage_218_moloch.bullet_target_update
tt = E:register_t_hot("bullet_stage_218_moloch_lava_ball", "bomb", true)
tt.render.sprites[1].prefix = "molochproyectile"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].offset = v(0, 25)
tt.render.sprites[1].scale = v(1.6, 1.6)
tt.bullet.g = 0
tt.bullet.align_with_trajectory = true
tt.bullet.particles_name = "ps_bullet_trail_stage_218_moloch"
tt.bullet.hit_fx = "fx_stage_218_moloch_explosion"
tt.bullet.hit_payload = "aura_stage_218_moloch_ground_fire"
tt.bullet.mod = "mod_stage_218_moloch_burn"
tt.bullet.damage_min = 200
tt.bullet.damage_max = 250
tt.bullet.damage_radius = 90
tt.bullet.damage_flags = bor(F_AREA, F_FRIEND)
tt.bullet.damage_bans = bor(F_ENEMY)
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = S18.bullet_stage_218_moloch_lava_ball.update
tt.screenshake_amplitude = 0.6
tt.screenshake_duration = 0.8
tt.screenshake_freq_factor = 6
tt.sound_events.hit = "Stage218MolochMoltenRockImpact"
tt = E:register_t_hot("decal_stage_218_moloch_shadow", "decal_tween", true)
tt.render.sprites[1].name = "molochproyectileshadow"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, v(0.1, 0.1)}, {1, v(1, 1)}}
tt = E:register_t_hot("decal_stage_218_moloch_smash_decal", "decal_tween", true)
tt.render.sprites[1].prefix = "MolochSmashDecalDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{4, 255}, {6, 0}}
tt = E:register_t_hot("fx_stage_218_moloch_explosion", "fx", true)
tt.render.sprites[1].prefix = "MolochProyectileExplosionDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt = E:register_t_hot("fx_stage_218_portal_efecto", "fx", true)
tt.render.sprites[1].prefix = "stage_218_portal_efectoDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
tt = E:register_t_hot("fx_stage_218_portal_efecto_flip", "fx_stage_218_portal_efecto", true)
tt.render.sprites[1].flip_x = true
tt = E:register_t_hot("fx_stage_218_portal_efecto_t2", "fx_stage_218_portal_efecto", true)
tt.render.sprites[1].prefix = "st_218_terreno_2_portal_efectoDef"
tt = E:register_t_hot("fx_stage_218_portal_efecto_t2_flip", "fx_stage_218_portal_efecto_t2", true)
tt.render.sprites[1].flip_x = true
tt = E:register_t_hot("aura_stage_218_moloch_ground_fire", "aura", true)
AC(tt, "render", "tween")
tt.aura.mod = "mod_stage_218_moloch_burn"
tt.aura.radius = 70
tt.aura.cycle_time = 0.4
tt.aura.duration = 5
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_ENEMY, F_FLYING)
tt.render.sprites[1].name = "molochproyectiledecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{"this.actual_duration - 1", 255}, {"this.actual_duration", 0}}
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt = E:register_t_hot("mod_stage_218_moloch_burn", "modifier", true)
AC(tt, "dps", "render")
tt.modifier.duration = 3
tt.modifier.vis_flags = bor(F_MOD, F_BURN)
tt.modifier.vis_bans = bor(F_ENEMY)
tt.dps.damage_min = 8
tt.dps.damage_max = 12
tt.dps.damage_inc = 0
tt.dps.damage_every = 0.5
tt.dps.damage_type = DAMAGE_TRUE
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt = E:register_t_hot("mod_stage_218_moloch_tower_stun", "mod_tower_stun", true)
AC(tt, "render")
tt.modifier.duration = 3.5
tt.render.sprites[1].prefix = "moloch_towerstunDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -10
tt.fade_time = 0.5
tt.main_script.update = S18.controller_stage_218_moloch.mod_tower_stun_update
tt = E:register_t_hot("mod_stage_218_moloch_hellspawn_buff", "modifier", true)
AC(tt, "render")
tt.inflicted_damage_factor = 1.5
tt.modifier.duration = 8
tt.out_time = fts(9)
tt.render.sprites[1].prefix = "molochbuff_back"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 10
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "molochbuff_front"
tt.render.sprites[2].name = "in"
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].sort_y_offset = -10
tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.update = S18.controller_stage_218_moloch.mod_buff_update
tt.main_script.remove = scripts.mod_damage_factors.remove
