local scripts = require("scripts")
local E = require("entity_db")
local GR = require("grid_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local bit = require("bit")
local HU = require("hero_utils")
local km = require("lib.klua.macros")
local signal = require("lib.hump.signal")
local log = require("lib.klua.log"):new("hero_scripts")
local band = bit.band
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local tt

local function bolt_hero_dragon_gem_attack_update(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local mspeed = b.min_speed
	local ps
	local new_target = false
	local target_invalid = false
	local target = store.entities[b.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	local is_flying = U.flag_has(target.vis.flags, F_FLYING)

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	if is_flying then
		b.hit_fx = b.hit_fx_flying
		b.ignore_hit_offset = false
	else
		b.hit_fx = b.hit_fx_floor
		b.ignore_hit_offset = true
	end

	::label_376_0::

	if b.store and not b.target_id then
		S:queue(this.sound_events.summon)

		s.z = Z_OBJECTS
		s.sort_y_offset = b.store_sort_y_offset

		U.animation_start_default(this, "idle", nil, store.tick_ts, true)

		if ps then
			ps.particle_system.emit = false
		end
	else
		S:queue(this.sound_events.travel)

		s.z = Z_BULLETS
		s.sort_y_offset = nil

		U.animation_start_default(this, "flying", nil, store.tick_ts, s.loop)

		if ps then
			ps.particle_system.emit = true
		end
	end

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		coroutine.yield()

		if not target_invalid then
			target = store.entities[b.target_id]
		end

		if target and not new_target then
			local tpx, tpy = target.pos.x, target.pos.y

			if not b.ignore_hit_offset then
				tpx, tpy = tpx + target.unit.hit_offset.x, tpy + target.unit.hit_offset.y
			end

			local d = math.max(math.abs(tpx - b.to.x), math.abs(tpy - b.to.y))

			if d > b.max_track_distance or band(target.vis.bans, F_RANGED) ~= 0 then
				target_invalid = true
				target = nil
			end
		end

		if target and target.health and not target.health.dead then
			if b.ignore_hit_offset then
				b.to.x, b.to.y = target.pos.x, target.pos.y
			else
				b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
			end

			new_target = false
		end

		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length

		if not b.ignore_rotation then
			s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
		end

		if ps then
			ps.particle_system.emit_direction = s.r
		end
	end

	while b.store and not b.target_id do
		coroutine.yield()

		if b.target_id then
			mspeed = b.min_speed
			new_target = true

			goto label_376_0
		end
	end

	this.pos.x, this.pos.y = b.to.x, b.to.y

	S:queue(this.sound_hit)

	local function explosion(r, damage_min, damage_max, dty)
		local target_bans = bit.bor(F_FLYING)
		local target_pos = V.vclone(this.pos)

		if is_flying then
			target_bans = 0

			if target then
				if target.flight_height then
					target_pos.y = target_pos.y - target.flight_height
				elseif target.unit.hit_offset then
					target_pos.y = target_pos.y - target.unit.hit_offset.y
				end
			end
		end

		local targets = U.find_enemies_in_range_filter_off(target_pos, r, 0, target_bans)

		if targets then
			for _, target in ipairs(targets) do
				local d = E.assign_damage(dty, math.random(damage_min, damage_max) * b.damage_factor, b.source_id, target.id)

				d.xp_gain_factor = b.xp_gain_factor
				d.xp_dest_id = b.source_id

				queue_damage(store, d)
			end
		end
	end

	local p = SU.create_bullet_pop(store, this)

	if p then
		simulation:queue_insert_entity(p)
	end

	explosion(this.damage_range, b.damage_min, b.damage_max, b.damage_type)

	if not is_flying and b.payload then
		for _, v in ipairs(b.payload) do
			local hp

			if type(v) == "string" then
				hp = E:create_entity(v)
			else
				hp = v
			end

			hp.pos.x, hp.pos.y = b.to.x, b.to.y
			hp.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(hp)
		end
	end

	if b.hit_fx then
		local sfx = E:create_entity(b.hit_fx)

		sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
		sfx.render.sprites[1].ts = store.tick_ts
		sfx.render.sprites[1].runs = 0

		if target and sfx.render.sprites[1].size_names then
			sfx.render.sprites[1].name = sfx.render.sprites[1].size_names[target.unit.size]
		end

		simulation:queue_insert_entity(sfx)
	end

	simulation:queue_remove_entity(this)
end

local function controller_hero_dragon_gem_skill_floor_impact_spawner_update(this, store)
	local function spawn_shard(pos)
		pos.x = pos.x + math.random(-4, 4)
		pos.y = pos.y + math.random(-5, 5)

		local s = E:create_entity(this.entity)

		s.pos = V.vclone(pos)
		s.dragon_pos = V.vclone(this.pos)

		simulation:queue_insert_entity(s)
	end

	for i = 1, #this.shards do
		spawn_shard(this.shards[i])
		U.y_wait_unconditional(store, fts(1))
	end

	simulation:queue_remove_entity(this)
end

local function bullet_hero_dragon_gem_ultimate_shard_update(this, store)
	local b = this.bullet
	local speed = b.max_speed

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) >= 2 * (speed * store.tick_length) do
		b.speed.x, b.speed.y = V.mul(speed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = 0

		coroutine.yield()
	end

	local targets = U.find_targets_in_range(store.enemies, b.to, 0, b.damage_radius, b.damage_flags, b.damage_bans)

	if targets then
		for _, target in ipairs(targets) do
			local d = E.assign_damage(b.damage_type, b.damage_max * b.damage_factor, this.id, target.id)

			queue_damage(store, d)

			if b.mod then
				local mod = E:create_entity(b.mod)

				mod.modifier.target_id = target.id
				mod.modifier.damage_factor = b.damage_factor

				simulation:queue_insert_entity(mod)
			end
		end
	end

	if b.hit_fx then
		SU.insert_sprite(store, b.hit_fx, this.pos)
	end

	if b.arrive_decal then
		local decal = E:create_entity(b.arrive_decal)

		decal.pos:copy(b.to)

		decal.render.sprites[1].ts = store.tick_ts
		decal.tween.ts = store.tick_ts

		simulation:queue_insert_entity(decal)
	end

	simulation:queue_remove_entity(this)
end

local function mod_hero_dragon_gem_crystal_instakill_update(this, store)
	local start_ts, target_hidden
	local m = this.modifier
	local target = store.entities[this.modifier.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	if target.unit.size == UNIT_SIZE_SMALL then
		this.render.sprites[1].scale = V.v(0.56, 0.56)
	else
		this.render.sprites[1].scale = V.v(0.7, 0.7)
	end

	this.pos = target.pos
	start_ts = store.tick_ts

	if m.animation_phases then
		U.animation_start_default(this, "start", nil, store.tick_ts)

		while not U.animation_finished_default(this) do
			if not target_hidden and m.hide_target_delay and store.tick_ts - start_ts > m.hide_target_delay then
				target_hidden = true

				if target.ui then
					target.ui.can_click = false
				end

				if target.health_bar then
					target.health_bar.hidden = true
				end

				U.sprites_hide(target, nil, nil, true)
				SU.hide_modifiers(store, target, true, this)
				SU.hide_auras(store, target, true)
			end

			coroutine.yield()
		end
	end

	local d = E.assign_damage(this.damage_type, 1, this.id, target.id)

	queue_damage(store, d)
	U.animation_start_default(this, "idle", nil, store.tick_ts, true)

	while store.tick_ts - m.ts < m.duration and target and not target.health.dead do
		if this.render and m.use_mod_offset and target.unit.mod_offset and not m.custom_offsets then
			for i = 1, #this.render.sprites do
				local s = this.render.sprites[i]

				s.offset.x, s.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
			end
		end

		coroutine.yield()
	end

	S:queue(this.explode_sound)

	if m.animation_phases then
		U.animation_start_default(this, "explosion", nil, store.tick_ts)

		if target_hidden then
			if target.ui then
				target.ui.can_click = true
			end

			if target.health_bar and not target.health.dead then
				target.health_bar.hidden = nil
			end

			U.sprites_show(target, nil, nil, true)
			SU.show_modifiers(store, target, true, this)
			SU.show_auras(store, target, true)
		end

		U.y_wait_unconditional(store, this.explode_time)

		local explode_fx = E:create_entity(this.explode_fx)

		explode_fx.pos:copy(target.pos)

		explode_fx.tween.ts = store.tick_ts

		simulation:queue_insert_entity(explode_fx)

		local targets = U.find_enemies_in_range_filter_off(this.pos, this.damage_range, 0, this.damage_aoe_bans)

		if targets then
			for _, target in ipairs(targets) do
				local d = E.assign_damage(this.damage_type_aoe, math.random(this.damage_aoe_min, this.damage_aoe_max) * this.modifier.damage_factor, this.id, target.id)

				queue_damage(store, d)
			end
		end

		while not U.animation_finished_default(this) do
			coroutine.yield()
		end
	end

	simulation:queue_remove_entity(this)
end

local function decal_hero_dragon_gem_crystal_tomb_update(this, store)
	U.y_animation_play(this, "death_crystals", nil, store.tick_ts, 1)

	while true do
		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function aura_hero_dragon_gem_skill_stun_update(this, store)
	local first_hit_ts
	local last_hit_ts = 0
	local cycles_count = 0
	local victims_count = 0

	if this.aura.track_source and this.aura.source_id then
		local te = store.entities[this.aura.source_id]

		if te and te.pos then
			this.pos = te.pos
		end
	end

	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, {1}, true)
	local pi, spi, ni = unpack(nodes[1])
	local npos = P:node_pos(pi, spi, ni)
	local fx = E:create_entity(this.surround_fx)

	fx.pos.x, fx.pos.y = npos.x - 20, npos.y
	fx.render.sprites[1].ts = store.tick_ts
	fx.render.sprites[1].runs = 0

	simulation:queue_insert_entity(fx)

	last_hit_ts = store.tick_ts - this.aura.cycle_time

	if this.aura.apply_delay then
		last_hit_ts = last_hit_ts + this.aura.apply_delay
	end

	while true do
		if this.interrupt then
			last_hit_ts = 1e+99
		end

		if this.aura.cycles and cycles_count >= this.aura.cycles or this.aura.duration >= 0 and store.tick_ts - this.aura.ts > this.actual_duration then
			break
		end

		if this.aura.stop_on_max_count and this.aura.max_count and victims_count >= this.aura.max_count then
			break
		end

		if not (store.tick_ts - last_hit_ts >= this.aura.cycle_time) or this.aura.apply_duration and first_hit_ts and store.tick_ts - first_hit_ts > this.aura.apply_duration then
		-- block empty
		else
			if this.render and this.aura.cast_resets_sprite_id then
				this.render.sprites[this.aura.cast_resets_sprite_id].ts = store.tick_ts
			end

			first_hit_ts = first_hit_ts or store.tick_ts
			last_hit_ts = store.tick_ts
			cycles_count = cycles_count + 1

			local targets = table.filter(store.enemies, function(k, v)
				return not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name)) and (not this.aura.filter_source or this.aura.source_id ~= v.id)
			end)

			for i, target in ipairs(targets) do
				if this.aura.targets_per_cycle and i > this.aura.targets_per_cycle then
					break
				end

				if this.aura.max_count and victims_count >= this.aura.max_count then
					break
				end

				local mods = this.aura.mods or {this.aura.mod}

				for _, mod_name in ipairs(mods) do
					local new_mod = E:create_entity(mod_name)

					new_mod.modifier.level = this.aura.level
					new_mod.modifier.target_id = target.id
					new_mod.modifier.source_id = this.id

					if this.aura.hide_source_fx and target.id == this.aura.source_id then
						new_mod.render = nil
					end

					simulation:queue_insert_entity(new_mod)

					victims_count = victims_count + 1
				end
			end
		end

		::label_378_0::

		coroutine.yield()
	end

	U.y_wait_unconditional(store, fts(5))

	fx = E:create_entity(this.surround_fx)
	fx.pos.x, fx.pos.y = npos.x + 20, npos.y - 20
	fx.render.sprites[1].ts = store.tick_ts
	fx.render.sprites[1].runs = 0

	simulation:queue_insert_entity(fx)
	U.y_wait_unconditional(store, fts(5))

	fx = E:create_entity(this.surround_fx)
	fx.pos.x, fx.pos.y = npos.x + 15, npos.y + 20
	fx.render.sprites[1].ts = store.tick_ts
	fx.render.sprites[1].runs = 0
	fx.render.sprites[1].flip_x = true

	simulation:queue_insert_entity(fx)
	signal.emit("aura-apply-mod-victims", this, victims_count)
	simulation:queue_remove_entity(this)
end

local function hero_dragon_gem_level_up(this, store, initial)
	local hl, ls = level_up_basic(this)
	local b = E:get_template(this.ranged.attacks[1].bullet)

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	upgrade_skill(this, "stun", function(this, s)
		local a = this.ranged.attacks[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local b = E:get_template(a.bullet)
		local aura = E:get_template(b.bullet.hit_payload)
		local mod = E:get_template(aura.aura.mod)

		mod.modifier.duration = s.duration[s.level]
	end)
	upgrade_skill(this, "floor_impact", function(this, s)
		local a = this.ranged.attacks[3]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local d = E:get_template(a.entity)

		d.damage_min = s.damage_min[s.level]
		d.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "crystal_instakill", function(this, s)
		local a = this.ranged.attacks[4]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.hp_max = s.hp_max[s.level]

		local m = E:get_template(a.mod)

		m.damage_aoe_min = s.damage_min[s.level]
		m.damage_aoe_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "crystal_totem", function(this, s)
		local a = this.ranged.attacks[5]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local bullet = E:get_template(a.bullet)
		local aura = E:get_template(bullet.bullet.hit_payload)

		aura.aura.duration = s.duration[s.level]
		aura.damage_min = s.damage_min[s.level]
		aura.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		local a = this.ultimate

		a.disabled = nil

		local uc = E:get_template(s.controller_name)

		uc.max_shards = s.max_shards[s.level]

		local decal = E:get_template(uc.decal)

		decal.damage_min = s.damage_min[s.level]
		decal.damage_max = s.damage_max[s.level]
	end)
	update_hp(this)
end

local function hero_dragon_gem_update(this, store)
	local h = this.health
	local shots_with_mod = 0
	local shadow_sprite = this.render.sprites[2]
	local stun_attack = this.ranged.attacks[2]
	local floor_impact_attack = this.ranged.attacks[3]
	local crystal_instakill_attack = this.ranged.attacks[4]
	local crystal_totem_attack = this.ranged.attacks[5]

	if not stun_attack.disabled then
		stun_attack.ts = store.tick_ts - stun_attack.cooldown
	end

	if not floor_impact_attack.disabled then
		floor_impact_attack.ts = store.tick_ts - floor_impact_attack.cooldown
	end

	if not crystal_instakill_attack.disabled then
		crystal_instakill_attack.ts = store.tick_ts - crystal_instakill_attack.cooldown
	end

	if not crystal_totem_attack.disabled then
		crystal_totem_attack.ts = store.tick_ts - crystal_totem_attack.cooldown
	end

	local function y_hero_death_and_respawn_hero_dragon_gem(store, this)
		local h = this.health
		local he = this.hero

		this.ui.can_click = false

		local death_ts = store.tick_ts
		local dead_lifetime = h.dead_lifetime

		U.unblock_target(store, this)

		if band(h.last_damage_types, bor(DAMAGE_DISINTEGRATE)) ~= 0 then
			this.unit.hide_after_death = true

			local fx = E:create_entity("fx_soldier_desintegrate")

			fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
			fx.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(fx)
		elseif band(h.last_damage_types, bor(DAMAGE_EAT)) ~= 0 then
			this.unit.hide_after_death = true
		elseif band(h.last_damage_types, bor(DAMAGE_HOST)) ~= 0 then
			this.unit.hide_after_death = true

			S:queue("DeathEplosion")

			local fx = E:create_entity("fx_unit_explode")

			fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]

			simulation:queue_insert_entity(fx)

			if this.unit.show_blood_pool and this.unit.blood_color ~= BLOOD_NONE then
				local decal = E:create_entity("decal_blood_pool")

				decal.pos:copy(this.pos)

				decal.render.sprites[1].ts = store.tick_ts
				decal.render.sprites[1].name = this.unit.blood_color

				simulation:queue_insert_entity(decal)
			end
		else
			S:queue(this.sound_events.death, this.sound_events.death_args)
			U.animation_start_default(this, "death_dragon", nil, store.tick_ts)
		end

		this.health.death_finished_ts = store.tick_ts

		if this.unit.hide_after_death then
			for _, s in ipairs(this.render.sprites) do
				s.hidden = true
			end
		end

		local tombstone

		if he and he.tombstone_show_time then
			while store.tick_ts - death_ts < he.tombstone_show_time do
				coroutine.yield()
			end

			local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, {1, 2, 3}, true)
			local pi, spi, ni = unpack(nodes[1])
			local npos = P:node_pos(pi, spi, ni)

			tombstone = E:create_entity(he.tombstone_decal)
			tombstone.pos = npos

			simulation:queue_insert_entity(tombstone)

			shadow_sprite.hidden = true
		end

		SU.y_hero_animation_wait(this)

		while dead_lifetime > store.tick_ts - death_ts do
			coroutine.yield()
		end

		this.health.death_finished_ts = nil

		U.animation_start_default(tombstone, "respawn_crystals", nil, store.tick_ts)
		U.y_wait_unconditional(store, fts(5))

		he.respawn_point = tombstone.pos

		if he and he.respawn_point then
			local p = he.respawn_point

			this.pos.x, this.pos.y = p.x, p.y
			this.nav_rally.pos.x, this.nav_rally.pos.y = p.x, p.y
			this.nav_rally.center.x, this.nav_rally.center.y = p.x, p.y
			this.nav_rally.new = false
		end

		for _, s in ipairs(this.render.sprites) do
			s.hidden = false
		end

		this.render.sprites[1].hidden = false
		h.ignore_damage = true

		S:queue(this.sound_events.respawn)
		U.y_animation_play(this, "respawn_dragon", nil, store.tick_ts, 1)

		if tombstone then
			simulation:queue_remove_entity(tombstone)
		end

		this.health_bar.hidden = false
		this.ui.can_click = true
		h.dead = false
		h.hp = h.hp_max
		h.ignore_damage = false
	end

	this.tween.disabled = false
	this.tween.ts = store.tick_ts
	this.health_bar.hidden = false

	U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts - fts(4), this.idle_flip.loop, nil, true)

	while true do
		if h.dead then
			y_hero_death_and_respawn_hero_dragon_gem(store, this)
			U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
		end

		while this.nav_rally.new do
			local start_pos = V.vclone(this.pos)

			SU.y_hero_new_rally(store, this)

			if V.dist2(this.pos.x, this.pos.y, start_pos.x, start_pos.y) > this.passive_charge.distance_to_charge ^ 2 then
				local modifier = E:create_entity(this.passive_charge.mod)

				modifier.modifier.target_id = this.id

				simulation:queue_insert_entity(modifier)
			end
		end

		if SU.hero_level_up(store, this) then
			U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
		end

		if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
			local target = find_target_at_critical_moment(this, 160, F_RANGED, F_FLYING, nil, true, false)

			if target and U.has_valid_rally_node_nearby(target.pos) then
				S:queue(this.sound_events.ultimate)

				local e = E:create_entity(this.hero.skills.ultimate.controller_name)

				e.pos.x, e.pos.y = target.pos.x, target.pos.y
				e.damage_factor = this.unit.damage_factor
				e.level = this.ultimate.level

				simulation:queue_insert_entity(e)

				this.ultimate.ts = store.tick_ts

				SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
			else
				this.ultimate.ts = this.ultimate.ts + 1
			end
		end

		for _, i in pairs(this.ranged.order) do
			do
				local a = this.ranged.attacks[i]

				if a.disabled then
				-- block empty
				elseif a.sync_animation and not this.render.sprites[1].sync_flag then
				-- block empty
				elseif store.tick_ts - a.ts < a.cooldown then
				-- block empty
				else
					if i == 2 then
						local targets_info = U.find_enemies_in_paths(store.enemies, this.pos, a.range_nodes_min, a.range_nodes_max, nil, a.vis_flags, a.vis_bans)

						if not targets_info or #targets_info < a.min_targets then
							a.ts = a.ts + 0.4

							goto label_370_1
						end

						local target

						for _, ti in ipairs(targets_info) do
							if GR:cell_is(ti.enemy.pos.x, ti.enemy.pos.y, bor(TERRAIN_LAND, TERRAIN_ICE)) then
								target = ti.enemy

								break
							end
						end

						if not target then
							a.ts = a.ts + 0.4

							goto label_370_1
						end

						local start_ts = store.tick_ts
						local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

						S:queue(a.sound)
						U.animation_start_default(this, an, af, store.tick_ts)

						if SU.y_soldier_wait(store, this, a.shoot_time) then
							goto label_370_2
						end

						local b = E:create_entity(a.bullet)

						b.bullet.target_id = target.id
						b.bullet.source_id = this.id
						b.bullet.damage_factor = this.unit.damage_factor

						b.pos:copy(this.pos)

						local bullet_start_offset = V.v(0, 0)

						if a.bullet_start_offset and #a.bullet_start_offset == 2 then
							local offset_index = af and 2 or 1

							bullet_start_offset = a.bullet_start_offset[offset_index]
						end

						b.pos.x = b.pos.x + (af and -1 or 1) * bullet_start_offset.x
						b.pos.y = b.pos.y + bullet_start_offset.y

						b.bullet.from:copy(b.pos)

						if b.bullet.ignore_hit_offset then
							b.bullet.to = V.v(target.pos.x, target.pos.y)
						else
							b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
						end

						simulation:queue_insert_entity(b)
						U.y_animation_wait_default(this)

						a.ts = start_ts

						SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])

						goto label_370_1
					end

					if i == 3 then
						local targets_info = U.find_enemies_in_paths(store.enemies, this.pos, a.range_nodes_min, a.range_nodes_max, nil, a.vis_flags, a.vis_bans)

						if not targets_info or #targets_info < a.min_targets then
							a.ts = a.ts + 0.4

							goto label_370_1
						end

						local target

						for _, ti in ipairs(targets_info) do
							if GR:cell_is(ti.enemy.pos.x, ti.enemy.pos.y, bor(TERRAIN_LAND, TERRAIN_ICE)) then
								target = ti.enemy

								break
							end
						end

						if not target then
							a.ts = a.ts + 0.4

							goto label_370_1
						end

						local available_paths = {}

						for k, v in pairs(P.paths) do
							table.insert(available_paths, k)
						end

						if store.level.ignore_walk_backwards_paths then
							available_paths = table.filter(available_paths, function(k, v)
								return not table.contains(store.level.ignore_walk_backwards_paths, v)
							end)
						end

						local nodes = P:nearest_nodes(this.pos.x, this.pos.y, available_paths, nil, nil, NF_RALLY)

						if #nodes < 1 then
							a.ts = a.ts + 0.4

							goto label_370_1
						end

						local pi, spi, ni = unpack(nodes[1])
						local nodepos = P:node_pos(pi, spi, ni)
						local dist = V.dist(this.pos.x, this.pos.y, nodepos.x, nodepos.y)

						if dist > a.distance_to_start_node then
							a.ts = a.ts + 0.4

							goto label_370_1
						end

						S:queue(a.sound)

						local start_ts = store.tick_ts
						local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

						U.animation_start_default(this, an, af, store.tick_ts)
						U.y_wait_unconditional(store, a.fall_time)

						local floor_decal = E:create_entity(a.floor_decal)

						floor_decal.pos = V.vclone(this.pos)
						floor_decal.render.sprites[1].ts = store.tick_ts

						simulation:queue_insert_entity(floor_decal)

						local shards = {}

						local function shard_too_close(new_pos)
							for _, shard in ipairs(shards) do
								local dist2 = V.dist2(new_pos.x, new_pos.y, shard.x, shard.y)

								if dist2 < 100 then
									return true
								end
							end

							return false
						end

						for i = 1, #nodes do
							local pi, spi, ni = unpack(nodes[i])
							local nodepos = P:node_pos(pi, spi, ni)
							local dist = V.dist(this.pos.x, this.pos.y, nodepos.x, nodepos.y)

							if dist < a.distance_to_start_node then
								local ni_backwards = ni - a.initial_offset
								local ni_forward = ni + a.initial_offset
								local ni_aux

								for j = 1, a.shards do
									ni_aux = ni_backwards - (j - 1) * a.nodes_between_shards

									local new_pos

									if P:is_node_valid(pi, ni_aux) then
										new_pos = P:node_pos(pi, 1, ni_aux)

										if not shard_too_close(new_pos) then
											table.insert(shards, new_pos)
										end
									end

									ni_aux = ni_backwards - (j - 1) * (a.nodes_between_shards + 2)

									if P:is_node_valid(pi, ni_aux) then
										new_pos = P:node_pos(pi, 2, ni_aux)

										if not shard_too_close(new_pos) then
											table.insert(shards, new_pos)
										end

										new_pos = P:node_pos(pi, 3, ni_aux)

										if not shard_too_close(new_pos) then
											table.insert(shards, new_pos)
										end
									end

									ni_aux = ni_forward + (j - 1) * a.nodes_between_shards

									if P:is_node_valid(pi, ni_aux) then
										new_pos = P:node_pos(pi, 1, ni_aux)

										if not shard_too_close(new_pos) then
											table.insert(shards, new_pos)
										end
									end

									ni_aux = ni_forward + (j - 1) * (a.nodes_between_shards + 2)

									if P:is_node_valid(pi, ni_aux) then
										new_pos = P:node_pos(pi, 2, ni_aux)

										if not shard_too_close(new_pos) then
											table.insert(shards, new_pos)
										end

										new_pos = P:node_pos(pi, 3, ni_aux)

										if not shard_too_close(new_pos) then
											table.insert(shards, new_pos)
										end
									end
								end
							end
						end

						table.sort(shards, function(e1, e2)
							return V.dist2(this.pos.x, this.pos.y, e1.x, e1.y) < V.dist2(this.pos.x, this.pos.y, e2.x, e2.y)
						end)

						local controller = E:create_entity(a.controller)

						controller.shards = shards
						controller.pos = V.vclone(this.pos)
						controller.entity = a.entity

						simulation:queue_insert_entity(controller)
						U.y_animation_wait_default(this)

						a.ts = start_ts

						SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])

						goto label_370_1
					end

					if i == 4 then
						local target = U.find_foremost_enemy_in_range_filter_off(this.pos, a.max_range, 0, a.vis_flags, a.vis_bans)

						if not target then
							a.ts = a.ts + 0.4

							goto label_370_1
						end

						if target.health and target.health.hp > a.hp_max then
							a.ts = a.ts + 0.4

							goto label_370_1
						end

						local start_ts = store.tick_ts

						S:queue(a.sound, a.sound_args)

						local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

						U.animation_start_default(this, an, af, store.tick_ts)
						U.y_wait_unconditional(store, a.shoot_time)

						local mod = E:create_entity(a.mod)

						mod.modifier.target_id = target.id
						mod.modifier.source_id = this.id
						mod.modifier.damage_factor = this.unit.damage_factor

						simulation:queue_insert_entity(mod)
						U.y_animation_wait_default(this)

						a.ts = start_ts

						SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])

						goto label_370_1
					end

					if i == 5 then
						local aim_target, enemies = U.find_foremost_enemy_with_max_coverage_in_range_filter_off(this.pos, a.max_range_trigger, a.shoot_time + E:get_template(a.bullet).bullet.flight_time, a.vis_flags, a.vis_bans, E:get_template(E:get_template(a.bullet).bullet.hit_payload).aura.radius)

						if not enemies or #enemies < a.min_targets then
							a.ts = a.ts + 0.4

							goto label_370_1
						end

						if P:nodes_to_goal(aim_target.nav_path.pi, aim_target.nav_path.spi, aim_target.nav_path.ni) < a.nodes_prediction + 10 then
							a.ts = a.ts + 0.4

							goto label_370_1
						end

						local bullet = E:create_entity(a.bullet)
						local node_offset = P:predict_enemy_node_advance(aim_target, bullet.bullet.flight_time)

						node_offset = node_offset + a.nodes_prediction

						local bullet_to = P:node_pos(aim_target.nav_path.pi, 1, aim_target.nav_path.ni + node_offset, true)
						local start_ts = store.tick_ts

						S:queue(a.sound)

						local an, af = U.animation_name_facing_point(this, a.animation, bullet_to)

						U.animation_start_default(this, an, af, store.tick_ts)
						U.y_wait_unconditional(store, a.shoot_time)
						bullet.pos:copy(this.pos)

						bullet.pos.x = bullet.pos.x + a.bullet_start_offset.x
						bullet.pos.y = bullet.pos.y + a.bullet_start_offset.y

						bullet.bullet.from:copy(bullet.pos)
						bullet.bullet.to:copy(bullet_to)

						bullet.bullet.target_id = aim_target.id
						bullet.bullet.source_id = this.id
						bullet.bullet.damage_factor = this.unit.damage_factor

						simulation:queue_insert_entity(bullet)
						U.y_animation_wait_default(this)

						a.ts = start_ts

						SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])

						goto label_370_1
					end

					if i == 1 then
						local flight_time = a.estimated_flight_time or 1
						local targets = U.find_enemies_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

						if targets then
							local target = targets[1]
							local start_ts = store.tick_ts
							local start_fx, b
							local node_offset = P:predict_enemy_node_advance(target, flight_time)
							local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
							local an, af = U.animation_name_facing_point(this, a.animation, t_pos)

							U.animation_start_default(this, an, af, store.tick_ts)
							S:queue(a.start_sound, a.start_sound_args)

							while store.tick_ts - start_ts < a.shoot_time do
								if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
									goto label_370_0
								end

								coroutine.yield()
							end

							b = E:create_entity(a.bullet)

							if a.type == "aura" then
								b.pos.x, b.pos.y = target.pos.x, target.pos.y
								b.aura.ts = store.tick_ts
							else
								b.bullet.target_id = target.id
								b.bullet.source_id = this.id
								b.bullet.xp_dest_id = this.id

								b.pos:copy(this.pos)

								local bullet_start_offset = V.v(0, 0)

								if a.bullet_start_offset and #a.bullet_start_offset == 2 then
									local offset_index = af and 2 or 1

									bullet_start_offset = a.bullet_start_offset[offset_index]
								end

								b.pos.x = b.pos.x + (af and -1 or 1) * bullet_start_offset.x
								b.pos.y = b.pos.y + bullet_start_offset.y

								b.bullet.from:copy(b.pos)

								if b.bullet.ignore_hit_offset then
									b.bullet.to = V.v(target.pos.x, target.pos.y)
								else
									b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
								end

								b.bullet.shot_index = i
								b.initial_impulse = 10
								b.bullet.damage_min = b.bullet.damage_min + this.unit.damage_buff
								b.bullet.damage_max = b.bullet.damage_max + this.unit.damage_buff
								b.bullet.damage_factor = this.unit.damage_factor
							end

							simulation:queue_insert_entity(b)

							if a.xp_from_skill then
								SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
							end

							a.ts = start_ts

							while not U.animation_finished_default(this) do
								if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
									goto label_370_0
								end

								coroutine.yield()
							end

							a.ts = start_ts

							if U.has_modifiers(store, this, this.passive_charge.mod) then
								shots_with_mod = shots_with_mod + 1

								if shots_with_mod >= this.passive_charge.shots_amount then
									SU.remove_modifiers(store, this, this.passive_charge.mod)

									shots_with_mod = 0
								end
							end

							U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

							::label_370_0::

							if start_fx then
								start_fx.render.sprites[1].hidden = true
							end

							goto label_370_1
						end
					end
				end
			end

			::label_370_1::
		end

		SU.soldier_idle(store, this)
		SU.soldier_regen(store, this)

		::label_370_2::

		coroutine.yield()
	end
