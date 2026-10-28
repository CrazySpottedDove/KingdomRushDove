local scripts = require("scripts")
local E = require("entity_db")
local GR = require("grid_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local bit = require("bit")
local km = require("lib.klua.macros")
local signal = require("lib.hump.signal")
local log = require("lib.klua.log"):new("hero_scripts")
local apply_ultimate = HU.apply_ultimate
local band = bit.band
local bor = bit.bor
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local tt

local function aura_dragon_bone_cloud_update(this, store)
	local first_hit_ts
	local last_hit_ts = 0
	local cycles_count = 0
	local victims_count = 0

	last_hit_ts = store.tick_ts - this.aura.cycle_time

	if this.aura.apply_delay then
		last_hit_ts = last_hit_ts + this.aura.apply_delay
	end

	this.tween.ts = store.tick_ts

	local nearest_nodes = P:nearest_nodes(this.pos.x, this.pos.y)
	local pi, _, ni = unpack(nearest_nodes[1])
	local cloud_1 = E:create_entity(this.decal_cloud_t)

	cloud_1.pos = P:node_pos(pi, 1, ni + 3)
	cloud_1.tween.ts = store.tick_ts

	simulation:queue_insert_entity(cloud_1)

	local cloud_2 = E:create_entity(this.decal_cloud_t)

	cloud_2.pos = P:node_pos(pi, 1, ni - 3)
	cloud_2.tween.ts = store.tick_ts

	simulation:queue_insert_entity(cloud_2)

	local cloud_3 = E:create_entity(this.decal_cloud_t)

	cloud_3.pos = P:node_pos(pi, 2, ni)
	cloud_3.tween.ts = store.tick_ts

	simulation:queue_insert_entity(cloud_3)

	local cloud_4 = E:create_entity(this.decal_cloud_t)

	cloud_4.pos = P:node_pos(pi, 3, ni)
	cloud_4.tween.ts = store.tick_ts

	simulation:queue_insert_entity(cloud_4)

	while true do
		if this.interrupt then
			last_hit_ts = 1e+99
		end

		if this.aura.cycles and cycles_count >= this.aura.cycles or this.aura.duration >= 0 and store.tick_ts - this.aura.ts > this.actual_duration then
			break
		end

		if not (store.tick_ts - last_hit_ts >= this.aura.cycle_time) or this.aura.apply_duration and first_hit_ts and store.tick_ts - first_hit_ts > this.aura.apply_duration then
		-- block empty
		else
			first_hit_ts = first_hit_ts or store.tick_ts
			last_hit_ts = store.tick_ts
			cycles_count = cycles_count + 1

			local targets = U.find_enemies_in_range_filter_off(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)

			if targets then
				for i, target in ipairs(targets) do
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
		end

		coroutine.yield()
	end

	signal.emit("aura-apply-mod-victims", this, victims_count)

	this.tween.reverse = true
	this.tween.remove = true
	this.tween.ts = store.tick_ts

	local clouds = {cloud_1, cloud_2, cloud_3, cloud_4}

	for i, v in ipairs(clouds) do
		v.tween.reverse = true
		v.tween.remove = true
		v.tween.ts = store.tick_ts
	end
end

local function mod_dragon_bone_plague_remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target and target.health.dead and band(target.health.last_damage_types, DAMAGE_EAT) == 0 then
		local targets = U.find_enemies_in_range_filter_off(this.pos, this.spread_radius, this.modifier.vis_flags, this.modifier.vis_bans)

		if targets then
			for _, t in ipairs(targets) do
				local m = E:create_entity(this.template_name)

				m.modifier.target_id = t.id
				m.modifier.source_id = this.modifier.source_id
				m.modifier.xp_dest_id = this.modifier.xp_dest_id

				simulation:queue_insert_entity(m)

				local dmin, dmax = this.spread_damage_min, this.spread_damage_max
				local dist_factor = U.dist_factor_inside_ellipse(t.pos, target.pos, this.spread_radius)
				local d = E.assign_damage(this.dps.damage_type, math.floor(dmax - (dmax - dmin) * dist_factor) * this.modifier.damage_factor, this.id, t.id)

				queue_damage(store, d)
			end
		end

		local fx = E:create_entity(this.spread_fx)

		fx.pos:copy(this.pos)

		if target and this.modifier.use_mod_offset and target.unit.mod_offset then
			local mo = target.unit.mod_offset

			fx.pos.x, fx.pos.y = fx.pos.x + mo.x, fx.pos.y + mo.y
			fx.render.sprites[1].sort_y_offset = -mo.y
		end

		fx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(fx)
	end

	return true
end

local function bullet_dragon_bone_cloud_update(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local dest = V.vclone(b.to)

	s.scale = s.scale or V.v(1, 1)
	s.ts = store.tick_ts

	local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

	s.r = angle

	local dist_offset = 0

	if this.dist_offset then
		dist_offset = this.dist_offset
	end

	s.scale.x = (V.dist(dest.x, dest.y, this.pos.x, this.pos.y) + dist_offset) / this.image_width

	U.y_wait_unconditional(store, b.hit_time)

	local hp = E:create_entity(b.hit_payload)

	hp.aura.level = this.bullet.level
	hp.aura.source_id = this.id
	hp.pos = V.vclone(dest)

	simulation:queue_insert_entity(hp)
	U.y_animation_wait_default(this)
	simulation:queue_remove_entity(this)
end

local function bolt_dragon_bone_basic_attack_update(this, store)
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

	b.hit_fx = is_flying and b.hit_fx_flying or b.hit_fx_floor
	b.ignore_hit_offset = not is_flying

	S:queue(this.sound_events.travel)

	s.z = Z_BULLETS
	s.sort_y_offset = nil

	U.animation_start_default(this, "idle", nil, store.tick_ts, true)

	if ps then
		ps.particle_system.emit = true
	end

	while V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length * (mspeed * store.tick_length) do
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
			b.to:copy(target.pos)

			if not b.ignore_hit_offset then
				b.to.x, b.to.y = b.to.x + target.unit.hit_offset.x, b.to.y + target.unit.hit_offset.y
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

	this.pos = V.vclone(b.to)

	S:queue(this.sound_events.hit)

	local function explosion(r, damage_min, damage_max, dty)
		local target_bans = bit.bor(F_FLYING)
		local target_pos = V.vclone(this.pos)

		if is_flying then
			target_bans = 0

			if target and target.flight_height then
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
				local d = E.assign_damage(dty, math.random(damage_min, damage_max), b.source_id, target.id)

				d.xp_gain_factor = b.xp_gain_factor
				d.xp_dest_id = b.source_id

				queue_damage(store, d)

				if b.mod then
					local mod = E:create_entity(b.mod)

					mod.modifier.target_id = target.id
					mod.modifier.source_id = b.source_id
					mod.xp_dest_id = b.source_id

					simulation:queue_insert_entity(mod)
				end
			end
		end
	end

	local p = SU.create_bullet_pop(store, this)

	if p then
		simulation:queue_insert_entity(p)
	end

	explosion(this.damage_range, b.damage_min, b.damage_max, b.damage_type)

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

local function hero_dragon_bone_level_up(this, store, initial)
	local hl, ls = level_up_basic(this)
	local b = E:get_template(this.ranged.attacks[1].bullet)

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	upgrade_skill(this, "cloud", function(this, s)
		local a = this.ranged.attacks[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local b = E:get_template(a.bullet)
		local aura = E:get_template(b.bullet.hit_payload)

		aura.aura.duration = s.duration[s.level]
	end)
	upgrade_skill(this, "nova", function(this, s)
		local a = this.ranged.attacks[3]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "rain", function(this, s)
		local a = this.ranged.attacks[4]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local b = E:get_template(a.entity)

		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]
		a.bones = s.bones_count[s.level]
	end)
	upgrade_skill(this, "burst", function(this, s)
		local a = this.ranged.attacks[5]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.proj_count = s.proj_count[s.level]

		local bullet = E:get_template(a.bullet)

		bullet.bullet.damage_min = s.damage_min[s.level]
		bullet.bullet.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		local u = this.ultimate

		u.disabled = nil

		local uc = E:get_template(s.controller_name)

		uc.cooldown = s.cooldown[s.level]

		local dog = E:get_template(uc.dog)

		dog.reinforcement.duration = s.duration[s.level]
		dog.health.hp_max = s.hp[s.level]
		dog.melee.attacks[1].damage_min = s.damage_min[s.level]
		dog.melee.attacks[1].damage_max = s.damage_max[s.level]
	end)
	update_hp(this)
end

local function hero_dragon_bone_update(this, store)
	local h = this.health
	local a
	local basic_ranged = this.ranged.attacks[1]
	local cloud_attack = this.ranged.attacks[2]
	local nova_attack = this.ranged.attacks[3]
	local rain_attack = this.ranged.attacks[4]
	local burst_attack = this.ranged.attacks[5]

	this.tween.disabled = false
	this.tween.ts = store.tick_ts
	this.health_bar.hidden = false

	U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts - fts(4), this.idle_flip.loop, nil, true)

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
			U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
		end

		while this.nav_rally.new do
			SU.y_hero_new_rally(store, this)
		end

		if SU.hero_level_up(store, this) then
			U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
		end

		a = this.ultimate

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			local target = U.detect_foremost_enemy_in_range_filter_off(this.pos, basic_ranged.max_range, F_BLOCK, F_NONE)

			if target and U.has_valid_rally_node_nearby(target.pos) then
				apply_ultimate(this, store, target.pos, "levelup")
			else
				a.ts = a.ts + 1
			end
		end

		a = cloud_attack

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			local _, targets, pred_pos = U.find_foremost_enemy_between_range_filter_on(this.pos, a.min_range, a.max_range, a.shoot_time + fts(10), a.vis_flags, a.vis_bans, function(v, o)
				return GR:cell_is(v.pos.x, v.pos.y, TERRAIN_LAND)
			end)

			if not targets or not pred_pos or #targets < a.min_targets then
				a.ts = a.ts + 0.4

				goto label_664_4
			end

			local target = targets[1]
			local start_ts = store.tick_ts
			local an, af = U.animation_name_facing_point(this, a.animation, pred_pos)

			S:queue(a.sound)
			U.animation_start_default(this, an, af, store.tick_ts)

			if SU.y_soldier_wait(store, this, a.shoot_time) then
				goto label_664_4
			end

			local b = E:create_entity(a.bullet)

			b.bullet.target_id = target.id
			b.bullet.source_id = this.id

			b.pos:copy(this.pos)

			local offset_index = af and 2 or 1
			local bullet_start_offset = a.bullet_start_offset[offset_index]

			b.pos.x = b.pos.x + (af and -1 or 1) * bullet_start_offset.x
			b.pos.y = b.pos.y + bullet_start_offset.y

			b.bullet.from:copy(b.pos)
			b.bullet.to:copy(pred_pos)
			simulation:queue_insert_entity(b)

			a.ts = start_ts

			SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])

			if SU.y_hero_animation_wait(this) then
				goto label_664_4
			end
		end

		a = nova_attack

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			if not GR:cell_is(this.pos.x, this.pos.y, TERRAIN_LAND) then
				goto label_664_4
			end

			local _, targets, pred_pos = U.find_foremost_enemy_between_range_filter_on(this.pos, a.min_range, a.max_range, a.hit_time, a.vis_flags, a.vis_bans_target, function(v, o)
				return GR:cell_is(v.pos.x, v.pos.y, TERRAIN_LAND)
			end)

			if not targets or not pred_pos or #targets < a.min_targets then
				a.ts = a.ts + 0.2

				goto label_664_4
			end

			local start_ts = store.tick_ts
			local an, af = U.animation_name_facing_point(this, a.animation, pred_pos)

			S:queue(a.sound)
			U.animation_start_default(this, an, af, store.tick_ts)

			if SU.y_soldier_wait(store, this, a.hit_time) then
				goto label_664_4
			end

			local targets = U.find_enemies_in_range_filter_off(this.pos, a.damage_radius, a.vis_flags, a.vis_bans_damage)

			if targets then
				for i, v in ipairs(targets) do
					local dist_factor = U.dist_factor_inside_ellipse(v.pos, this.pos, a.damage_radius)
					local d = E.assign_damage(a.damage_type, math.floor(a.damage_max - (a.damage_max - a.damage_min) * dist_factor) * this.unit.damage_factor, this.id, v.id)

					queue_damage(store, d)

					local m = E:create_entity(a.mod)

					m.modifier.target_id = v.id
					m.modifier.source_id = this.id

					simulation:queue_insert_entity(m)
				end
			end

			a.ts = start_ts

			SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
			SU.y_hero_animation_wait(this)
			U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

			goto label_664_4
		end

		a = rain_attack

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

			if not target then
				a.ts = a.ts + 0.4

				goto label_664_4
			end

			local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
			local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {pi}, nil, nil, NF_RALLY)

			if #nodes < 1 then
				a.ts = a.ts + 0.4

				goto label_664_4
			end

			local s_pi, _, s_ni = unpack(nodes[1])

			S:queue(a.sound)

			local flip = target.pos.x < this.pos.x

			U.animation_start_default(this, a.animation, flip, store.tick_ts)

			if SU.y_soldier_wait(store, this, a.spawn_time) then
				goto label_664_4
			end

			local delay = 0
			local n_step = ni < s_ni and -2 or 2

			ni = km.clamp(1, #P:path(s_pi), ni < s_ni and ni + 6 or ni)

			for i = 1, a.bones do
				local e = E:create_entity(a.entity)

				e.pos = P:node_pos(pi, spi, ni)

				local types = {"a", "b", "c"}
				local type = types[math.random(1, 3)]

				e.bone_type = type
				e.render.sprites[1].flip_x = flip
				e.render.sprites[2].flip_x = flip
				e.delay = delay
				e.bullet.source_id = this.id

				simulation:queue_insert_entity(e)

				delay = delay + fts(U.frandom(1, 3))
				ni = ni + n_step
				spi = km.zmod(spi + math.random(1, 2), 3)
			end

			U.y_animation_wait_default(this)

			a.ts = store.tick_ts

			SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])

			goto label_664_4
		end

		a = burst_attack

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			local target, targets = U.find_foremost_enemy_between_range_filter_on(this.pos, a.min_range, a.max_range, a.spawn_time + a.node_prediction, a.vis_flags, a.vis_bans, function(v, o)
				return GR:cell_is(v.pos.x, v.pos.y, bor(TERRAIN_LAND, TERRAIN_ICE))
			end)

			if not target or not targets or #targets < a.min_targets then
				a.ts = a.ts + 0.4
			else
				S:queue(a.sound)

				local flip = target.pos.x < this.pos.x

				U.animation_start_default(this, a.animation, flip, store.tick_ts)

				if SU.y_soldier_wait(store, this, a.spawn_time) then
					goto label_664_4
				end

				local function shuffle_table(nodes)
					for i = #nodes, 2, -1 do
						local j = math.random(i)

						nodes[i], nodes[j] = nodes[j], nodes[i]
					end

					return nodes
				end

				local function shoot_bullet_to_target(target)
					local node_offset = P:predict_enemy_node_advance(target, a.node_prediction)
					local e_ni = target.nav_path.ni + node_offset
					local e_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, e_ni)
					local b = E:create_entity(a.bullet)

					b.pos.x, b.pos.y = this.pos.x + a.bullet_start_offset.x, this.pos.y + a.bullet_start_offset.y

					b.bullet.from:copy(b.pos)

					b.bullet.to = e_pos
					b.bullet.damage_factor = this.unit.damage_factor
					b.bullet.source_id = this.id
					b.bullet.target_id = target.id
					b.bullet.damage_min = b.bullet.damage_min_config[this.hero.skills.burst.level]
					b.bullet.damage_max = b.bullet.damage_max_config[this.hero.skills.burst.level]

					simulation:queue_insert_entity(b)
				end

				local function shoot_bullet_to_pos(pos)
					local b = E:create_entity(a.bullet)

					b.pos.x, b.pos.y = this.pos.x + a.bullet_start_offset.x, this.pos.y + a.bullet_start_offset.y

					b.bullet.from:copy(b.pos)

					b.bullet.to = pos
					b.bullet.source_id = this.id
					b.bullet.damage_factor = this.unit.damage_factor

					simulation:queue_insert_entity(b)
				end

				local selected_targets = {}
				local selected_positions = {}
				local max_dist2 = a.max_dist_between_tgts * a.max_dist_between_tgts

				for i = 1, a.proj_count do
					if not targets or #targets == 0 or #selected_targets > a.proj_count / 2 then
						goto label_664_1
					end

					local sel_target = targets[1]

					table.insert(selected_targets, sel_target)
					table.remove(targets, 1)
				end

				if #selected_targets == a.proj_count then
					goto label_664_2
				end

				::label_664_1::

				do
					local nodes = P:get_all_valid_pos(this.pos.x, this.pos.y, 0, a.max_range, nil, nil, nil, {1})

					shuffle_table(nodes)

					for i = #selected_targets + 1, a.proj_count do
						local sel_node = nodes[1]

						table.insert(selected_positions, sel_node)
						table.remove(nodes, 1)

						for i = #nodes, 1, -1 do
							local n = nodes[i]

							if max_dist2 > V.dist2(sel_node.x, sel_node.y, n.x, n.y) then
								table.remove(nodes, i)
							end
						end
					end
				end

				::label_664_2::

				shuffle_table(selected_targets)

				for _, t in ipairs(selected_targets) do
					shoot_bullet_to_target(t)
					U.y_wait_unconditional(store, a.wait_between_shots)
				end

				shuffle_table(selected_positions)

				for _, p in pairs(selected_positions) do
					shoot_bullet_to_pos(p)
					U.y_wait_unconditional(store, a.wait_between_shots)
				end

				U.y_animation_wait_default(this)

				a.ts = store.tick_ts

				SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])

				goto label_664_4
			end
		end

		a = basic_ranged

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			local flight_time = a.estimated_flight_time or 1
			local pos_offset = v(this.pos.x + a.ignore_offset.x, this.pos.y + a.ignore_offset.y)
			local targets = U.find_enemies_between_range_filter_on(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, function(e)
				return V.dist2(pos_offset.x, pos_offset.y, e.pos.x, e.pos.y) > a.radius * a.radius
			end)

			if targets then
				local target = targets[1]
				local start_ts = store.tick_ts
				local b
				local node_offset = P:predict_enemy_node_advance(target, flight_time)
				local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
				local an, af = U.animation_name_facing_point(this, a.animation, t_pos)

				U.animation_start_default(this, an, af, store.tick_ts)
				S:queue(a.start_sound, a.start_sound_args)

				while store.tick_ts - start_ts < a.shoot_time do
					if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
						goto label_664_0
					end

					coroutine.yield()
				end

				b = E:create_entity(a.bullet)
				b.bullet.target_id = target.id
				b.bullet.source_id = this.id
				b.bullet.xp_dest_id = this.id

				b.pos:copy(this.pos)

				if a.bullet_start_offset and #a.bullet_start_offset == 2 then
					local bullet_start_offset = v(0, 0)

					if #a.bullet_start_offset == 2 then
						local offset_index = af and 2 or 1

						bullet_start_offset = a.bullet_start_offset[offset_index]
					else
						bullet_start_offset = V.vclone(a.bullet_start_offset)
					end

					b.pos.x = b.pos.x + (af and -1 or 1) * bullet_start_offset.x
					b.pos.y = b.pos.y + bullet_start_offset.y
				end

				b.bullet.from:copy(b.pos)

				if b.bullet.ignore_hit_offset then
					b.bullet.to = V.v(target.pos.x, target.pos.y)
				else
					b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
				end

				b.bullet.damage_factor = this.unit.damage_factor

				simulation:queue_insert_entity(b)

				if a.xp_from_skill then
					SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
				end

				a.ts = start_ts

				while not U.animation_finished_default(this) do
					if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
						goto label_664_0
					end

					coroutine.yield()
				end

				a.ts = start_ts

				U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

				::label_664_0::

				goto label_664_4
			end
		end

		::label_664_4::

		SU.soldier_idle(store, this)
		SU.soldier_regen(store, this)
		coroutine.yield()
	end
