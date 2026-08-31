-- 死亡管理，伤害结算，伤害追踪，伤害数字，治疗数字
local health = {}

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
local configer = require("dove_modules.configer")

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
} Num;
]]

local dnum_enabled = false
local hnum_enabled = false

local MAX_DNUMS = 300
local dnum_pool = ffi.new("Num[?]", MAX_DNUMS)
local dnum_digits = {}
local dnum_write_cur = 0
local dnum_on_applied_impl
local num_draw_impl
local dnum_atlas_quads
local dnum_atlas_widths

for i = 0, MAX_DNUMS - 1 do
	dnum_pool[i].alive = 0
	dnum_digits[i] = {}
end

local MAX_HNUMS = 100
local hnum_pool = ffi.new("Num[?]", MAX_HNUMS)
local hnum_digits = {}
local hnum_write_cur = 0
local hnum_on_applied_impl
local HNUM_COLOR = 17

for i = 0, MAX_HNUMS - 1 do
	hnum_pool[i].alive = 0
	hnum_digits[i] = {}
end

local num_batch
local num_palette = {
	{0.00, 0.00, 0.00}, -- shadow
	{1.00, 0.08, 0.08}, -- instakill/eat
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
	{1.00, 0.88, 0.55}, -- default
	{0.30, 1.00, 0.30} -- heal
}

local NUM_MAX_CHARS = 12
local NUM_BATCH_CAP = (MAX_DNUMS + MAX_HNUMS) * NUM_MAX_CHARS * 2

local function dnum_color_index(dtype)
	if band(dtype, DAMAGE_INSTAKILL) ~= 0 or band(dtype, DAMAGE_EAT) ~= 0 then
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

local FONT_SCALE_FACTOR = IS_ANDROID and 1.3 or 1.0

local function dnum_display_params(damage, hp_max)
	local ratio = (hp_max > 0) and (damage / hp_max) or 0
	local abs_score = damage * 0.001
	local score = (math.min(ratio, 1) + math.min(abs_score, 1)) * 0.5
	score = score ^ 0.7
	local font_scale = 0.45 + score * 0.55
	local duration = 0.70 + score * 0.70
	local vy = -30 + score * (-25)
	return font_scale * FONT_SCALE_FACTOR, duration, vy
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
	local color_count = #num_palette

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
		local p = num_palette[ci]
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
	num_batch = G.newSpriteBatch(canvas, NUM_BATCH_CAP, "stream")
end

local function dnum_on_applied_disabled(store, d, target)
	return
end

local function num_draw_disabled(g)
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

	local txt = tostring(math.ceil(d.damage_applied))

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

local function num_draw_enabled(g)
	perf.start("number")
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

	num_batch:clear()

	if dnum_enabled then
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
						num_batch:setColor(1, 1, 1, alpha)
						last_alpha = alpha
					end
					for j = 1, len do
						local digit = digits[j]
						local cw = dnum_atlas_widths[digit]

						num_batch:add(shadow_quads[digit], cursor + fs, sy_f + fs, 0, fs, fs)
						num_batch:add(color_quads[digit], cursor, sy_f, 0, fs, fs)
						cursor = cursor + cw * fs
					end
				end
			end
		end
	end

	if hnum_enabled then
		for i = 0, MAX_HNUMS - 1 do
			local n = hnum_pool[i]
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
					local digits = hnum_digits[i]
					local shadow_quads = dnum_atlas_quads[1]
					local color_quads = dnum_atlas_quads[n.color_idx]
					if last_alpha ~= alpha then
						num_batch:setColor(1, 1, 1, alpha)
						last_alpha = alpha
					end
					for j = 1, len do
						local digit = digits[j]
						local cw = dnum_atlas_widths[digit]
						num_batch:add(shadow_quads[digit], cursor + fs, sy_f + fs, 0, fs, fs)
						num_batch:add(color_quads[digit], cursor, sy_f, 0, fs, fs)
						cursor = cursor + cw * fs
					end
				end
			end
		end
	end

	dnum_set_color(1, 1, 1, 1)
	G.draw(num_batch)
	dnum_set_color(1, 1, 1, 1)
	perf.stop("number")
end

dnum_on_applied_impl = dnum_on_applied_disabled