end

local function mod_hero_dragon_gem_passive_charge_update(this, store)
	local m = this.modifier

	this.modifier.ts = store.tick_ts

	local target = store.entities[m.target_id]

	if not target or not target.pos then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or m.duration >= 0 and store.tick_ts - m.ts > m.duration or m.last_node and target.nav_path.ni > m.last_node then
			simulation:queue_remove_entity(this)

			return
		end

		if this.render and target.unit then
			local s = this.render.sprites[1]
			local flip_sign = 1

			if target.render then
				flip_sign = target.render.sprites[1].flip_x and -1 or 1
			end

			if m.health_bar_offset and target.health_bar then
				local hb = target.health_bar.offset
				local hbo = m.health_bar_offset

				s.offset.x, s.offset.y = hb.x + hbo.x * flip_sign, hb.y + hbo.y
			elseif m.use_mod_offset and target.unit.mod_offset then
				s.offset.x, s.offset.y = target.unit.mod_offset.x * flip_sign, target.unit.mod_offset.y
			end
		end

		coroutine.yield()
	end
end

local function hero_dragon_gem_ultimate_update(this, store)
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_POWER_3)

	if #nodes < 1 then
		log.error("hero_dragon_gem_ultimate: could not find valid node")
		simulation:queue_remove_entity(this)

		return
	end

	local target_pos = {}
	local node = {
		spi = 1,
		pi = nodes[1][1],
		ni = nodes[1][3]
	}
	local node_pos = P:node_pos(node.pi, node.spi, node.ni)
	local count = this.max_shards

	local function shard_too_close(new_pos)
		for _, shard in ipairs(target_pos) do
			local dist = V.dist(new_pos.x, new_pos.y, shard.x, shard.y)

			if dist < this.distance_between_shards then
				return true
			end
		end

		return false
	end

	local _, targets = U.find_nearest_enemy(store, this.pos, 0, this.range, this.vis_flags, this.vis_bans)

	table.insert(target_pos, node_pos)

	if targets then
		for _, v in ipairs(targets) do
			if count > #target_pos then
				local node_offset = P:predict_enemy_node_advance(v, this.prediction_nodes)
				local e_pos = P:node_pos(v.nav_path.pi, v.nav_path.spi, v.nav_path.ni + node_offset)

				table.insert(target_pos, V.vclone(e_pos))
			end
		end
	end

	if count > #target_pos then
		local available_paths = {}

		for k, v in pairs(P.paths) do
			table.insert(available_paths, k)
		end

		if store.level.ignore_walk_backwards_paths then
			available_paths = table.filter(available_paths, function(k, v)
				return not table.contains(store.level.ignore_walk_backwards_paths, v)
			end)
		end

		local safe_break = 1000
		local nearest = P:nearest_nodes(this.pos.x, this.pos.y, available_paths)

		if nearest and #nearest > 0 then
			local path_pi, _, path_ni = unpack(nearest[1])
			local spi = {1, 3, 2}

			while count > #target_pos do
				local ni_random = math.random(this.random_ni_spread * -1, this.random_ni_spread)
				local spi_random = spi[count % 3 + 1]
				local pos_spawn = P:node_pos(path_pi, spi_random, path_ni + ni_random)

				if not shard_too_close(pos_spawn) then
					table.insert(target_pos, pos_spawn)
				end

				safe_break = safe_break - 1

				if safe_break <= 0 then
					break
				end
			end
		end
	end

	for _, pos in ipairs(target_pos) do
		local decal = E:create_entity(this.decal)

		decal.pos:copy(pos)
		simulation:queue_insert_entity(decal)
		U.y_wait_unconditional(store, this.spawn_delay)
	end

	simulation:queue_remove_entity(this)