end

local function bullet_dragon_bone_rain_insert(this, store)
	this.render.sprites[1].name = this.sprite_prefix .. this.bone_type .. "_green_air"
	this.render.sprites[2].name = this.sprite_prefix .. this.bone_type .. "_ground"

	if this.render.sprites[1].flip_x then
		this.tween.props[3].keys[1][2].x = -this.tween.props[3].keys[1][2].x
		this.tween.props[3].keys[2][2].x = -this.tween.props[3].keys[2][2].x
	end

	return true
end

local function bullet_dragon_bone_rain_update(this, store)
	local b = this.bullet

	U.sprites_hide(this)

	if this.delay then
		U.y_wait_unconditional(store, this.delay)
	end

	U.sprites_show(this)

	this.tween.disabled = false
	this.tween.ts = store.tick_ts

	U.y_wait_unconditional(store, b.hit_time)

	this.render.sprites[1].name = this.sprite_prefix .. this.bone_type .. "_green_ground"
	this.render.sprites[1].offset = V.vv(0)
	this.render.sprites[2].hidden = false

	for i = 1, 3 do
		this.tween.props[i].disabled = true
	end

	this.tween.props[4].disabled = false
	this.tween.ts = store.tick_ts

	local fx = E:create_entity(b.hit_fx)

	fx.pos:copy(this.pos)

	fx.render.sprites[1].ts = store.tick_ts
	fx.render.sprites[1].runs = 0

	if this.bone_type == "c" then
		fx.render.sprites[1].scale = V.vv(0.6)
	end

	simulation:queue_insert_entity(fx)

	local decal = E:create_entity(b.hit_decal)

	decal.pos:copy(this.pos)

	decal.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(decal)
	S:queue(this.sound_events.hit)

	local targets = U.find_enemies_in_range_filter_off(this.pos, b.damage_radius, b.damage_flags, b.damage_bans)

	if targets then
		for _, target in ipairs(targets) do
			local d = E.assign_damage(b.damage_type, math.random(b.damage_min, b.damage_max) * this.bullet.damage_factor, this.id, target.id)

			queue_damage(store, d)

			local m = E:create_entity(b.mod)

			m.modifier.source_id = this.id
			m.modifier.target_id = target.id
			m.modifier.xp_dest_id = b.source_id

			simulation:queue_insert_entity(m)
		end
	end

	U.y_wait_unconditional(store, b.duration - b.hit_time)

	this.render.sprites[2].hidden = true

	local fx = E:create_entity(b.vanish_fx)

	fx.pos:copy(this.pos)

	fx.render.sprites[1].ts = store.tick_ts
	fx.render.sprites[1].runs = 0

	simulation:queue_insert_entity(fx)

	this.tween.props[4].disabled = true
	this.tween.props[5].disabled = false
	this.tween.ts = store.tick_ts
	this.tween.remove = true