local function dnum_init(store)
	dnum_write_cur = 0
	for i = 0, MAX_DNUMS - 1 do
		dnum_pool[i].alive = 0
	end
	dnum_enabled = configer.ui_settings().damage_numbers_enabled ~= false
	if dnum_enabled then
		if not num_batch then
			dnum_build_atlas()
		end
		dnum_on_applied_impl = dnum_on_applied_enabled
	else
		dnum_on_applied_impl = dnum_on_applied_disabled
	end
end

local function hnum_on_applied_disabled(store, target, heal_amount)
end

local function hnum_draw_disabled(g)
end

local function hnum_on_applied_enabled(store, target, heal_amount)
	if not target.pos then
		return
	end

	local hp_max = target.health and target.health.hp_max or 0
	local font_scale, duration, vy = dnum_display_params(heal_amount, hp_max)

	local world_y = target.pos.y
	local health_bar = target.health_bar
	if health_bar then
		world_y = world_y + health_bar.offset.y
	end

	local slot = hnum_write_cur
	hnum_write_cur = (hnum_write_cur + 1) % MAX_HNUMS

	local n = hnum_pool[slot]
	n.x = target.pos.x + (random() - 0.5) * 20
	n.y = REF_H - world_y - 20
	n.vx = (random() - 0.5) * 8
	n.vy = vy - random() * 8
	n.color_idx = HNUM_COLOR
	n.font_scale = font_scale
	n.duration = duration
	n.ts = store.tick_ts
	n.alive = 1

	local txt = tostring(math.ceil(heal_amount))
	local digits = hnum_digits[slot]
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

hnum_on_applied_impl = hnum_on_applied_disabled

local function hnum_init(store)
	hnum_write_cur = 0
	for i = 0, MAX_HNUMS - 1 do
		hnum_pool[i].alive = 0
	end
	hnum_enabled = configer.ui_settings().heal_numbers_enabled ~= false
	if hnum_enabled then
		if not num_batch then
			dnum_build_atlas()
		end
		hnum_on_applied_impl = hnum_on_applied_enabled
	else
		hnum_on_applied_impl = hnum_on_applied_disabled
	end
	U.hnum_on_applied_impl = function(target, heal_amount)
		hnum_on_applied_impl(store, target, heal_amount)
	end
end

local damage_trace_table = {}
local damage_trace_waves = {}

local damage_trace

local function damage_trace_name(e)
	return e.info and e.info.i18n_key and _(e.info.i18n_key .. "_NAME") or _(string.upper(e.template_name) .. "_NAME")
end

local function damage_trace_add(bucket, entity, sub_key, damage_type, value)
	local template_name = entity.template_name
	local entry = bucket[template_name]

	if not entry then
		entry = {
			name = damage_trace_name(entity),
			applied_effective_damage = {},
			received_total_damage = {}
		}
		bucket[template_name] = entry
	end

	local sub = entry[sub_key]

	if not sub[damage_type] then
		sub[damage_type] = 0
	end

	sub[damage_type] = sub[damage_type] + value
end

local function damage_trace_wave_bucket(wave)
	local bucket = damage_trace_waves[wave]

	if not bucket then
		bucket = {}
		damage_trace_waves[wave] = bucket
	end

	return bucket
end

local function damage_trace_disabled(store, d, e)
end

local function damage_trace_enabled(store, d, e)
	local wave_bucket = damage_trace_wave_bucket(store.wave_group_number or 0)

	if d.source_id then
		local source = store.entities[d.source_id]

		if source then
			local root = store.root_entity_map[source.id] or source
			local value = math.min(d.damage_applied, math.max(e.health.hp, 0))

			damage_trace_add(damage_trace_table, root, "applied_effective_damage", d.damage_type, value)
			damage_trace_add(wave_bucket, root, "applied_effective_damage", d.damage_type, value)
		end
	end

	local damage_taken = 0

	if e.health.hp > 0 then
		damage_taken = (band(d.damage_type, bor(DAMAGE_INSTAKILL, DAMAGE_EAT)) ~= 0 and d.damage_applied or d.value) * math.min(e.health.hp / d.damage_applied, 1)
	end

	local root_target = store.root_entity_map[e.id] or e

	damage_trace_add(damage_trace_table, root_target, "received_total_damage", d.damage_type, damage_taken)
	damage_trace_add(wave_bucket, root_target, "received_total_damage", d.damage_type, damage_taken)