end

local function decal_hero_dragon_gem_floor_impact_shard_update(this, store)
	this.render.sprites[1].flip_x = this.dragon_pos.x > this.pos.x

	U.animation_start_default(this, "start", nil, store.tick_ts, false)
	U.y_wait_unconditional(store, this.damage_time)
	U.y_animation_wait_default(this)
	U.animation_start_default(this, "idle", nil, store.tick_ts, false)

	local targets = U.find_enemies_in_range_filter_off(this.pos, this.damage_range, 0, bit.bor(F_FLYING, F_CLIFF))

	if targets then
		for _, target in ipairs(targets) do
			local d = E.assign_damage(this.damage_type, math.random(this.damage_min, this.damage_max), this.id, target.id)

			queue_damage(store, d)
		end
	end

	U.y_wait_unconditional(store, this.duration_time + fts(math.random(1, 10) - 5))
	U.animation_start_default(this, "end", nil, store.tick_ts, false)
	U.y_animation_wait_default(this)
	simulation:queue_remove_entity(this)
end

local function decal_hero_dragon_gem_ultimate_shard_update(this, store)
	this.render.sprites[1].hidden = true

	local x_bullet_offset = {0, 10, -10, 10}
	local y_bullet_offset = {-10, -5, 0, -5}

	for i = 1, 4 do
		local bullet = E:create_entity(this.bullet)
		local bullet_pos = V.vclone(this.pos)

		bullet_pos.x = bullet_pos.x + x_bullet_offset[i]
		bullet_pos.y = bullet_pos.y + y_bullet_offset[i]

		bullet.pos:copy(bullet_pos)

		bullet.pos.y = bullet.pos.y + 200

		bullet.bullet.from:copy(bullet.pos)
		bullet.bullet.to:copy(bullet_pos)
		simulation:queue_insert_entity(bullet)
		U.y_wait_unconditional(store, fts(2))
	end

	U.y_wait_unconditional(store, this.damage_time)

	this.render.sprites[1].hidden = false

	for _, v in ipairs(this.fx_on_arrival) do
		local fx = E:create_entity(v)

		fx.pos:copy(this.pos)

		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].runs = 0

		simulation:queue_insert_entity(fx)
	end

	local floor_decal = E:create_entity(this.floor_decal)

	floor_decal.pos = V.vclone(this.pos)
	floor_decal.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(floor_decal)

	local targets = U.find_enemies_in_range_filter_off(this.pos, this.damage_range, 0, bit.bor(F_FLYING, F_CLIFF))

	if targets then
		for _, target in ipairs(targets) do
			local d = E.assign_damage(this.damage_type, math.random(this.damage_min, this.damage_max), this.id, target.id)

			queue_damage(store, d)
		end
	end

	this.tween.ts = store.tick_ts
	this.tween.disabled = false

	U.y_wait_unconditional(store, this.tween.props[1].keys[2][1])
	simulation:queue_remove_entity(this)