end

local function bolt_dragon_bone_burst_insert(this, store)
	local b = this.bullet

	b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

	local s = this.render.sprites[1]

	if not b.ignore_rotation then
		s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
	end

	U.animation_start_default(this, "idle", nil, store.tick_ts, s.loop)

	return true
end

local function bolt_dragon_bone_burst_update(this, store)
	local b = this.bullet
	local fm = this.force_motion
	local target = store.entities[b.target_id]
	local ps
	local dmin, dmax = b.damage_min, b.damage_max

	local function move_step(dest)
		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)
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

	local function do_hit(hit_pos)
		local is_flying

		if target then
			local d = E.assign_damage(b.damage_type, math.random(dmin, dmax) * b.damage_factor, this.id, target.id)

			queue_damage(store, d)

			is_flying = U.flag_has(target.vis.flags, F_FLYING)

			local m = E:create_entity(b.mod)

			m.modifier.source_id = this.id
			m.modifier.target_id = target.id
			m.modifier.xp_dest_id = b.source_id

			simulation:queue_insert_entity(m)
		end

		S:queue(this.sound_events.hit)

		if is_flying then
			local fx = E:create_entity(b.hit_fx_flying)

			fx.pos:copy(hit_pos)

			fx.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(fx)
		else
			local fx = E:create_entity(b.hit_fx_floor)

			fx.pos:copy(hit_pos)

			fx.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(fx)
		end
	end

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.emit = true
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	local pred_pos

	if target then
		pred_pos = P:predict_enemy_pos(target, fts(5))
	else
		pred_pos = b.to
	end

	local iix, iiy = V.normalize(pred_pos.x - this.pos.x, pred_pos.y - this.pos.y)
	local last_pos = V.vclone(this.pos)

	b.ts = store.tick_ts

	while true do
		target = store.entities[b.target_id]

		if target and target.health and not target.health.dead and band(target.vis.bans, F_RANGED) == 0 then
			local hit_offset = V.v(0, 0)

			if not b.ignore_hit_offset then
				hit_offset.x = target.unit.hit_offset.x
				hit_offset.y = target.unit.hit_offset.y
			end

			local d = math.max(math.abs(target.pos.x + hit_offset.x - b.to.x), math.abs(target.pos.y + hit_offset.y - b.to.y))

			if d > b.max_track_distance then
				log.debug("BOLT MAX DISTANCE FAIL. (%s) %s / dist:%s target.pos:%s,%s b.to:%s,%s", this.id, this.template_name, d, target.pos.x, target.pos.y, b.to.x, b.to.y)

				target = nil
				b.target_id = nil
			else
				b.to.x, b.to.y = target.pos.x + hit_offset.x, target.pos.y + hit_offset.y
			end
		end

		if this.initial_impulse and store.tick_ts - b.ts < this.initial_impulse_duration then
			local t = store.tick_ts - b.ts

			if this.initial_impulse_angle_abs then
				fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(this.initial_impulse_angle_abs, 1, 0))
			else
				local angle = this.initial_impulse_angle

				if iix < 0 then
					angle = angle * -1
				end

				fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(angle, iix, iiy))
			end
		end

		last_pos.x, last_pos.y = this.pos.x, this.pos.y

		if move_step(b.to) then
			break
		end

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - last_pos.x, this.pos.y - last_pos.y)
		end

		coroutine.yield()
	end

	this.render.sprites[1].hidden = true

	do_hit(b.to)

	if ps and ps.particle_system.emit then
		ps.particle_system.emit = false
	end

	U.y_wait_unconditional(store, fts(10))
	simulation:queue_remove_entity(this)