end

local function damage_trace_init(store)
	if configer.ui_settings().damage_trace_enabled then
		damage_trace = damage_trace_enabled
		damage_trace_table = {}
		damage_trace_waves = {}
		store.damage_trace_table = damage_trace_table
		store.damage_trace_waves = damage_trace_waves
		-- 记录实体 id -> 实体的根实体的映射关系
		store.root_entity_map = {}

		function health:on_queue_unconditional(e, d)
			if d._dominant_entity then
				local parent = d._dominant_entity
				-- 如果创建该实体的实体拥有根实体，则将 parent 指向其根实体
				if store.root_entity_map[parent.id] then
					parent = store.root_entity_map[parent.id]
				end

				if not e.enemy or (e.enemy and parent.enemy) then
					store.root_entity_map[e.id] = parent
				end
			end
		end

		-- 清理引用，避免内存泄露
		function health:on_remove_unconditional(e, store)
			store.root_entity_map[e.id] = nil
		end
	else
		damage_trace = damage_trace_disabled
		damage_trace_table = nil
		damage_trace_waves = nil
		store.damage_trace_table = nil
		store.damage_trace_waves = nil
		store.root_entity_map = nil
		health.on_queue_unconditional = nil
		health.on_remove_unconditional = nil
	end
end

-- local FADE_OUT_DURATION = 0.4
require("table.clear")
local GS = require("kr1.game_settings")

health.name = "health"

function health:init(store)
	store.damage_queue = {}
	store.damage_queue_swapper = {}
	dnum_init(store)
	hnum_init(store)
	damage_trace_init(store)
	if dnum_enabled or hnum_enabled then
		num_draw_impl = num_draw_enabled
	else
		num_draw_impl = num_draw_disabled
	end
	store.numbers_draw = num_draw_impl
end

function health:on_insert_unconditional(entity, store)
	if entity.health then
		if not entity.health.hp then
			entity.health.hp = entity.health.hp_max
		end
		if entity.regen then
			if not entity.regen.health then
				entity.regen.health = math.ceil(entity.health.hp_max * GS.soldier_regen_factor)
			end
		end
	end
end