end

local function aura_hero_dragon_gem_crystal_totem_update(this, store)
	local first_hit_ts
	local last_hit_ts = 0
	local cycles_count = 0
	local victims_count = 0

	if this.aura.track_source and this.aura.source_id then
		local te = store.entities[this.aura.source_id]

		if te and te.pos then
			this.pos = te.pos
		end
	end

	last_hit_ts = store.tick_ts - this.aura.cycle_time

	if this.aura.apply_delay then
		last_hit_ts = last_hit_ts + this.aura.apply_delay
	end

	local floor_decal = E:create_entity(this.floor_decal)

	floor_decal.pos = V.vclone(this.pos)
	floor_decal.tween.ts = store.tick_ts

	simulation:queue_insert_entity(floor_decal)
	S:queue(this.pulse_sound)
	U.y_animation_play(this, "spawn", nil, store.tick_ts)
	U.animation_start_default(this, "idle", nil, store.tick_ts, true)

	while true do
		if this.interrupt then
			last_hit_ts = 1e+99
		end

		if this.aura.cycles and cycles_count >= this.aura.cycles or this.aura.duration >= 0 and store.tick_ts - this.aura.ts > this.actual_duration then
			break
		end

		if this.aura.stop_on_max_count and this.aura.max_count and victims_count >= this.aura.max_count then
			break
		end

		if not (store.tick_ts - last_hit_ts >= this.aura.cycle_time) or this.aura.apply_duration and first_hit_ts and store.tick_ts - first_hit_ts > this.aura.apply_duration then
		-- block empty
		else
			if this.render and this.aura.cast_resets_sprite_id then
				this.render.sprites[this.aura.cast_resets_sprite_id].ts = store.tick_ts
			end

			first_hit_ts = first_hit_ts or store.tick_ts
			last_hit_ts = store.tick_ts
			cycles_count = cycles_count + 1

			local targets = table.filter(store.enemies, function(k, v)
				return not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name)) and (not this.aura.filter_source or this.aura.source_id ~= v.id)
			end)

			for i, target in ipairs(targets) do
				if this.aura.targets_per_cycle and i > this.aura.targets_per_cycle then
					break
				end

				if this.aura.max_count and victims_count >= this.aura.max_count then
					break
				end

				local mods = this.aura.mods or {this.aura.mod}

				for _, mod_name in ipairs(mods) do
					local new_mod = E:create_entity(mod_name)

					new_mod.modifier.level = this.aura.level
					new_mod.modifier.target_id = target.id
					new_mod.modifier.source_id = this.id
					new_mod.modifier.damage_factor = this.aura.damage_factor

					if this.aura.hide_source_fx and target.id == this.aura.source_id then
						new_mod.render = nil
					end

					simulation:queue_insert_entity(new_mod)

					victims_count = victims_count + 1
				end
			end

			local targets = U.find_enemies_in_range_filter_off(this.pos, this.damage_range, this.aura.vis_flags, F_NONE)

			if targets then
				for _, target in ipairs(targets) do
					local d = E.assign_damage(this.damage_type, math.random(this.damage_min, this.damage_max) * this.aura.damage_factor, this.id, target.id)

					queue_damage(store, d)
				end
			end

			local floor_decal = E:create_entity(this.floor_decal)

			floor_decal.pos = V.vclone(this.pos)
			floor_decal.tween.ts = store.tick_ts

			simulation:queue_insert_entity(floor_decal)
			U.y_animation_play(this, "shock", nil, store.tick_ts)
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
		end

		::label_385_0::

		coroutine.yield()
	end

	this.tween.ts = store.tick_ts
	this.tween.disabled = false

	U.y_wait_unconditional(store, fts(15))
	signal.emit("aura-apply-mod-victims", this, victims_count)
	simulation:queue_remove_entity(this)