end

local function hero_dragon_bone_ultimate_update(this, store)
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_POWER_3)

	if #nodes < 1 then
		log.error("hero_dragon_bone_ultimate: could not find valid node")
		simulation:queue_remove_entity(this)

		return
	end

	local x, y = this.pos.x, this.pos.y
	local pos1 = V.v(x + 12, y - 12)
	local pos2 = V.v(x - 12, y + 12)
	local fx = E:create_entity(this.spawn_fx)

	fx.pos:copy(pos1)

	fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(fx)

	local fx = E:create_entity(this.spawn_fx)

	fx.pos:copy(pos2)

	fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(fx)
	U.y_wait_unconditional(store, this.spawn_time)

	local e = E:create_entity(this.dog)

	e.pos = V.vclone(pos1)
	e.nav_rally.center = V.v(x, y)
	e.nav_rally.pos = V.vclone(e.pos)
	e.reinforcement.squad_id = this.id

	simulation:queue_insert_entity(e)

	e = E:create_entity(this.dog)
	e.pos = V.vclone(pos2)
	e.nav_rally.center = V.v(x, y)
	e.nav_rally.pos = V.vclone(e.pos)
	e.reinforcement.squad_id = this.id

	simulation:queue_insert_entity(e)
	simulation:queue_remove_entity(this)