function health.on_damage_applied(store, d, e)
	dnum_on_applied_impl(store, d, e)
	-- pops system begin
	if d.pop then
		local source = store.entities[d.source_id]
		local pop_entity = (source and (source.enemy or source.soldier)) and source or e
		if pop_entity then
			local pop_chance = d.pop_chance
			local pop_conds = d.pop_conds
			if (not pop_chance or random() < pop_chance) and (not pop_conds or band(d.damage_result, pop_conds) ~= 0) then
				local name = d.pop[random(1, #d.pop)]
				local pop = E:create_entity(name)

				if pop.pop_over_target then
					pop_entity = e
				end

				local pos_y = pop_entity.pos.y + pop.pop_y_offset

				if pop_entity.unit then
					if pop_entity.unit.pop_offset then
						pos_y = pos_y + pop_entity.unit.pop_offset.y
					elseif pop_entity == e and pop_entity.unit.hit_offset then
						pos_y = pos_y + pop_entity.unit.hit_offset.y
					end
				end

				pop.pos:set(pop_entity.pos.x, pos_y)
				pop.render.sprites[1].r = random(-21, 21) * 0.017453292519943295
				pop.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(pop)
			end
		end
	end
	-- pops system end

	-- hero_xp_tracking system begin
	if d.xp_gain_factor then
		local id = d.xp_dest_id or d.source_id
		local source = store.entities[id]

		if source and source.hero then
			local amount = d.damage_applied * d.xp_gain_factor
			source.hero.xp_queued = source.hero.xp_queued + amount
		end
	end
-- hero_xp_tracking system end
end

function health:on_update(dt, ts, store)
	perf.start("health")
	local new_damage_queue = store.damage_queue_swapper
	table.clear(new_damage_queue)

	local damage_queue = store.damage_queue
	local damage_queue_len = #damage_queue

	local entities = store.entities
	for i = 1, damage_queue_len do
		local d = damage_queue[i]
		local e = entities[d.target_id]

		if e then
			local h = e.health

			if not (h.dead or band(h.immune_to, d.damage_type) ~= 0 or h.ignore_damage or h.on_damage and not h.on_damage(e, store, d)) then
				local starting_hp = h.hp

				h.last_damage_types = bor(h.last_damage_types, d.damage_type)

				if band(d.damage_type, DAMAGE_ARMOR) ~= 0 then
					SU.armor_dec(e, d.value)
					d.damage_result = bor(d.damage_result, DR_ARMOR)
				elseif band(d.damage_type, DAMAGE_MAGICAL_ARMOR) ~= 0 then
					SU.magic_armor_dec(e, d.value)
					d.damage_result = bor(d.damage_result, DR_MAGICAL_ARMOR)
				else
					if band(d.damage_type, DAMAGE_EAT) ~= 0 then
						local eat_amt = math.max(h.hp, 0)
						d.damage_applied = eat_amt
						d.damage_result = bor(d.damage_result, DR_KILL)
						damage_trace(store, d, e)
						h.hp = 0
						self.on_damage_applied(store, d, e)
					else
						local actual_damage = U.predict_damage(e, d)

						if actual_damage > 0 then
							d.damage_applied = actual_damage
							d.damage_result = bor(d.damage_result, DR_DAMAGE)
							damage_trace(store, d, e)

							if e.regen then
								e.regen.last_hit_ts = ts
							end

							h.hp = h.hp - actual_damage
							if starting_hp > 0 and h.hp <= 0 then
								d.damage_result = bor(d.damage_result, DR_KILL)
							end

							if d.track_damage then
								signal.emit("entity-damaged", e, d)

								local source = entities[d.source_id]

								if source and source.track_damage then
									source.track_damage.damaged[#source.track_damage.damaged + 1] = {e.id, actual_damage}
								end
							end
							self.on_damage_applied(store, d, e)
						end

						if h.spiked_armor > 0 and d.source_id then
							local t = entities[d.source_id]

							if t and t.health and not t.health.dead then
								new_damage_queue[#new_damage_queue + 1] = E.assign_damage(DAMAGE_TRUE, h.spiked_armor * d.value, e.id, t.id)
							end
						end

						if h.constant_spiked_armor and d.source_id then
							local t = entities[d.source_id]

							if t and t.health and not t.health.dead then
								new_damage_queue[#new_damage_queue + 1] = E.assign_damage(h.constant_spiked_armor.damage_type, h.constant_spiked_armor.value, e.id, t.id)
							end
						end
					end

					-- 处理击杀
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
	end

	for i = damage_queue_len + 1, #damage_queue do
		new_damage_queue[#new_damage_queue + 1] = damage_queue[i]
	end

	store.damage_queue_swapper = damage_queue
	store.damage_queue = new_damage_queue

	local soldiers = store.soldiers

	for _, e in pairs(soldiers) do
		local h = e.health

		if h.hp <= 0 and not h.dead and not h.ignore_damage then
			h.hp = 0
			h.dead = true
			h.death_ts = ts

			if e.render then
				h.fading_after = ts + h.dead_lifetime - 0.4
			else
				h.delete_after = ts + h.dead_lifetime
			end

			if e.health_bar then
				e.health_bar.hidden = true
			end
		end

		if not h.dead then
			h.last_damage_types = 0
		elseif not e.hero and not h.ignore_delete_after then
			if h.fading_after and ts > h.fading_after then
				local progress = (ts - h.fading_after) / 0.4

				if progress >= 1.0 then
					simulation:queue_remove_entity(e)
				else
					local sprites = e.render.sprites
					if not h._fade_init_alphas then
						h._fade_init_alphas = {}
						for i = 1, #sprites do
							h._fade_init_alphas[i] = sprites[i].alpha
						end
					end
					for i = 1, #sprites do
						sprites[i].alpha = h._fade_init_alphas[i] * (1 - progress)
					end
				end
			elseif h.delete_after and ts > h.delete_after then
				simulation:queue_remove_entity(e)
			end
		end
	end

	perf.stop("health")
end

-- 供其他模块复用伤害数字的伤害类型 -> 颜色映射（单一数据源）
health.damage_color_index = dnum_color_index
health.damage_color_palette = num_palette

return health
