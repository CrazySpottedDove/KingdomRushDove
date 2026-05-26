local M = {}

local bit = require("bit")
local bor = bit.bor
local band = bit.band
local perf = require("dove_modules.perf.perf")
local E = require("entity_db")
local signal = require("lib.hump.signal")
local SU = require("script_utils")
local U = require("utils")
local ffi = require("ffi")
local G = love.graphics
local random = math.random
local floor = math.floor

ffi.cdef[[
typedef struct {
    float  x, y;
    float  vx, vy;
    int    color_idx;
    float  font_scale;
    float  duration;
    float  ts;
    int    alive;
    int    digits_len;
    int    width;
} DNum;
]]

local MAX_DNUMS = 300
local dnum_pool = ffi.new("DNum[?]", MAX_DNUMS)
local dnum_digits = {}
local dnum_write_cur = 0
local dnum_on_applied_impl
local dnum_draw_impl
local dnum_atlas_quads
local dnum_atlas_widths
local dnum_batch
local DNUM_MAX_CHARS = 12
local DNUM_BATCH_CAP = MAX_DNUMS * DNUM_MAX_CHARS * 2

for i = 0, MAX_DNUMS - 1 do
	dnum_pool[i].alive = 0
	dnum_digits[i] = {}
end

local dnum_palette = {
	{0.00, 0.00, 0.00}, -- shadow
	{1.00, 0.08, 0.08}, -- instakill
	{0.20, 1.00, 0.20}, -- poison
	{0.30, 0.70, 1.00}, -- electrical
	{1.00, 0.50, 0.80}, -- magical explosion
	{0.40, 0.50, 1.00}, -- magical
	{1.00, 0.45, 0.05}, -- explosion
	{1.00, 1.00, 0.10}, -- stab
	{0.90, 0.35, 0.20}, -- rude
	{0.50, 0.85, 1.00}, -- shot
	{1.00, 0.88, 0.50}, -- physical
	{0.30, 0.40, 0.92}, -- against magic armor
	{0.75, 0.75, 0.80}, -- against armor
	{0.00, 0.85, 0.85}, -- mixed
	{0.95, 0.95, 0.95}, -- true
	{1.00, 0.88, 0.55} -- default
}

local function dnum_color_index(dtype)
	if band(dtype, DAMAGE_INSTAKILL) ~= 0 then
		return 2
	elseif band(dtype, DAMAGE_POISON) ~= 0 then
		return 3
	elseif band(dtype, DAMAGE_ELECTRICAL) ~= 0 then
		return 4
	elseif band(dtype, DAMAGE_MAGICAL_EXPLOSION) ~= 0 then
		return 5
	elseif band(dtype, DAMAGE_MAGICAL) ~= 0 then
		return 6
	elseif band(dtype, DAMAGE_EXPLOSION) ~= 0 then
		return 7
	elseif band(dtype, DAMAGE_STAB) ~= 0 then
		return 8
	elseif band(dtype, DAMAGE_RUDE) ~= 0 then
		return 9
	elseif band(dtype, DAMAGE_SHOT) ~= 0 then
		return 10
	elseif band(dtype, DAMAGE_PHYSICAL) ~= 0 then
		return 11
	elseif band(dtype, DAMAGE_AGAINST_MAGIC_ARMOR) ~= 0 then
		return 12
	elseif band(dtype, DAMAGE_AGAINST_ARMOR) ~= 0 then
		return 13
	elseif band(dtype, DAMAGE_MIXED) ~= 0 then
		return 14
	elseif band(dtype, DAMAGE_TRUE) ~= 0 then
		return 15
	else
		return 16
	end
end

local function dnum_display_params(damage, hp_max)
	local ratio = (hp_max > 0) and (damage / hp_max) or 0
	local abs_score = damage * 0.001
	local score = (math.min(ratio, 1) + math.min(abs_score, 1)) * 0.5
	score = score ^ 0.7
	local font_scale = 0.45 + score * 0.55
	local duration = 0.70 + score * 0.70
	local vy = -30 + score * (-25)
	return font_scale, duration, vy
end

local dnum_set_color = G.setColor

