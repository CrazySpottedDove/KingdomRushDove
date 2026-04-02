-- chunkname: @./all/endless_scripts.lua
require("lib.klua.table")
require("i18n")
require("all.constants")

local log = require("lib.klua.log"):new("endless_scripts")
local km = require("lib.klua.macros")
local E = require("entity_db")
local P = require("path_db")
local SU = require("script_utils")
local U = require("utils")
-- local V = require("lib.klua.vector")
local V = require("lib.klua.vector")
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local v = V.v

local function queue_insert(store, e)
	simulation:queue_insert_entity(e)
end

local function queue_remove(store, e)
	simulation:queue_remove_entity(e)
end

local function queue_damage(store, damage)
	store.damage_queue[#store.damage_queue + 1] = damage
end

local scripts = require("scripts")

scripts.arrow_endless_multishot = {}

function scripts.arrow_endless_multishot.insert(this, store)
	if this._endless_multishot > 0 then
		local targets = U.find_enemies_in_range_filter_off(this.bullet.to, 100, this.bullet.vis_flags, this.bullet.vis_bans)
		if targets then
			for i = 1, this._endless_multishot do
				local target = targets[km.zmod(i, #targets)]

				if target then
					local b = E:clone_entity(this)

					b._endless_multishot = 0
					b.bullet.from = V.vclone(this.pos)
					b.bullet.to.x = target.pos.x + target.unit.hit_offset.x
					b.bullet.to.y = target.pos.y + target.unit.hit_offset.y
					b.bullet.target_id = target.id

					queue_insert(store, b)
				end
			end
		end
	end

	return true
end

scripts.decal_catapult_endless = {}

function scripts.decal_catapult_endless.update(this, store)
	local start_ts
	local a = this.ranged.attacks[1]
	local s2 = this.render.sprites[2]

	this.x_outside = this.pos.x

	while true do
		this.phase_signal = nil
		this.phase = "out"

		while this.phase_signal == nil do
			coroutine.yield()
		end

		local ms = a.munition_settings[a.munition_type]

		s2.prefix = ms[a.count == 1 and 0 or 1]
		a.bullet = ms.bullet
		this.phase = "enter"

		U.animation_start(this, "running", true, store.tick_ts, true)
		U.y_ease_key(store, this.pos, "x", this.x_outside, this.x_inside, this.transit_time)

		this.phase = "in"
		start_ts = store.tick_ts

		U.animation_start(this, "idle", true, store.tick_ts, true)

		while store.tick_ts - start_ts < this.duration do
			if store.tick_ts - a.ts > a.cooldown then
				local dest, d_pi, d_spi, d_ni, target

				if a.munition_type == 3 then
					dest, d_pi, d_spi, d_ni = P:get_random_position(a.path_margins, TERRAIN_LAND, nil, true)
				else
					local targets = table.filter(store.entities, function(k, v)
						return not v.pending_removal and v.health and not v.health.dead and v.vis and band(v.vis.flags, a.vis_bans) == 0 and band(v.vis.bans, a.vis_flags) == 0 and v.pos.x < a.max_x and v.pos.y > a.min_x
					end)

					if #targets > 0 then
						local stunned = table.filter(targets, function(k, v)
							return v.unit.is_stunned
						end)

						target = table.random(#stunned > 0 and stunned or targets)
						dest = target.pos

						local nodes = P:nearest_nodes(dest.x, dest.y)

						if #nodes > 0 then
							d_pi, d_spi, d_ni = unpack(nodes[1])
						end
					end
				end

				if not d_pi then
					log.warning("%s: node for shooting not found", this.template_name)
				else
					local an, af, ai = U.animation_name_facing_point(this, a.animation, dest)

					U.animation_start(this, an, af, store.tick_ts, false)
					U.y_wait(store, a.shoot_time)

					local n_offsets = {0, -5, 5, -10, 10}

					for i = 1, a.count do
						local d = P:node_pos(d_pi, d_spi, d_ni + n_offsets[i])
						local b = E:create_entity(a.bullet)

						b.pos = V.vclone(this.pos)

						local offset = a.bullet_start_offset[ai]

						b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y
						b.bullet.from = V.vclone(b.pos)
						b.bullet.to = V.vclone(d)

						if a.munition_type == 3 then
							local e = E:create_entity(a.barrel_payloads[a.barrel_payload_idx])

							e.nav_path.pi = d_pi
							e.nav_path.spi = d_spi
							e.nav_path.ni = d_ni + 3
							b.bullet.hit_payload = e
						end

						queue_insert(store, b)
					end

					U.y_animation_wait(this)
					U.animation_start(this, "idle", nil, store.tick_ts)

					a.ts = store.tick_ts
				end
			end

			coroutine.yield()
		end

		this.phase = "exit"

		U.animation_start(this, "running", false, store.tick_ts, true)
		U.y_ease_key(store, this.pos, "x", this.x_inside, this.x_outside, this.transit_time)
	end
end

scripts.endless_barrack_synergy_aura = {}

function scripts.endless_barrack_synergy_aura.insert(this, store)
	local source = store.entities[this.aura.source_id]

	if not source then
		return false
	end

	this.aura.ts = store.tick_ts
	this.pos = source.pos

	return true
end

function scripts.endless_barrack_synergy_aura.update(this, store)
	local last_hit_ts = store.tick_ts - this.aura.cycle_time

	while true do
		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
			local towers = U.find_towers_in_range(store.towers, this.pos, {
				min_range = 0,
				max_range = this.aura.radius
			})

			if towers then
				for _, t in pairs(towers) do
					local m = E:create_entity(this.aura.mod)

					m.modifier.target_id = t.id
					m.modifier.source_id = this.id
					m.template_name = m.template_name .. tostring(this.id)

					queue_insert(store, m)
				end
			end

			last_hit_ts = store.tick_ts
		end

		coroutine.yield()
	end
end

scripts.mod_endless_barrack_synergy = {}

function scripts.mod_endless_barrack_synergy.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return false
	end

	SU.insert_tower_damage_factor_buff(target, this.extra_damage)

	this.modifier.ts = store.tick_ts

	return true
end

function scripts.mod_endless_barrack_synergy.update(this, store)
	while this.modifier.ts + this.modifier.duration > store.tick_ts do
		coroutine.yield()
	end

	queue_remove(store, this)

	return
end

function scripts.mod_endless_barrack_synergy.remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target then
		SU.remove_tower_damage_factor_buff(target, this.extra_damage)
	end

	return true
end

scripts.mod_endless_engineer_aftermath = {
	insert = function(this, store)
		local target = store.entities[this.modifier.target_id]

		if not target then
			return false
		end

		local enemies = U.find_enemies_in_range_filter_off(target.pos, this.radius, F_RANGED, 0)

		if enemies then
			for i = 1, #enemies do
				local e = enemies[i]
				local d = E:create_entity("damage")

				d.damage_type = DAMAGE_EXPLOSION
				d.value = this.value
				d.source_id = this.id
				d.target_id = e.id

				queue_damage(store, d)
			end
		end

		local decal = E:create_entity("decal_tween")

		decal.pos.x, decal.pos.y = target.pos.x, target.pos.y
		decal.tween.props[1].keys = {{0, 255}, {0.5, 128}, {1, 0}}
		decal.tween.props[1].name = "alpha"

		if math.random() < 0.5 then
			decal.render.sprites[1].name = "EarthquakeTower_HitDecal1"
		else
			decal.render.sprites[1].name = "EarthquakeTower_HitDecal2"
		end

		decal.render.sprites[1].animated = false
		decal.render.sprites[1].z = Z_DECALS
		decal.render.sprites[1].ts = store.tick_ts
		decal.render.sprites[1].scale = v(0.6, 0.6)

		queue_insert(store, decal)

		return false
	end
}
scripts.aura_endless_engineer_aftermath_ray = {
	update = function(this, store)
		local a = this.aura
		local ps = E:create_entity(this.particles_name)

		ps.pos = V.vclone(this.pos)
		ps.particle_system.scales_x = {0.8, 0.36}
		ps.particle_system.scales_y = {0.8, 0.36}

		queue_insert(store, ps)
		U.y_wait(store, a.duration)

		local targets = U.find_enemies_in_range_filter_off(this.pos, a.radius, a.vis_flags, a.vis_bans)

		if targets then
			for _, e in pairs(targets) do
				local d = SU.create_attack_damage(a, e.id, this)

				queue_damage(store, d)
			end
		end

		queue_remove(store, this)
	end
}
scripts.endless_mage_thunder = {}

function scripts.endless_mage_thunder.update(this, store)
	local function create_thunder(thunder, pos)
		local e = E:create_entity("fx_power_thunder_" .. math.random(1, 2))

		e.pos.x, e.pos.y = pos.x, pos.y
		e.render.sprites[1].flip_x = math.random() < 0.5
		e.render.sprites[1].ts = store.tick_ts
		e.render.sprites[1].scale = v(0.8, 0.8)

		if REF_H - pos.y > e.image_h then
			e.render.sprites[1].scale = v(0.8, (REF_H - pos.y) / e.image_h)
		end

		queue_insert(store, e)

		e = E:create_entity("fx_power_thunder_explosion")
		e.pos.x, e.pos.y = pos.x, pos.y
		e.render.sprites[1].ts = store.tick_ts
		e.render.sprites[1].scale = v(0.8, 0.8)
		e.render.sprites[2].ts = store.tick_ts
		e.render.sprites[2].scale = v(0.8, 0.8)

		queue_insert(store, e)

		e = E:create_entity("fx_power_thunder_explosion_decal")
		e.pos.x, e.pos.y = pos.x, pos.y
		e.render.sprites[1].ts = store.tick_ts
		e.render.sprites[1].scale = v(0.8, 0.8)

		queue_insert(store, e)

		if thunder.pop and math.random() < thunder.pop_chance then
			local e = SU.create_pop(store, this.pos, thunder.pop)

			queue_insert(store, e)
		end

		local targets = U.find_enemies_in_range_filter_off(pos, thunder.damage_radius, this.vis_flags, this.vis_bans)

		if targets then
			for _, target in pairs(targets) do
				local d = E:create_entity("damage")

				d.damage_type = thunder.damage_type
				d.value = math.random(thunder.damage_min, thunder.damage_max)
				d.target_id = target.id
				d.source_id = this.id

				SU.magic_armor_dec(target, 0.01)
				queue_damage(store, d)
			end
		end
	-- AC:inc_check("LIGHTNING_CAST")
	end

	local visited = {}
	local t1, t2 = this.thunders[1], this.thunders[2]

	t1.created, t2.created = 0, 0

	if t2.count > 0 then
		t2.cooldown = U.frandom(t2.delay_min, t2.delay_max)
		t2.ts = store.tick_ts
	end

	while t1.created < t1.count or t2.created < t2.count do
		for _, thunder in pairs(this.thunders) do
			if thunder.created < thunder.count and store.tick_ts - thunder.ts > thunder.cooldown then
				local pos

				if thunder.targeting == "nearest" then
					if thunder.created == 0 then
						pos = this.pos
					else
						local target = U.find_nearest_enemy(store, this.pos, 0, thunder.range, this.vis_flags, this.vis_bans, function(v)
							return not table.contains(visited, v)
						end)

						if target then
							table.insert(visited, target)

							pos = target.pos
						else
							local nearest = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

							if #nearest > 0 then
								local pi, spi, ni = unpack(nearest[1])
								local no = math.random(-this.nodes_spread, this.nodes_spread)

								if not P:is_node_valid(pi, ni + no) then
									no = 0
								end

								pos = P:node_pos(pi, math.random(1, 3), ni + no)
							end
						end
					end
				else
					local target = U.find_random_enemy(store, this.pos, 0, thunder.range, this.vis_flags, this.vis_bans)

					if target then
						pos = target.pos
					else
						pos = P:get_random_position(10, bor(TERRAIN_LAND, TERRAIN_WATER)) or this.pos
					end
				end

				if pos then
					create_thunder(thunder, pos)
				end

				thunder.ts = store.tick_ts
				thunder.cooldown = U.frandom(thunder.delay_min, thunder.delay_max)
				thunder.created = thunder.created + 1
			end
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

return scripts