end

tt = RT("ps_bolt_dragon_bone_basic_attack")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_dragon_bone_projectile_trail_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.emission_rate = 20
tt.particle_system.emit_rotation_spread = math.pi / 2
tt.particle_system.z = Z_FLYING_HEROES
tt = RT("ps_bolt_dragon_bone_burst")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_dragon_bone_burst_projectile_trail_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(14), fts(14)}
tt.particle_system.emission_rate = 50
tt.particle_system.emit_area_spread = vec_2(5, 0)
tt.particle_system.scales_y = {1, 0.5}
tt.particle_system.scales_x = {1, 0.5}
tt = RT("fx_bolt_dragon_bone_basic_attack_hit", "fx")
tt.render.sprites[1].name = "hero_dragon_bone_hit_idle"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.render.sprites[1].sort_y_offset = -5
tt.render.sprites[1].scale = vec_1(1)
tt = RT("fx_bolt_dragon_bone_basic_attack_hit_flying", "fx")
tt.render.sprites[1].name = "hero_dragon_bone_hit_air_idle"
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.render.sprites[1].scale = vec_1(1)
tt = RT("fx_dragon_bone_plague_explosion", "fx")
tt.render.sprites[1].name = "hero_dragon_bone_plague_explosion_idle"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.render.sprites[1].scale = vec_1(1)
tt = RT("fx_bullet_dragon_bone_rain", "fx")
tt.render.sprites[1].name = "hero_dragon_bone_bones_fx_idle"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.render.sprites[1].scale = vec_1(1)
tt = RT("fx_bullet_dragon_bone_rain_vanish", "fx")
tt.render.sprites[1].name = "hero_dragon_bone_bones_despawn_fx_idle"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.render.sprites[1].scale = vec_1(1)
tt = RT("fx_dragon_bone_dog_spawn", "fx")
tt.render.sprites[1].name = "hero_dragon_bone_drake_spawn_fx_idle"
tt.render.sprites[1].anchor = vec_2(0.5, 0.4)
tt.render.sprites[1].scale = vec_1(1)
tt = RT("fx_dragon_bone_dog_hit", "fx")
tt.render.sprites[1].name = "hero_dragon_bone_drake_hit_fx_idle"
tt.render.sprites[1].scale = vec_1(1)
tt = RT("decal_dragon_bone_cloud", "decal_tween")
tt.render.sprites[1].name = "hero_dragon_bone_cloud_b"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].scale = vec_1(1)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "hero_dragon_bone_cloud"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].offset = vec_2(0, 15)
tt.render.sprites[2].sort_y_offset = -25
tt.render.sprites[2].scale = vec_1(1)
tt.tween.props[1].keys = {{0, 0}, {fts(18), 255}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {{0, 0}, {fts(18), 255}}
tt.tween.props[2].sprite_id = 2
tt.tween.disabled = false
tt.tween.remove = false
tt = RT("decal_bullet_dragon_bone_rain", "decal_timed")
tt.render.sprites[1].name = "hero_dragon_bone_bones_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].scale = vec_1(1)
tt.timed.duration = fts(27)
tt = RT("hero_dragon_bone", "hero")

AC(tt, "ranged", "timed_attacks", "tween")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {409, 442, 474, 507, 539, 572, 604, 637, 669, 702}
tt.hero.level_stats.melee_damage_max = {1, 2, 4, 4, 5, 6, 7, 8, 9, 10}
tt.hero.level_stats.melee_damage_min = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
tt.hero.level_stats.ranged_damage_min = {14, 16, 20, 23, 26, 28, 32, 35, 37, 41}
tt.hero.level_stats.ranged_damage_max = {22, 26, 31, 35, 39, 44, 48, 52, 57, 59}
tt.hero.skills.cloud = CC("hero_skill")
tt.hero.skills.cloud.cooldown = {15, 15, 15}
tt.hero.skills.cloud.duration = {4, 6, 10}
tt.hero.skills.cloud.xp_gain = {120, 240, 360}
tt.hero.skills.cloud.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.nova = CC("hero_skill")
tt.hero.skills.nova.cooldown = {24, 24, 24}
tt.hero.skills.nova.damage_min = {26, 80, 109}
tt.hero.skills.nova.damage_max = {52, 153, 202}
tt.hero.skills.nova.xp_gain = {192, 384, 576}
tt.hero.skills.nova.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.rain = CC("hero_skill")
tt.hero.skills.rain.cooldown = {20, 20, 20}
tt.hero.skills.rain.damage_min = {15, 31, 46}
tt.hero.skills.rain.damage_max = {23, 46, 70}
tt.hero.skills.rain.bones_count = {4, 6, 8}
tt.hero.skills.rain.xp_gain = {160, 320, 400}
tt.hero.skills.rain.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.burst = CC("hero_skill")
tt.hero.skills.burst.cooldown = {32, 32, 32}
tt.hero.skills.burst.damage_min = {31, 75, 112}
tt.hero.skills.burst.damage_max = {46, 112, 169}
tt.hero.skills.burst.proj_count = {6, 8, 10}
tt.hero.skills.burst.xp_gain = {240, 480, 720}
tt.hero.skills.burst.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.cooldown = {36, 36, 36, 36}
tt.hero.skills.ultimate.duration = {10, 15, 20, 25}
tt.hero.skills.ultimate.hp = {130, 156, 195, 234}
tt.hero.skills.ultimate.damage_min = {13, 14, 18, 27}
tt.hero.skills.ultimate.damage_max = {18, 22, 28, 40}
tt.hero.skills.ultimate.controller_name = "hero_dragon_bone_ultimate"
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.xp_gain_factor = 36
tt.flight_height = 80
tt.health.dead_lifetime = 15
tt.health_bar.draw_order = -1
tt.health_bar.offset = vec_2(0, 170)
tt.health_bar.sort_y_offset = -171
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.health_bar.z = Z_FLYING_HEROES
tt.hero.fn_level_up = hero_dragon_bone_level_up
tt.idle_flip.cooldown = 10
tt.info.hero_portrait = "kr5_hero_portraits_0014"
tt.info.portrait = "kr5_info_portraits_heroes_0014"
tt.main_script.update = hero_dragon_bone_update
tt.motion.max_speed = 130
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.all_except_flying_nowalk = bor(TERRAIN_NONE, TERRAIN_LAND, TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_SHALLOW, TERRAIN_FAERIE, TERRAIN_ICE)
tt.nav_grid.valid_terrains = tt.all_except_flying_nowalk
tt.nav_grid.valid_terrains_dest = tt.all_except_flying_nowalk
tt.drag_line_origin_offset = vec_2(0, tt.flight_height)
tt.regen.cooldown = 1
tt.render.sprites[1].offset.y = tt.flight_height
tt.render.sprites[1].prefix = "hero_dragon_bone_hero"
tt.render.sprites[1].name = "respawn"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_dragon_bone_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.sound_events.change_rally_point = "HeroDragonBoneTaunt"
tt.sound_events.death = "HeroDragonBoneDeath"
tt.sound_events.respawn = "HeroDragonBoneTauntIntro"
tt.sound_events.hero_room_select = "HeroDragonBoneTauntSelect"
tt.ui.click_rect = r(-37, tt.flight_height - 20, 90, 85)
tt.unit.hit_offset = vec_2(0, tt.flight_height + 10)
tt.unit.mod_offset = vec_2(0, tt.flight_height + 10)
tt.unit.death_animation = "death"
tt.unit.hide_after_death = true
tt.hero.tombstone_decal = nil
tt.hero.respawn_animation = "respawn"
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_POISON, F_MOD)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].max_range = 220
tt.ranged.attacks[1].shoot_time = fts(16)
tt.ranged.attacks[1].bullet = "bolt_dragon_bone_basic_attack"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(46, tt.flight_height - 23), vec_2(50, tt.flight_height - 23)}
tt.ranged.attacks[1].sync_animation = true
tt.ranged.attacks[1].vis_flags = bor(F_RANGED, F_AREA)
tt.ranged.attacks[1].ignore_offset = vec_2(0, tt.flight_height + 10)
tt.ranged.attacks[1].radius = 60
tt.ranged.attacks[1].basic_attack = true
tt.ranged.attacks[2] = CC("aura_attack")
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].animation = "breath"
tt.ranged.attacks[2].shoot_time = fts(14)
tt.ranged.attacks[2].min_targets = 3
tt.ranged.attacks[2].min_range = 50
tt.ranged.attacks[2].max_range = 225
tt.ranged.attacks[2].bullet = "bullet_dragon_bone_cloud"
tt.ranged.attacks[2].bullet_start_offset = table.deepclone(tt.ranged.attacks[1].bullet_start_offset)
tt.ranged.attacks[2].sync_animation = true
tt.ranged.attacks[2].xp_from_skill = "cloud"
tt.ranged.attacks[2].vis_flags = bor(F_RANGED, F_AREA)
tt.ranged.attacks[2].vis_bans = F_FLYING
tt.ranged.attacks[2].sound = "HeroDragonBonePlagueCloudCast"
tt.ranged.attacks[3] = CC("area_attack")
tt.ranged.attacks[3].disabled = true
tt.ranged.attacks[3].animation = "nova"
tt.ranged.attacks[3].hit_time = fts(22)
tt.ranged.attacks[3].min_targets = 3
tt.ranged.attacks[3].max_range = 75
tt.ranged.attacks[3].damage_radius = 75
tt.ranged.attacks[3].mod = "mod_dragon_bone_plague"
tt.ranged.attacks[3].sync_animation = true
tt.ranged.attacks[3].xp_from_skill = "nova"
tt.ranged.attacks[3].vis_flags = bor(F_AREA)
tt.ranged.attacks[3].vis_bans_target = F_FLYING
tt.ranged.attacks[3].vis_bans_damage = F_FRIEND
tt.ranged.attacks[3].sound = "HeroDragonBoneDiseaseNovaCast"
tt.ranged.attacks[4] = CC("spawn_attack")
tt.ranged.attacks[4].disabled = true
tt.ranged.attacks[4].animation = "bone_rain"
tt.ranged.attacks[4].entity = "bullet_dragon_bone_rain"
tt.ranged.attacks[4].spawn_time = fts(19)
tt.ranged.attacks[4].vis_flags = bor(F_RANGED)
tt.ranged.attacks[4].vis_bans = bor(F_FLYING)
tt.ranged.attacks[4].min_range = 50
tt.ranged.attacks[4].max_range = 200
tt.ranged.attacks[4].xp_from_skill = "rain"
tt.ranged.attacks[4].sound = "HeroDragonBoneSpineRainCast"
tt.ranged.attacks[5] = CC("spawn_attack")
tt.ranged.attacks[5].disabled = true
tt.ranged.attacks[5].animation = "burst"
tt.ranged.attacks[5].bullet = "bolt_dragon_bone_burst"
tt.ranged.attacks[5].bullet_start_offset = vec_2(0, tt.flight_height + 25)
tt.ranged.attacks[5].spawn_time = fts(24)
tt.ranged.attacks[5].vis_flags = bor(F_RANGED)
tt.ranged.attacks[5].vis_bans = bor(F_FLYING)
tt.ranged.attacks[5].min_targets = 5
tt.ranged.attacks[5].min_range = 0
tt.ranged.attacks[5].max_range = 300
tt.ranged.attacks[5].max_dist_between_tgts = 50
tt.ranged.attacks[5].wait_between_shots = fts(1)
tt.ranged.attacks[5].node_prediction = fts(45)
tt.ranged.attacks[5].xp_from_skill = "burst"
tt.ranged.attacks[5].sound = "HeroDragonBoneSpreadingBurstCast"
tt.ultimate = {
	ts = 0,
	cooldown = 36,
	vis_ban = F_FLYING,
	disabled = true
}
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt = RT("hero_dragon_bone_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.main_script.update = hero_dragon_bone_ultimate_update
tt.spawn_delay = fts(5)
tt.vis_flags = bor(F_RANGED)
tt.vis_bans = bor(F_FLYING)
tt.dog = "soldier_dragon_bone_ultimate_dog"
tt.spawn_fx = "fx_dragon_bone_dog_spawn"
tt.spawn_time = fts(12)
tt.prediction_nodes = fts(15)
tt.sound_events.insert = "HeroDragonBoneUltimateCast"
tt = RT("soldier_dragon_bone_ultimate_dog", "soldier_militia")

AC(tt, "reinforcement", "nav_grid", "tween")

tt.health.armor = 0
tt.health.hp_max = {130, 156, 195, 234}
tt.health_bar.offset = vec_2(0, 30)
tt.info.portrait = "kr5_info_portraits_soldiers_0020"
tt.info.random_name_format = nil
tt.info.random_name_count = nil
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].hit_fx = "fx_dragon_bone_dog_hit"
tt.melee.attacks[1].hit_offset = vec_2(20, 5)
tt.melee.range = 72
tt.motion.max_speed = 95
tt.regen.health = 0
tt.reinforcement.duration = {10, 15, 20, 25}
tt.render.sprites[1].prefix = "hero_dragon_bone_drake"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.render.sprites[1].scale = vec_1(1)
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.unit.hit_offset = vec_2(0, 5)
tt.unit.mod_offset = vec_2(0, 14)
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN, F_POISON)
tt = RT("bolt_dragon_bone_basic_attack", "bolt")