local function dnum_build_atlas()
	local font_size = 30
	if IS_ANDROID then
		font_size = math.ceil(font_size / love.window.getDPIScale())
	end
	local font = require("lib.klove.font_db"):f("numbers_bold", font_size)

	local widths = {}
	local h = font:getHeight()
	local atlas_w = 0
	local color_count = #dnum_palette

	for i = 0, 9 do
		local c = tostring(i)
		local w = font:getWidth(c)
		widths[i] = w
		atlas_w = atlas_w + w
	end

	local canvas = G.newCanvas(atlas_w, h * color_count)
	local quads = {}

	G.push("all")
	G.setCanvas(canvas)
	G.clear(0, 0, 0, 0)
	G.setFont(font)
	for ci = 1, color_count do
		local p = dnum_palette[ci]
		local y = (ci - 1) * h
		local x = 0
		dnum_set_color(p[1], p[2], p[3], 1)
		quads[ci] = {}
		for i = 0, 9 do
			local c = tostring(i)
			local w = widths[i]
			G.print(c, x, y)
			quads[ci][i] = G.newQuad(x, y, w, h, atlas_w, h * color_count)
			x = x + w
		end
	end

	G.setCanvas()
	G.pop()

	dnum_atlas_quads = quads
	dnum_atlas_widths = widths
	dnum_batch = G.newSpriteBatch(canvas, DNUM_BATCH_CAP, "stream")
end

local function dnum_on_applied_disabled(store, d, target)
	return
end

local function dnum_draw_disabled(g)
	return
end

local function dnum_on_applied_enabled(store, d, target)
	if not target.pos then
		return
	end

	local hp_max = target.health.hp_max
	local font_scale, duration, vy = dnum_display_params(d.damage_applied, hp_max)

	if band(d.damage_result, DR_KILL) ~= 0 then
		font_scale = font_scale * 1.25
		duration = duration + 0.2
	end

	local color_idx = dnum_color_index(d.damage_type)

	local world_y = target.pos.y
	local unit = target.unit
	if unit then
		if unit.pop_offset then
			world_y = world_y + unit.pop_offset.y
		elseif unit.hit_offset then
			world_y = world_y + unit.hit_offset.y
		end
	end

	local slot = dnum_write_cur
	dnum_write_cur = (dnum_write_cur + 1) % MAX_DNUMS

	local n = dnum_pool[slot]
	n.x = target.pos.x + (random() - 0.5) * 20
	n.y = REF_H - world_y - 20
	n.vx = (random() - 0.5) * 8
	n.vy = vy - random() * 8
	n.color_idx = color_idx
	n.font_scale = font_scale
	n.duration = duration
	n.ts = store.tick_ts
	n.alive = 1

	local txt = tostring(floor(d.damage_applied))

	local digits = dnum_digits[slot]
	local len = #txt
	local tw = 0
	for i = 1, len do
		local digit = string.byte(txt, i) - 48
		digits[i] = digit

		tw = tw + dnum_atlas_widths[digit]
	end
	n.digits_len = len
	n.width = tw
end

local last_alpha = 1

local function dnum_draw_enabled(g)
	perf.start("damage number")
	local now = g.store.tick_ts
	local c = g.camera
	local zoom = c.zoom
	local gs = g.game_scale * zoom
	local rox = -(c.x * zoom - g.screen_w * 0.5)
	local roy = -(c.y * zoom - g.screen_h * 0.5)

	if g.store.world_offset then
		rox = rox + g.store.world_offset.x
		roy = roy + g.store.world_offset.y
	end

	dnum_batch:clear()

	for i = 0, MAX_DNUMS - 1 do
		local n = dnum_pool[i]
		if n.alive ~= 0 then
			local t = now - n.ts
			if t >= n.duration then
				n.alive = 0
			else
				local remain = 1 - t / n.duration
				local alpha = remain < 0.4 and (remain * 2.5) or 1

				local wx = n.x + n.vx * t
				local wy = n.y + n.vy * t + 12 * t * t
				local sx = wx * gs + rox
				local sy = wy * gs + roy
				local fs = n.font_scale
				if t < 0.12 then
					fs = fs * (1.5 - t * 4.66)
				end

				local len = n.digits_len
				local tw = n.width * fs
				local sx_c = floor(sx - tw * 0.5)
				local sy_f = floor(sy)
				local cursor = sx_c
				local digits = dnum_digits[i]
				local shadow_quads = dnum_atlas_quads[1]
				local color_quads = dnum_atlas_quads[n.color_idx]
				if last_alpha ~= alpha then
					dnum_batch:setColor(1, 1, 1, alpha)
					last_alpha = alpha
				end
				for j = 1, len do
					local digit = digits[j]
					local cw = dnum_atlas_widths[digit]

					dnum_batch:add(shadow_quads[digit], cursor + fs, sy_f + fs, 0, fs, fs)
					dnum_batch:add(color_quads[digit], cursor, sy_f, 0, fs, fs)
					cursor = cursor + cw * fs
				end
			end
		end
	end

	dnum_set_color(1, 1, 1, 1)
	G.draw(dnum_batch)
	dnum_set_color(1, 1, 1, 1)
	perf.stop("damage number")