end

tt = RT("ps_bolt_hero_dragon_gem_attack")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_evil_dragon_attack_projectile_trail_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(14), fts(14)}
tt.particle_system.emission_rate = 20
tt.particle_system.emit_rotation_spread = math.pi * 0.5
tt.particle_system.z = Z_FLYING_HEROES
tt = RT("fx_hero_dragon_gem_bolt_hit", "fx")
tt.render.sprites[1].name = "hero_evil_dragon_attack_fx_idle"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].draw_order = DO_MOD_FX
tt = RT("fx_hero_dragon_gem_bolt_hit_flying", "fx")
tt.render.sprites[1].name = "hero_evil_dragon_attack_fx_air_idle"
tt.render.sprites[1].draw_order = DO_MOD_FX
tt = RT("fx_hero_dragon_gem_skill_stun", "fx")
tt.render.sprites[1].name = "hero_evil_dragon_breath_cloud_idle"
tt.render.sprites[1].loop = true
tt = RT("fx_hero_dragon_gem_ultimate_shard_arrival_1", "fx")
tt.render.sprites[1].name = "hero_evil_dragon_ultimate_fx_a_idle"
tt = RT("fx_hero_dragon_gem_ultimate_shard_arrival_2", "fx")
tt.render.sprites[1].name = "hero_evil_dragon_ultimate_fx_b_idle"
tt = RT("decal_hero_dragon_gem_crystal_tomb", "decal_scripted")
tt.render.sprites[1].prefix = "hero_evil_dragon_hero"
tt.render.sprites[1].name = "death_crystals"
tt.render.sprites[1].loop = false
tt.main_script.update = decal_hero_dragon_gem_crystal_tomb_update
tt = RT("decal_bullet_hero_dragon_gem_ultimate_shard", "decal_tween")
tt.render.sprites[1].name = "hero_evil_dragon_ultimate_crystal_a_idle"
tt.render.sprites[1].loop = false
tt.tween.props[1].keys = {{0, 255}, {3, 0}}
tt = RT("decal_hero_dragon_gem_floor_decal", "decal_tween")
tt.render.sprites[1].name = "hero_evil_dragon_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {1.5, 255}, {2, 0}}
tt = RT("decal_hero_dragon_gem_floor_circle", "decal")