AC(tt, "force_motion")

tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.hit_fx = nil
tt.bullet.hit_fx_floor = "fx_bolt_dragon_bone_basic_attack_hit"
tt.bullet.hit_fx_flying = "fx_bolt_dragon_bone_basic_attack_hit_flying"
tt.bullet.particles_name = "ps_bolt_dragon_bone_basic_attack"
tt.bullet.max_speed = 600
tt.bullet.align_with_trajectory = true
tt.bullet.min_speed = 600
tt.bullet.xp_gain_factor = 1.4
tt.bullet.ignore_hit_offset = true
tt.bullet.pop_chance = 0
tt.bullet.mod = "mod_dragon_bone_plague"
tt.force_motion.a_step = 5
tt.force_motion.max_a = 3000
tt.force_motion.max_v = 600
tt.initial_impulse = 10
tt.render.sprites[1].prefix = "hero_dragon_bone_projectile"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[1].scale = vec_1(1)
tt.main_script.update = bolt_dragon_bone_basic_attack_update
tt.damage_range = 60
tt.sound_events.insert = "HeroDragonBoneBasicAttackCast"
tt.sound_events.hit = "HeroDragonBoneBasicAttackImpact"
tt = RT("bullet_dragon_bone_cloud", "bullet")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_time = fts(10)
tt.bullet.ignore_hit_offset = true
tt.bullet.hit_payload = "aura_dragon_bone_cloud"
tt.hit_fx_only_no_target = true
tt.image_width = 150
tt.main_script.update = bullet_dragon_bone_cloud_update
tt.render.sprites[1].name = "hero_dragon_bone_breath_idle"
tt.render.sprites[1].loop = false
tt.render.sprites[1].scale = vec_1(1)
tt.sound_events.insert = "TowerArcaneWizardBasicAttack"
tt.track_target = false
tt.ray_duration = fts(42)
tt = RT("bullet_dragon_bone_rain", "bullet")