end

dnum_on_applied_impl = dnum_on_applied_disabled
dnum_draw_impl = dnum_draw_disabled

local function dnum_init(store)
	dnum_write_cur = 0
	for i = 0, MAX_DNUMS - 1 do
		dnum_pool[i].alive = 0
	end
	if store.config.damage_numbers_enabled ~= false then
		if not dnum_batch then
			dnum_build_atlas()
		end
		dnum_on_applied_impl = dnum_on_applied_enabled
		dnum_draw_impl = dnum_draw_enabled
	else
		dnum_on_applied_impl = dnum_on_applied_disabled
		dnum_draw_impl = dnum_draw_disabled
	end
	store.damage_numbers_draw = dnum_draw_impl
end

--- 从 damage.source_id 沿 modifier.source_id / bullet.source_id 追溯
local function damage_trace_bullet_hints(s)
	local b = s.bullet

	if not b then
		return ""
	end

	local bits = {}

	if b.target_id then
		bits[#bits + 1] = "btgt#" .. tostring(b.target_id)
	end

	if b.source_id then
		bits[#bits + 1] = "bsrc#" .. tostring(b.source_id)
	end

	if #bits == 0 then
		return ""
	end

	return "[" .. table.concat(bits, ",") .. "]"
end

local function damage_trace_format_source(store, d)
	local entities = store.entities
	local parts = {}
	local sid = d.source_id

	if not sid then
		local o = "source_id=nil"

		if d.damage_trace_origin and d.damage_trace_origin ~= "" then
			o = o .. " || origin:" .. tostring(d.damage_trace_origin)
		end

		if d.damage_trace_extra and d.damage_trace_extra ~= "" then
			o = o .. " || extra:" .. tostring(d.damage_trace_extra)
		end

		return o
	end

	local seen = {}
	local depth = 0

	while sid and depth < 12 do
		if seen[sid] then
			parts[#parts + 1] = string.format("(cycle#%s)", tostring(sid))

			break
		end

		seen[sid] = true
		depth = depth + 1

		local s = entities[sid]

		if not s then
			parts[#parts + 1] = string.format("missing#%s", tostring(sid))

			break
		end

		local tags = {}

		if s.tower then
			tags[#tags + 1] = "tower"
		end

		if s.modifier then
			tags[#tags + 1] = "mod"
		end

		if s.bullet then
			tags[#tags + 1] = "bullet"
		end

		local tag_str = #tags > 0 and ("[" .. table.concat(tags, ",") .. "]") or ""
		local seg = string.format("%s%s#%s", s.template_name or "?", tag_str, tostring(sid))
		local bh = damage_trace_bullet_hints(s)

		if bh ~= "" then
			seg = seg .. bh
		end

		parts[#parts + 1] = seg

		if s.tower_ref and s.tower_ref.id then
			local tw = s.tower_ref

			parts[#parts + 1] = string.format("tower_ref=%s#%s", tw.template_name or "?", tostring(tw.id))
		end

		local next_id

		if s.modifier and s.modifier.source_id then
			next_id = s.modifier.source_id
		elseif s.bullet and s.bullet.source_id then
			next_id = s.bullet.source_id
		else
			break
		end

		sid = next_id
	end

	local out = table.concat(parts, " <- ")

	if out ~= "" and not string.find(out, " <- ", 1, true) and entities[d.source_id] and entities[d.source_id].tower and d.damage_trace_origin ~= "tower_skill_endless" then
		out = out .. " [hint:source is tower only; if unexpected, check modifier/bullet source_id or damage_trace_extra]"
	end

	if d.damage_trace_extra and d.damage_trace_extra ~= "" then
		out = (out ~= "" and out .. " || " or "") .. "extra:" .. tostring(d.damage_trace_extra)
	end

	if d.damage_trace_origin and d.damage_trace_origin ~= "" then
		out = (out ~= "" and out .. " || " or "") .. "origin:" .. tostring(d.damage_trace_origin)
	end

	return out
end

--- 是否纳入追溯：默认仅敌人；DEBUG_DAMAGE_TRACE_ALL_TARGETS 时含士兵/英雄等一切带 health 的实体
local function damage_trace_include_target(e)
	if not e or not e.health then
		return false
	end

	if DEBUG_DAMAGE_TRACE_ALL_TARGETS then
		return true
	end

	return e.enemy ~= nil
end

local function damage_trace_target_class(e)
	if not e then
		return "?"
	end

	if e.enemy then
		return "enemy"
	end

	if e.hero then
		return "hero"
	end

	if e.soldier then
		return "soldier"
	end

	if e.tower then
		return "tower"
	end

	return "unit"
end

local function damage_trace_investigate_print(store, target, d, val, branch)
	if not DEBUG_DAMAGE_TRACE_INVESTIGATE then
		return
	end

	if not damage_trace_include_target(target) then
		return
	end

	if (branch == "hp" or branch == "eat") and (not val or val <= 0) then
		return
	end

	local e = d.source_id and store.entities[d.source_id]
	local snap = "src_entity=missing"

	if e then
		local twref = ""

		if e.tower_ref and e.tower_ref.id then
			twref = string.format(" twref=%s#%s", tostring(e.tower_ref.template_name), tostring(e.tower_ref.id))
		end

		snap = string.format("src_tpl=%s tw=%s bl=%s mod=%s ray_bullet_id=%s bullet.bsrc=%s bullet.btgt=%s%s", tostring(e.template_name), tostring(e.tower ~= nil), tostring(e.bullet ~= nil), tostring(e.modifier ~= nil), tostring(e.ray_source_bullet_id), tostring(e.bullet and e.bullet.source_id), tostring(e.bullet and e.bullet.target_id), twref)
	end

	print(string.format("[DAMAGE_INVESTIGATE] tick=%.3f branch=%s src_id=%s tgt_kind=%s tgt_id=%s tgt=%s val=%.1f dtype=0x%X origin=%s extra=%s | %s", store.tick_ts, branch, tostring(d.source_id), damage_trace_target_class(target), tostring(d.target_id), target.template_name or "?", val or 0, d.damage_type or 0, tostring(d.damage_trace_origin), tostring(d.damage_trace_extra), snap))

	if e and e.tower and not d.damage_trace_origin then
		print("[DAMAGE_INVESTIGATE] hint: source_id points to TOWER but damage_trace_origin is empty — 请搜 SU.create_attack_damage、mod_dps、无尽技能等")
	end
end

--- branch: hp | eat | armor | magic_armor（覆盖 health 系统内各类伤害包）
local function damage_trace_record_event(store, target, d, branch, val, hp_before, hp_after)
	damage_trace_investigate_print(store, target, d, val, branch)

	if not DEBUG_DAMAGE_TRACE or not damage_trace_include_target(target) then
		return
	end

	local max_h = tonumber(DEBUG_DAMAGE_TRACE_HISTORY) or 32
	local rec = {
		tick_ts = store.tick_ts,
		branch = branch,
		dmg = val,
		hp_before = hp_before,
		hp_after = hp_after,
		dmg_type = d.damage_type,
		src = damage_trace_format_source(store, d),
		damage_trace_extra = d.damage_trace_extra,
		kill = (branch == "hp" or branch == "eat") and hp_before > 0 and hp_after <= 0 or false
	}

	target._damage_trace = target._damage_trace or {}
	local t = target._damage_trace

	t[#t + 1] = rec

	while #t > max_h do
		table.remove(t, 1)
	end

	if DEBUG_DAMAGE_TRACE_ALL_ENEMY_HITS then
		local px = target.pos and target.pos.x or 0
		local py = target.pos and target.pos.y or 0
		local cls = damage_trace_target_class(target)

		print(string.format("[DAMAGE_TRACE] %s %s#%s pos=(%.0f,%.0f) branch=%s val=%.1f hp %d->%d dtype=0x%X | %s", cls, target.template_name or "?", tostring(target.id), px, py, branch, val or 0, hp_before, hp_after, d.damage_type or 0, rec.src))
	end
end

local function damage_trace_print_death(store, target)
	if not DEBUG_DAMAGE_TRACE or not damage_trace_include_target(target) then
		return
	end

	local t = target._damage_trace

	if not t or #t == 0 then
		return
	end

	local cls = damage_trace_target_class(target)

	print(string.format("[DAMAGE_TRACE] ========== death %s %s#%s ==========", cls, target.template_name or "?", tostring(target.id)))

	for i = 1, #t do
		local r = t[i]

		print(string.format("  [%d] tick=%.3f branch=%s val=%.1f hp %d->%d dtype=0x%X kill=%s | %s", i, r.tick_ts, tostring(r.branch), r.dmg, r.hp_before, r.hp_after, r.dmg_type or 0, tostring(r.kill), r.src))
	end

	print("[DAMAGE_TRACE] ========== end death trace ==========")
end

local FADE_OUT_DURATION = 0.4

function M.register(sys)
	local function queue_insert(store, e)
		simulation:queue_insert_entity(e)
	end

	local function queue_remove(store, e)
		simulation:queue_remove_entity(e)
	end

	sys.health = {}
	sys.health.name = "health"

	function sys.health:init(store)
		store.damage_queue = {}
		store.damages_applied = {}
		dnum_init(store)
	end

	function sys.health:on_insert_unconditional(entity, store)
		if entity.health and not entity.health.hp then
			entity.health.hp = entity.health.hp_max
		end

		return true
	end

	function sys.health:on_update(dt, ts, store)
		perf.start("health")
		local new_damage_queue = {}
		local damage_queue = store.damage_queue
		local damages_applied = {}
		local damages_applied_count = 0
		local entities = store.entities
		local damage_queue_len = #damage_queue
		for i = damage_queue_len, 1, -1 do
			local d = damage_queue[i]
			local e = entities[d.target_id]

			if e then
				local h = e.health

				if not (h.dead or band(h.immune_to, d.damage_type) ~= 0 or h.ignore_damage or h.on_damage and not h.on_damage(e, store, d)) then
					local starting_hp = h.hp

					h.last_damage_types = bor(h.last_damage_types, d.damage_type)

					if band(d.damage_type, DAMAGE_EAT) ~= 0 then
						local eat_amt = math.max(h.hp, 0)

						d.damage_applied = eat_amt
						d.damage_result = bor(d.damage_result, DR_KILL)
						damage_trace_record_event(store, e, d, "eat", eat_amt, starting_hp, 0)
						h.hp = 0
						damages_applied_count = damages_applied_count + 1
						damages_applied[damages_applied_count] = d
						dnum_on_applied_impl(store, d, e)
					elseif band(d.damage_type, DAMAGE_ARMOR) ~= 0 then
						SU.armor_dec(e, d.value)
						d.damage_result = bor(d.damage_result, DR_ARMOR)
						damage_trace_record_event(store, e, d, "armor", d.value, h.hp, h.hp)
					elseif band(d.damage_type, DAMAGE_MAGICAL_ARMOR) ~= 0 then
						SU.magic_armor_dec(e, d.value)
						d.damage_result = bor(d.damage_result, DR_MAGICAL_ARMOR)
						damage_trace_record_event(store, e, d, "magic_armor", d.value, h.hp, h.hp)
					else
						local actual_damage = U.predict_damage(e, d)

						h.hp = h.hp - actual_damage
						d.damage_applied = actual_damage
						damage_trace_record_event(store, e, d, "hp", actual_damage, starting_hp, h.hp)

						if starting_hp > 0 and h.hp <= 0 then
							d.damage_result = bor(d.damage_result, DR_KILL)
						end

						if actual_damage > 0 then
							d.damage_result = bor(d.damage_result, DR_DAMAGE)

							if e.regen then
								e.regen.last_hit_ts = store.tick_ts
							end

							if d.track_damage then
								signal.emit("entity-damaged", e, d)

								local source = entities[d.source_id]

								if source and source.track_damage then
									source.track_damage.damaged[#source.track_damage.damaged + 1] = {e.id, actual_damage}
								end
							end
							dnum_on_applied_impl(store, d, e)
						end

						if h.spiked_armor > 0 and d.source_id then
							local t = entities[d.source_id]

							if t and t.health and not t.health.dead then
								local sad = E.create_damage()

								sad.damage_type = DAMAGE_TRUE
								sad.value = h.spiked_armor * d.value
								sad.source_id = e.id
								sad.target_id = t.id
								new_damage_queue[#new_damage_queue + 1] = sad
							end
						end

						if h.constant_spiked_armor and d.source_id then
							local t = entities[d.source_id]

							if t and t.health and not t.health.dead then
								local sad = E.create_damage()

								sad.damage_type = h.constant_spiked_armor.damage_type
								sad.value = h.constant_spiked_armor.value
								sad.source_id = e.id
								sad.target_id = t.id
								new_damage_queue[#new_damage_queue + 1] = sad
							end
						end

						damages_applied_count = damages_applied_count + 1
						damages_applied[damages_applied_count] = d
					end

					if starting_hp > 0 and h.hp <= 0 then
						signal.emit("entity-killed", e, d)

						if d.track_kills then
							local source = entities[d.source_id]

							if source and source.track_kills then
								source.track_kills.killed[#source.track_kills.killed + 1] = e.id
							end
						end
					end
				end
			end
		end

		local enemies = store.enemies
		local soldiers = store.soldiers

		for _, e in pairs(enemies) do
			local h = e.health

			if h.hp <= 0 and not h.dead and not h.ignore_damage then
				damage_trace_print_death(store, e)
				h.hp = 0
				h.dead = true
				h.death_ts = store.tick_ts

				if e.render then
					h.fading_after = store.tick_ts + h.dead_lifetime - FADE_OUT_DURATION
					h._fade_init_alphas = {}
					for i = 1, #e.render.sprites do
						h._fade_init_alphas[i] = e.render.sprites[i].alpha
					end
				else
					h.delete_after = store.tick_ts + h.dead_lifetime
				end

				if e.health_bar then
					e.health_bar.hidden = true
				end

				store.player_gold = store.player_gold + e.enemy.gold
				signal.emit("got-enemy-gold", e, e.enemy.gold)
			end

			if not h.dead then
				h.last_damage_types = 0
			elseif not h.ignore_delete_after then
				if h.fading_after and store.tick_ts > h.fading_after then
					local progress = (store.tick_ts - h.fading_after) / FADE_OUT_DURATION

					if progress >= 1.0 then
						queue_remove(store, e)
					else
						local sprites = e.render.sprites
						for i = 1, #sprites do
							sprites[i].alpha = h._fade_init_alphas[i] * (1 - progress)
						end
					end
				elseif h.delete_after and store.tick_ts > h.delete_after then
					queue_remove(store, e)
				end
			end
		end

		for _, e in pairs(soldiers) do
			local h = e.health

			if h.hp <= 0 and not h.dead and not h.ignore_damage then
				damage_trace_print_death(store, e)
				h.hp = 0
				h.dead = true
				h.death_ts = store.tick_ts

				if e.render then
					h.fading_after = store.tick_ts + h.dead_lifetime - FADE_OUT_DURATION
					h._fade_init_alphas = {}
					for i = 1, #e.render.sprites do
						h._fade_init_alphas[i] = e.render.sprites[i].alpha
					end
				else
					h.delete_after = store.tick_ts + h.dead_lifetime
				end

				if e.health_bar then
					e.health_bar.hidden = true
				end
			end

			if not h.dead then
				h.last_damage_types = 0
			elseif not e.hero and not h.ignore_delete_after then
				if h.fading_after and store.tick_ts > h.fading_after then
					local progress = (store.tick_ts - h.fading_after) / FADE_OUT_DURATION

					if progress >= 1.0 then
						queue_remove(store, e)
					else
						local sprites = e.render.sprites
						for i = 1, #sprites do
							sprites[i].alpha = h._fade_init_alphas[i] * (1 - progress)
						end
					end
				elseif h.delete_after and store.tick_ts > h.delete_after then
					queue_remove(store, e)
				end
			end
		end

		store.damage_queue = new_damage_queue

		for i = damage_queue_len + 1, #damage_queue do
			new_damage_queue[#new_damage_queue + 1] = damage_queue[i]
		end

		store.damages_applied = damages_applied
		perf.stop("health")
	end
end

return M