AC(tt, "tween")

tt.render.sprites[1].name = "hero_evil_dragon_area_damage_fx"
tt.render.sprites[1].animated = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {fts(6), 255}, {fts(13), 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_2(0.245, 0.245)}, {fts(6), vec_2(0.385, 0.385)}, {fts(13), vec_2(0.42, 0.42)}}
tt = RT("decal_hero_dragon_gem_floor_circle_totem", "decal_hero_dragon_gem_floor_circle")
tt.tween.props[2].keys = {{0, vec_2(0.175, 0.175)}, {fts(6), vec_2(0.315, 0.315)}, {fts(13), vec_2(0.35, 0.35)}}
tt = RT("decal_hero_dragon_gem_floor_impact_shard", "decal_scripted")

AC(tt, "sound_events")

tt.render.sprites[1].prefix = "hero_evil_dragon_shards"
tt.render.sprites[1].loop = false
tt.main_script.update = decal_hero_dragon_gem_floor_impact_shard_update
tt.damage_time = fts(5)
tt.duration_time = fts(10)
tt.damage_range = 50
tt.damage_type = DAMAGE_PHYSICAL
tt.sound_events.insert = "HeroDragonGemPrismaticShardRipple"
tt = RT("decal_hero_dragon_gem_ultimate_shard", "decal_scripted")

AC(tt, "tween", "sound_events")

tt.render.sprites[1].name = "hero_evil_dragon_ultimate_crystal_b"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt.main_script.update = decal_hero_dragon_gem_ultimate_shard_update
tt.damage_time = fts(1)
tt.damage_range = 30
tt.damage_type = DAMAGE_TRUE
tt.bullet = "bullet_hero_dragon_gem_ultimate_shard"
tt.fx_on_arrival = {"fx_hero_dragon_gem_ultimate_shard_arrival_1", "fx_hero_dragon_gem_ultimate_shard_arrival_2"}
tt.floor_decal = "decal_hero_dragon_gem_floor_decal"
tt.tween.props[1].keys = {{0, 255}, {3, 0}}
tt.tween.disabled = true
tt.tween_remove = false
tt.sound_events.insert = "HeroDragonGemUltimateCast"
tt = RT("hero_dragon_gem", "hero")