AC(tt, "tween")

tt.main_script.insert = bullet_dragon_bone_rain_insert
tt.main_script.update = bullet_dragon_bone_rain_update
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_radius = 50
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_bans = F_FRIEND
tt.bullet.mod = "mod_dragon_bone_rain_stun"
tt.bullet.hit_decal = "decal_bullet_dragon_bone_rain"
tt.bullet.hit_fx = "fx_bullet_dragon_bone_rain"
tt.bullet.vanish_fx = "fx_bullet_dragon_bone_rain_vanish"
tt.bullet.hit_time = fts(4)
tt.bullet.duration = 1
tt.render.sprites[1].name = "hero_dragon_bone_bones_"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].scale = vec_1(1)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "hero_dragon_bone_bones_"
tt.render.sprites[2].animated = false
tt.render.sprites[2].hidden = true
tt.render.sprites[2].alpha = 0
tt.render.sprites[2].scale = vec_1(1)
tt.sprite_prefix = "hero_dragon_bone_bones_"
tt.bone_type = "a"
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 0}, {tt.bullet.hit_time, 255}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(0.5)}, {tt.bullet.hit_time, vec_1(1)}}
tt.tween.props[3] = CC("tween_prop")
tt.tween.props[3].name = "offset"
tt.tween.props[3].keys = {{0, vec_2(-50, 100)}, {tt.bullet.hit_time, vec_2(-5, 10)}}
tt.tween.props[4] = CC("tween_prop")
tt.tween.props[4].name = "alpha"
tt.tween.props[4].sprite_id = 2
tt.tween.props[4].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[4].disabled = true
tt.tween.props[5] = CC("tween_prop")
tt.tween.props[5].name = "alpha"
tt.tween.props[5].keys = {{0, 255}, {fts(12), 0}}
tt.tween.props[5].disabled = true
tt.sound_events.hit = "HeroDragonBoneSpineRainImpact"
tt = RT("bolt_dragon_bone_burst", "bolt")

AC(tt, "force_motion")

tt.render.sprites[1].prefix = "hero_dragon_bone_burst_projectile"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].scale = vec_1(1)
tt.height_attack = 70
tt.initial_vel_y = 50
tt.transition_time = 1
tt.target_distance_detection = 20
tt.main_script.insert = bolt_dragon_bone_burst_insert
tt.main_script.update = bolt_dragon_bone_burst_update
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_max_config = {46, 112, 169}
tt.bullet.damage_min_config = {31, 75, 112}
tt.bullet.damage_max = 46
tt.bullet.damage_min = 31
tt.bullet.acceleration_factor = 0.1
tt.bullet.particles_name = "ps_bolt_dragon_bone_burst"
tt.bullet.max_speed = 1800
tt.bullet.hit_sound = "Stage03HeartOfTheForestBlast"
tt.bullet.hit_fx_floor = "fx_bolt_dragon_bone_basic_attack_hit"
tt.bullet.hit_fx_flying = "fx_bolt_dragon_bone_basic_attack_hit_flying"
tt.bullet.align_with_trajectory = true
tt.bullet.mod = "mod_dragon_bone_plague"
tt.initial_impulse = 12000
tt.initial_impulse_duration = 0.1
tt.initial_impulse_angle = math.pi / 2
tt.force_motion.a_step = 15
tt.force_motion.max_a = 1650
tt.force_motion.max_v = 510
tt.sound_events.insert = nil
tt.sound_events.hit = "HeroDragonBoneSpreadingBurstImpact"
tt = RT("aura_dragon_bone_cloud", "aura")

AC(tt, "render", "tween")

tt.aura.duration = nil
tt.aura.radius = 100
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.vis_flags = bor(F_AREA)
tt.aura.mods = {"mod_dragon_bone_plague", "mod_dragon_bone_cloud_slow"}
tt.aura.cycle_time = fts(10)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = aura_dragon_bone_cloud_update
tt.render.sprites[1].prefix = "hero_dragon_bone_cloud_decal"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].scale = vec_1(1)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "hero_dragon_bone_cloud_b_bubbles"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].scale = vec_1(1)
tt.render.sprites[2].offset = vec_2(0, 10)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "hero_dragon_bone_cloud_b_bubbles"
tt.render.sprites[3].name = "idle"
tt.render.sprites[3].flip_x = true
tt.render.sprites[3].offset = vec_2(0, -10)
tt.render.sprites[3].scale = vec_1(1)
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {fts(18), 255}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {{0, 0}, {fts(18), 255}}
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = CC("tween_prop")
tt.tween.props[3].name = "alpha"
tt.tween.props[3].keys = {{0, 0}, {fts(18), 255}}
tt.tween.props[3].sprite_id = 2
tt.tween.remove = false
tt.decal_cloud_t = "decal_dragon_bone_cloud"
tt = RT("mod_dragon_bone_plague", "modifier")

AC(tt, "render", "dps")

tt.modifier.duration = 4
tt.modifier.vis_flags = F_MOD
tt.render.sprites[1].prefix = "hero_dragon_bone_plague_fx"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].scale = vec_1(1)
tt.dps.damage_min = 1
tt.dps.damage_max = 1
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = 0.25
tt.spread_radius = 60
tt.spread_damage_min = 15
tt.spread_damage_max = 15
tt.spread_fx = "fx_dragon_bone_plague_explosion"
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.main_script.remove = mod_dragon_bone_plague_remove
tt = RT("mod_dragon_bone_cloud_slow", "mod_slow")
tt.slow.factor = 0.5
tt = RT("mod_dragon_bone_rain_stun", "mod_stun")
tt.modifier.duration = 0.25
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