AC(tt, "ranged", "timed_attacks", "tween")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {390, 429, 468, 507, 546, 585, 624, 663, 707, 754}
tt.hero.level_stats.melee_damage_max = {1, 2, 4, 4, 5, 6, 7, 8, 9, 10}
tt.hero.level_stats.melee_damage_min = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
tt.hero.level_stats.ranged_damage_min = {16, 19, 23, 26, 28, 32, 35, 39, 41, 45}
tt.hero.level_stats.ranged_damage_max = {21, 29, 33, 39, 44, 48, 53, 57, 63, 71}
tt.hero.skills.stun = CC("hero_skill")
tt.hero.skills.stun.duration = {2, 3, 4}
tt.hero.skills.stun.cooldown = {16, 16, 16}
tt.hero.skills.stun.xp_gain = {128, 256, 384}
tt.hero.skills.stun.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.floor_impact = CC("hero_skill")
tt.hero.skills.floor_impact.cooldown = {25, 25, 25}
tt.hero.skills.floor_impact.damage_min = {31, 62, 93}
tt.hero.skills.floor_impact.damage_max = {46, 93, 140}
tt.hero.skills.floor_impact.xp_gain = {200, 400, 600}
tt.hero.skills.floor_impact.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.crystal_instakill = CC("hero_skill")
tt.hero.skills.crystal_instakill.cooldown = {35, 35, 35}
tt.hero.skills.crystal_instakill.damage_min = {41, 98, 124}
tt.hero.skills.crystal_instakill.damage_max = {41, 98, 124}
tt.hero.skills.crystal_instakill.hp_max = {260, 520, 1040}
tt.hero.skills.crystal_instakill.xp_gain = {280, 560, 840}
tt.hero.skills.crystal_instakill.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.crystal_totem = CC("hero_skill")
tt.hero.skills.crystal_totem.cooldown = {20, 20, 20}
tt.hero.skills.crystal_totem.duration = {6, 8, 10}
tt.hero.skills.crystal_totem.damage_min = {10, 20, 32}
tt.hero.skills.crystal_totem.damage_max = {10, 20, 32}
tt.hero.skills.crystal_totem.xp_gain = {160, 320, 480}
tt.hero.skills.crystal_totem.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_dragon_gem_ultimate"
tt.hero.skills.ultimate.damage_min = {62, 93, 114, 135}
tt.hero.skills.ultimate.damage_max = {93, 140, 171, 202}
tt.hero.skills.ultimate.max_shards = {3, 4, 6, 8}
tt.hero.skills.ultimate.cooldown = {45, 45, 45, 45}
tt.hero.skills.ultimate.xp_gain_factor = 36
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.flight_height = 80
tt.health.dead_lifetime = 15
tt.health_bar.draw_order = -1
tt.health_bar.offset = vec_2(0, 170)
tt.health_bar.sort_y_offset = -171
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.health_bar.z = Z_FLYING_HEROES
tt.hero.fn_level_up = hero_dragon_gem_level_up
tt.idle_flip.cooldown = 10
tt.info.hero_portrait = "kr5_hero_portraits_0012"
tt.info.portrait = "kr5_info_portraits_heroes_0012"
tt.main_script.update = hero_dragon_gem_update
tt.motion.max_speed = 100
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.all_except_flying_nowalk = bor(TERRAIN_NONE, TERRAIN_LAND, TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_SHALLOW, TERRAIN_FAERIE, TERRAIN_ICE)
tt.nav_grid.valid_terrains = tt.all_except_flying_nowalk
tt.nav_grid.valid_terrains_dest = tt.all_except_flying_nowalk
-- tt.drag_line_origin_offset = vec_2(0, tt.flight_height)
tt.render.sprites[1].offset.y = tt.flight_height
tt.render.sprites[1].prefix = "hero_evil_dragon_hero"
tt.render.sprites[1].name = "respawn"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_lumenir_hero_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.sound_events.change_rally_point = "HeroDragonGemTaunt"
tt.sound_events.death = "HeroDragonGemDeath"
tt.sound_events.respawn = "HeroDragonGemTauntIntro"
tt.sound_events.hero_room_select = "HeroDragonGemTauntSelect"
tt.ui.click_rect = r(-37, tt.flight_height - 20, 75, 75)
tt.unit.hit_offset = vec_2(0, tt.flight_height + 10)
tt.unit.mod_offset = vec_2(0, tt.flight_height + 10)
tt.unit.death_animation = "death_dragon"
tt.unit.hide_after_death = false
tt.hero.tombstone_concurrent_with_death = true
tt.hero.tombstone_show_time = fts(1)
tt.hero.tombstone_decal = "decal_hero_dragon_gem_crystal_tomb"
tt.hero.tombstone_force_over_path = true
tt.hero.tombstone_respawn_animation = "respawn_crystals"
tt.hero.respawn_animation = "respawn_dragon"
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_POISON, F_MOD)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.passive_charge = {}
tt.passive_charge.distance_to_charge = 250
tt.passive_charge.mod = "mod_hero_dragon_gem_passive_charge"
tt.passive_charge.shots_amount = 1
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "bolt_hero_dragon_gem_attack"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(46, tt.flight_height - 23), vec_2(50, tt.flight_height - 23)}
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].max_range = 220
tt.ranged.attacks[1].shoot_time = fts(14)
tt.ranged.attacks[1].sync_animation = true
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].start_sound = "HeroDragonGemBasicAttackCast"
tt.ranged.attacks[1].ignore_offset = vec_2(0, tt.flight_height + 10)
tt.ranged.attacks[1].radius = 100
tt.ranged.attacks[1].basic_attack = true
tt.ranged.attacks[2] = CC("aura_attack")
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].animation = "breath"
tt.ranged.attacks[2].shoot_time = fts(12)
tt.ranged.attacks[2].min_targets = 2
tt.ranged.attacks[2].min_range = 0
tt.ranged.attacks[2].max_range = 180
tt.ranged.attacks[2].sync_animation = true
tt.ranged.attacks[2].xp_from_skill = "stun"
tt.ranged.attacks[2].vis_flags = bor(F_RANGED, F_ENEMY)
tt.ranged.attacks[2].vis_bans = F_FLYING
tt.ranged.attacks[2].bullet = "ray_hero_dragon_gem_stun"
tt.ranged.attacks[2].range_nodes_max = 30
tt.ranged.attacks[2].range_nodes_min = 20
tt.ranged.attacks[2].bullet_start_offset = {vec_2(46, tt.flight_height - 23), vec_2(50, tt.flight_height - 23)}
tt.ranged.attacks[2].sound = "HeroDragonGemParalyzingBreathCast"
tt.ranged.attacks[3] = CC("aura_attack")
tt.ranged.attacks[3].disabled = true
tt.ranged.attacks[3].min_nodes = 20
tt.ranged.attacks[3].fall_time = fts(24)
tt.ranged.attacks[3].sync_animation = true
tt.ranged.attacks[3].animation = "shards"
tt.ranged.attacks[3].vis_flags = bor(F_RANGED)
tt.ranged.attacks[3].vis_bans = bor(F_FLYING, F_CLIFF)
tt.ranged.attacks[3].xp_from_skill = "floor_impact"
tt.ranged.attacks[3].range_nodes_max = 30
tt.ranged.attacks[3].range_nodes_min = 0
tt.ranged.attacks[3].min_targets = 3
tt.ranged.attacks[3].entity = "decal_hero_dragon_gem_floor_impact_shard"
tt.ranged.attacks[3].floor_decal = "decal_hero_dragon_gem_floor_decal"
tt.ranged.attacks[3].shards = 3
tt.ranged.attacks[3].nodes_between_shards = 8
tt.ranged.attacks[3].initial_offset = 4
tt.ranged.attacks[3].distance_to_start_node = 20
tt.ranged.attacks[3].controller = "controller_hero_dragon_gem_skill_floor_impact_spawner"
tt.ranged.attacks[3].sound = "HeroDragonGemPrismaticShardCast"
tt.ranged.attacks[4] = CC("mod_attack")
tt.ranged.attacks[4].disabled = true
tt.ranged.attacks[4].shoot_time = fts(15)
tt.ranged.attacks[4].sync_animation = true
tt.ranged.attacks[4].mod = "mod_hero_dragon_gem_crystal_instakill"
tt.ranged.attacks[4].animation = "red_death"
tt.ranged.attacks[4].max_range = 200
tt.ranged.attacks[4].vis_flags = bor(F_RANGED, F_MOD)
tt.ranged.attacks[4].vis_bans = bor(F_BOSS, F_FLYING, F_CLIFF)
tt.ranged.attacks[4].xp_from_skill = "crystal_instakill"
tt.ranged.attacks[4].sound = "HeroDragonGemRedDeathCast"
tt.ranged.attacks[4].sound_args = {
	delay = fts(11)
}
tt.ranged.attacks[5] = CC("bullet_attack")
tt.ranged.attacks[5].disabled = true
tt.ranged.attacks[5].animation = "conduit"
tt.ranged.attacks[5].sync_animation = true
tt.ranged.attacks[5].bullet = "bullet_hero_dragon_gem_crystal_totem"
tt.ranged.attacks[5].bullet_start_offset = vec_2(0, tt.flight_height + 20)
tt.ranged.attacks[5].shoot_time = fts(12)
tt.ranged.attacks[5].min_targets = 2
tt.ranged.attacks[5].max_range_trigger = 160
tt.ranged.attacks[5].vis_bans = bor(F_FLYING)
tt.ranged.attacks[5].xp_from_skill = "crystal_totem"
tt.ranged.attacks[5].nodes_prediction = 10
tt.ranged.attacks[5].sound = "HeroDragonGemPowerConduitCast"
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.ultimate = {
	ts = 0,
	cooldown = 36,
	disabled = true
}
tt = RT("hero_dragon_gem_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.main_script.update = hero_dragon_gem_ultimate_update
tt.range = 500
tt.spawn_delay = fts(5)
tt.vis_flags = bor(F_RANGED)
tt.vis_bans = F_NONE
tt.decal = "decal_hero_dragon_gem_ultimate_shard"
tt.max_shards = {3, 4, 6, 8}
tt.prediction_nodes = fts(15)
tt.distance_between_shards = 10
tt.random_ni_spread = 30
tt = RT("bolt_hero_dragon_gem_attack", "bolt")

AC(tt, "force_motion")

tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.hit_fx = nil
tt.bullet.hit_fx_floor = "fx_hero_dragon_gem_bolt_hit"
tt.bullet.hit_fx_flying = "fx_hero_dragon_gem_bolt_hit_flying"
tt.bullet.particles_name = "ps_bolt_hero_dragon_gem_attack"
tt.bullet.max_speed = 600
tt.bullet.align_with_trajectory = true
tt.bullet.min_speed = 600
tt.bullet.xp_gain_factor = 1.45
tt.bullet.ignore_hit_offset = true
tt.bullet.payload = {"decal_hero_dragon_gem_floor_decal", "decal_hero_dragon_gem_floor_circle"}
tt.bullet.pop_chance = 0
tt.force_motion.a_step = 5
tt.force_motion.max_a = 3000
tt.force_motion.max_v = 600
tt.render.sprites[1].prefix = "hero_evil_dragon_attack_projectile"
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.main_script.update = bolt_hero_dragon_gem_attack_update
tt.damage_range = 75
tt.sound_hit = "HeroDragonGemBasicAttackImpact"
tt = RT("ray_hero_dragon_gem_stun", "bullet")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.hit_time = fts(0)
tt.bullet.ignore_hit_offset = true
tt.bullet.hit_payload = "aura_hero_dragon_gem_skill_stun"
tt.hit_fx_only_no_target = true
tt.image_width = 165.5
tt.main_script.update = scripts.ray5_simple.update
tt.render.sprites[1].name = "hero_evil_dragon_breath_idle"
tt.render.sprites[1].loop = false
tt.sound_events.insert = "TowerArcaneWizardBasicAttack"
tt.track_target = false
tt.ray_duration = fts(42)
tt = RT("bullet_hero_dragon_gem_crystal_totem", "bomb")
tt.bullet.flight_time = fts(30)
tt.bullet.align_with_trajectory = true
tt.bullet.ignore_hit_offset = true
tt.bullet.pop = nil
tt.bullet.rotation_speed = nil
tt.bullet.hit_payload = "aura_hero_dragon_gem_crystal_totem"
tt.sound_events.hit = nil
tt.sound_events.insert = nil
tt.render.sprites[1].animated = true
tt.render.sprites[1].name = "hero_evil_dragon_conduit_projectile_idle"
tt.bullet.hit_decal = nil
tt.bullet.hit_fx = nil
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.g = -0.8 / (fts(1) * fts(1))
tt = RT("bullet_hero_dragon_gem_ultimate_shard", "bullet")
tt.main_script.update = bullet_hero_dragon_gem_ultimate_shard_update
tt.bullet.arrive_decal = "decal_bullet_hero_dragon_gem_ultimate_shard"
tt.bullet.max_speed = 900
tt.render.sprites[1].name = "hero_evil_dragon_ultimate_projectile"
tt.render.sprites[1].animated = false
tt = RT("aura_hero_dragon_gem_skill_stun", "aura")
tt.aura.mod = "mod_hero_dragon_gem_skill_stun"
tt.aura.radius = 80
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.surround_fx = "fx_hero_dragon_gem_skill_stun"
tt.aura.duration = fts(1)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = aura_hero_dragon_gem_skill_stun_update
tt = RT("aura_hero_dragon_gem_crystal_totem", "aura")

AC(tt, "render", "tween")

tt.aura.mod = "mod_hero_dragon_gem_crystal_totem_slow"
tt.aura.radius = 80
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.vis_flags = F_RANGED
tt.aura.cycle_time = fts(30)
tt.aura.duration = nil
tt.render.sprites[1].prefix = "hero_evil_dragon_conduit"
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = aura_hero_dragon_gem_crystal_totem_update
tt.damage_range = 80
tt.damage_type = DAMAGE_MAGICAL
tt.tween.props[1].keys = {{0, 255}, {fts(15), 0}}
tt.tween.disabled = true
tt.floor_decal = "decal_hero_dragon_gem_floor_circle_totem"
tt.pulse_sound = "HeroDragonGemPowerConduitCrystal"
tt = RT("mod_hero_dragon_gem_skill_stun", "mod_stun")
tt.modifier.duration = nil
tt.render.sprites[1].prefix = "hero_evil_dragon_breath_crystal"
tt.render.sprites[1].size_names = {"small", "medium", "big"}
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.modifier.animation_phases = true
tt = RT("mod_hero_dragon_gem_crystal_instakill", "modifier")

AC(tt, "render")

tt.modifier.duration = fts(30)
tt.modifier.animation_phases = true
tt.main_script.insert = scripts.mod_stun.insert
tt.main_script.update = mod_hero_dragon_gem_crystal_instakill_update
tt.main_script.remove = scripts.mod_stun.remove
tt.explode_fx = "decal_hero_dragon_gem_floor_circle"
tt.explode_sound = "HeroDragonGemRedDeathExplosion"
tt.render.sprites[1].prefix = "hero_evil_dragon_red_death_crystal"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.explode_time = fts(27)
tt.damage_type = bor(DAMAGE_DISINTEGRATE, DAMAGE_INSTAKILL, DAMAGE_NO_SPAWNS)
tt.damage_type_aoe = DAMAGE_PHYSICAL
tt.damage_range = 100
tt.damage_aoe_bans = bor(F_FLYING, F_CLIFF)
tt = RT("mod_hero_dragon_gem_crystal_totem_slow", "mod_slow")
tt.slow.factor = 0.75
tt.modifier.duration = 1
tt = RT("mod_hero_dragon_gem_passive_charge", "modifier")

AC(tt, "render")

tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.remove = scripts.mod_damage_factors.remove
tt.main_script.update = mod_hero_dragon_gem_passive_charge_update
tt.inflicted_damage_factor = 3
tt.modifier.duration = 1e+99
tt.render.sprites[1].prefix = "hero_evil_dragon_passive"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].z = Z_FLYING_HEROES + 1
tt = RT("controller_hero_dragon_gem_skill_floor_impact_spawner")

AC(tt, "main_script")

tt.main_script.update = controller_hero_dragon_gem_skill_floor_impact_spawner_update
