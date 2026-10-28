local scripts = require("scripts")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local bit = require("bit")
local HU = require("hero_utils")
local log = require("lib.klua.log"):new("hero_scripts")
local band = bit.band
local bor = bit.bor
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local vv = V.vv
local tt

local function aura_hero_bird_cluster_bomb_fire_remove(this, store)
	this.tween.ts = store.tick_ts
	this.tween.reverse = true
	this.tween.remove = true
	this.tween.props[1].keys[2][1] = fts(10)
	this.tween.props[2].keys[2][1] = fts(10)

	return true
end

local function decal_hero_bird_tomb_update(this, store)
	U.y_animation_play(this, "death", nil, store.tick_ts, 1)

	while true do
		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function controller_bullet_hero_bird_cluster_bomb_part_update(this, store)
	local floor_pos = V.vclone(this.pos)

	floor_pos.y = floor_pos.y - this.explosion_height

	local nodes = {}
	local floor_node = P:nearest_nodes(floor_pos.x, floor_pos.y)[1]
	local path_pi, _, path_ni = unpack(floor_node)

	table.insert(nodes, 1, P:node_pos(path_pi, 1, path_ni + 3))
	table.insert(nodes, 2, P:node_pos(path_pi, 2, path_ni))
	table.insert(nodes, 3, P:node_pos(path_pi, 3, path_ni - 3))

	for _, n in ipairs(nodes) do
		local part = E:create_entity(this.part_template)

		part.pos:copy(this.pos)
		part.bullet.from:copy(part.pos)
		part.bullet.to:copy(n)

		part.bullet.source_id = this.source_id
		part.bullet.xp_dest_id = this.source_id

		simulation:queue_insert_entity(part)
	end

	simulation:queue_remove_entity(this)
end

local function hero_bird_level_up(this, store, initial)
	local hl, ls = level_up_basic(this)
	local b = E:get_template(this.ranged.attacks[1].bullet)

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	upgrade_skill(this, "cluster_bomb", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local bt = E:get_template(a.bullet)
		local controller = E:get_template(bt.bullet.hit_payload)
		local b_part = E:get_template(controller.part_template)

		b_part.bullet.damage_min = s.explosion_damage_min[s.level]
		b_part.bullet.damage_max = s.explosion_damage_max[s.level]

		local aura = E:get_template(b_part.bullet.hit_payload)

		aura.aura.duration = s.fire_duration[s.level]

		local mod = E:get_template(aura.aura.mod)

		mod.dps.damage_min = s.burn_damage_min[s.level]
		mod.dps.damage_max = s.burn_damage_max[s.level]
	end)
	upgrade_skill(this, "shout_stun", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local m1 = E:get_template(a.mods[1])

		m1.modifier.duration = s.stun_duration[s.level]

		local m2 = E:get_template(a.mods[2])

		m2.modifier.duration = m1.modifier.duration + s.slow_duration[s.level]
	end)
	upgrade_skill(this, "gattling", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.duration = s.duration[s.level]
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "eat_instakill", function(this, s)
		local a = this.timed_attacks.list[4]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.hp_max = s.hp_max[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil
		this.ultimate.cooldown = s.cooldown[s.level]

		local uc = E:get_template(s.controller_name)

		uc.cooldown = s.cooldown[s.level]

		local child = E:get_template(uc.child)

		child.melee.attacks[1].damage_min = s.damage_min[s.level]
		child.melee.attacks[1].damage_max = s.damage_max[s.level]
		child.duration = s.duration[s.level]
	end)
	update_hp(this)
end

local function hero_bird_update(this, store)
	local h = this.health
	local cluster_bomb_attack = this.timed_attacks.list[1]
	local shout_stun_attack = this.timed_attacks.list[2]
	local gattling_attack = this.timed_attacks.list[3]
	local eat_instakill_attack = this.timed_attacks.list[4]

	for i = 1, #this.timed_attacks.list do
		if not this.timed_attacks.list[i].disabled then
			this.timed_attacks.list[i].ts = store.tick_ts - this.timed_attacks.list[i].cooldown
		end
	end

	this.tween.disabled = false
	this.tween.ts = store.tick_ts
	this.health_bar.hidden = false

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
	U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

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

		if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
			local target = U.find_foremost_enemy_in_range_filter_off(this.pos, 200, 0, F_AREA, 0)

			if target and target.pos then
				local e = E:create_entity(this.hero.skills.ultimate.controller_name)

				e.level = this.hero.skills.ultimate.level
				e.pos = V.vclone(target.pos)

				simulation:queue_insert_entity(e)

				this.ultimate.ts = store.tick_ts

				SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
			else
				this.ultimate.ts = this.ultimate.ts + 1
			end
		end

		for _, a in ipairs(this.timed_attacks.list) do
			if a.disabled then
			-- block empty
			elseif a.sync_animation and not this.render.sprites[1].sync_flag then
			-- block empty
			elseif store.tick_ts - a.ts < a.cooldown then
			-- block empty
			elseif a == cluster_bomb_attack then
				local target, targets, pred_pos = U.find_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans)

				if not targets or #targets < a.min_targets or not pred_pos then
				-- block empty
				else
					local start_ts = store.tick_ts
					local b
					local bullet_start_offset = v(0, 0)
					local an, af = U.animation_name_facing_point(this, a.animation, pred_pos)

					U.animation_start_default(this, an, af, store.tick_ts)
					S:queue(a.start_sound, a.start_sound_args)

					if SU.y_hero_wait(store, this, a.shoot_time) then
					-- block empty
					else
						b = E:create_entity(a.bullet)
						b.bullet.target_id = target.id
						b.bullet.source_id = this.id
						b.bullet.xp_dest_id = this.id

						b.pos:copy(this.pos)

						if a.bullet_start_offset and #a.bullet_start_offset == 2 then
							local offset_index = af and 2 or 1

							bullet_start_offset = a.bullet_start_offset[offset_index]
						end

						b.pos.x = b.pos.x + (af and -1 or 1) * bullet_start_offset.x
						b.pos.y = b.pos.y + bullet_start_offset.y

						b.bullet.from:copy(b.pos)

						b.bullet.to = V.v(pred_pos.x, pred_pos.y + a.first_explosion_height)
						b.bullet.damage_factor = this.unit.damage_factor

						simulation:queue_insert_entity(b)

						a.ts = start_ts

						if SU.y_hero_wait(store, this, a.explosion_time) then
						-- block empty
						else
							do
								local ray = E:create_entity(a.ray)

								ray.pos = V.vclone(this.pos)

								local offset = a.ray_start_offset[1]

								if this.render.sprites[1].flip_x then
									offset = a.ray_start_offset[2]
								end

								ray.pos.x = ray.pos.x + offset.x
								ray.pos.y = ray.pos.y + offset.y
								ray.render.sprites[1].ts = store.tick_ts

								local b_pos_x, b_pos_y = SU.position_in_parabola(store.tick_ts - b.bullet.ts + fts(8.5), b.bullet.from, b.bullet.speed, b.bullet.g)

								ray.render.sprites[1].r = V.angleTo(b_pos_x - this.pos.x, b_pos_y - this.pos.y)
								ray.render.sprites[1].scale.x = V.dist(b_pos_x, b_pos_y, this.pos.x, this.pos.y) / a.ray_width

								simulation:queue_insert_entity(ray)
							end

							if a.xp_from_skill then
								SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
							end

							if SU.y_hero_animation_wait(this) then
							-- block empty
							else
								U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
							end
						end
					end

					break
				end
			elseif a == shout_stun_attack then
				local _, targets, pred_pos = U.find_foremost_enemy_in_range_filter_off(this.pos, a.radius, a.node_prediction, a.vis_flags, a.vis_bans)

				if not targets or #targets < a.min_targets or not pred_pos then
				-- block empty
				else
					local start_ts = store.tick_ts
					local an, af = U.animation_name_facing_point(this, a.animation, pred_pos)

					U.animation_start_default(this, an, af, store.tick_ts)
					S:queue(a.sound)

					if SU.y_hero_wait(store, this, a.shoot_time) then
					-- block empty
					else
						local targets = U.find_enemies_in_range_filter_off(this.pos, a.radius, a.vis_flags, a.vis_bans)

						if targets and #targets > 0 then
							for _, t in ipairs(targets) do
								local mods = a.mods or {a.mod}

								for _, m in ipairs(mods) do
									local mod = E:create_entity(m)

									mod.modifier.target_id = t.id
									mod.modifier.source_id = this.id

									simulation:queue_insert_entity(mod)
								end
							end
						end

						local decal = E:create_entity(a.decal)

						decal.pos:copy(this.pos)

						decal.render.sprites[1].ts = store.tick_ts

						simulation:queue_insert_entity(decal)

						a.ts = start_ts

						if a.xp_from_skill then
							SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
						end

						if SU.y_hero_animation_wait(this) then
						-- block empty
						else
							U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
						end
					end
				end
			elseif a == gattling_attack then
				local target, _, pred_pos = U.find_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans)

				if not target or not pred_pos then
				-- block empty
				else
					local start_ts = store.tick_ts
					local an, af = U.animation_name_facing_point(this, a.animation_in, pred_pos)

					U.animation_start_default(this, an, af, store.tick_ts, false)

					if SU.y_hero_animation_wait(this) then
					-- block empty
					else
						if not target or target.health.dead then
							target, _, pred_pos = U.find_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans)

							if not target or target.health.dead then
								goto label_515_1
							end
						end

						local shoot_start_ts = store.tick_ts

						S:queue(a.sound)

						local an, af = U.animation_name_facing_point(this, a.animation_loop, target.pos)

						U.animation_start_default(this, an, af, store.tick_ts, true)

						local function do_gattling_damage(target)
							local d = E.assign_damage(a.damage_type, math.random(a.damage_min, a.damage_max), this.id, target.id)

							queue_damage(store, d)

							local fx = E:create_entity(a.hit_fx)

							fx.pos:copy(target.pos)

							if target.unit and target.unit.hit_offset then
								fx.pos.x = fx.pos.x + target.unit.hit_offset.x
								fx.pos.y = fx.pos.y + target.unit.hit_offset.y
							end

							fx.render.sprites[1].ts = store.tick_ts

							simulation:queue_insert_entity(fx)
						end

						while store.tick_ts - shoot_start_ts < a.duration and target and not target.health.dead do
							if band(target.vis.flags, F_FLYING) ~= 0 then
								do_gattling_damage(target)
							else
								local ni = target.nav_path.ni + P:predict_enemy_node_advance(target, fts(10))
								local f_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, ni)
								local rand_var = 15
								local b_pos = V.vclone(f_pos)

								b_pos.x = b_pos.x + math.random(-rand_var, rand_var)
								b_pos.y = b_pos.y + math.random(-rand_var, rand_var)

								local decal = E:create_entity(a.decal)

								decal.pos:copy(b_pos)

								decal.render.sprites[1].ts = store.tick_ts

								simulation:queue_insert_entity(decal)

								local targets = U.find_enemies_in_range_filter_off(target.pos, rand_var * 1.5, a.vis_flags, bor(F_FLYING))

								if not targets or #targets == 0 then
									goto label_515_0
								end

								for _, t in ipairs(targets) do
									do_gattling_damage(t)
								end
							end

							this.render.sprites[1].flip_x = target.pos.x < this.pos.x

							::label_515_0::

							if SU.y_hero_wait(store, this, a.shoot_every) then
								goto label_515_1
							end
						end

						a.ts = start_ts

						S:stop(a.sound)
						S:queue(a.sound_end)

						local an, af = U.animation_name_facing_point(this, a.animation_out, target.pos)

						U.animation_start_default(this, an, af, store.tick_ts, false)

						if a.xp_from_skill then
							SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
						end

						if SU.y_hero_animation_wait(this) then
						-- block empty
						else
							U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
						end
					end
				end
			elseif a == eat_instakill_attack then
				local target, _, pred_pos = U.find_foremost_enemy_between_range_filter_on(this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans, function(e, o)
					return e.health.hp < a.hp_max
				end)

				if not target or not pred_pos then
				-- block empty
				else
					local start_ts = store.tick_ts
					local an, af = U.animation_name_facing_point(this, a.animation, pred_pos)

					U.animation_start_default(this, an, af, store.tick_ts)

					if af then
						pred_pos.x = pred_pos.x + a.eat_offset_x
					else
						pred_pos.x = pred_pos.x - a.eat_offset_x
					end

					local prep_time = fts(12)

					S:queue(a.sound)

					if SU.y_hero_wait(store, this, prep_time) then
					-- block empty
					else
						local fly_time = a.shoot_time - prep_time
						local fly_start_ts = store.tick_ts
						local step_x, step_y = V.sub(pred_pos.x, pred_pos.y, this.pos.x, this.pos.y)
						local step_mag = 1 / (fly_time * FPS * 2)

						step_x, step_y = step_x * step_mag, step_y * step_mag

						while fly_time > store.tick_ts - fly_start_ts do
							this.pos.x = this.pos.x + step_x
							this.pos.y = this.pos.y + step_y

							coroutine.yield()
						end

						local d = E.assign_damage(DAMAGE_INSTAKILL, 10, this.id, target.id)

						queue_damage(store, d)

						a.ts = start_ts

						if a.xp_from_skill then
							SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
						end

						if SU.y_hero_animation_wait(this) then
						-- block empty
						else
							U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
						end
					end
				end
			end

			::label_515_1::
		end

		SU.y_soldier_ranged_attacks(store, this)
		SU.soldier_idle(store, this)
		SU.soldier_regen(store, this)
		coroutine.yield()
	end
end

local function hero_bird_ultimate_child_update(this, store)
	local sd = this.render.sprites[1]
	local ss = this.render.sprites[2]
	local a = this.melee.attacks[1]
	local fm = this.force_motion
	local target, dist
	local dest = V.v(this.pos.x, this.pos.y)

	this.start_ts = store.tick_ts
	fm.a_step = fm.a_step + math.random(-3, 3)
	this.tween.ts = U.frandom(0, 1)

	local oos = {V.v(-20, 0), V.v(20, 7)}
	local oo = oos[this.child_id]

	if this.child_id == 1 then
		this.tween.ts = store.tick_ts
	else
		this.tween.ts = store.tick_ts - 1
	end

	local start_pos = V.vclone(this.pos)

	U.animation_start(this, "in", nil, store.tick_ts, false, this.sid_bird)
	U.y_ease_keys(store, {ss}, {"alpha"}, {0}, {255}, fts(17))
	U.animation_start(this, "idle", nil, store.tick_ts, true, this.sid_bird)

	while true do
		if this.duration and store.tick_ts - this.start_ts > this.duration then
			break
		end

		::label_523_0::

		target = U.find_foremost_enemy_in_range_filter_on(this.pos, this.target_range, 0, a.vis_flags, a.vis_bans, function(e, origin)
			return V.dist2(e.pos.x, e.pos.y, start_pos.x, start_pos.y) < this.chase_range * this.chase_range
		end)

		if target and store.tick_ts - this.start_ts > 0.7 then
			::label_523_1::

			repeat
				dest.x, dest.y = target.pos.x + oo.x + target.unit.hit_offset.x, target.pos.y + oo.y
				sd.flip_x = dest.x < this.pos.x

				U.force_motion_step(this, store.tick_length, dest)
				coroutine.yield()

				dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)

				if this.duration and store.tick_ts - this.start_ts > this.duration then
					goto label_523_2
				end
			until dist < a.range or target.health.dead or band(a.vis_flags, target.vis.bans) ~= 0

			if not target or target.health.dead then
				goto label_523_0
			end

			if store.entities[target.id] and not target.health.dead and band(a.vis_flags, target.vis.bans) == 0 then
				local an, af = U.animation_name_facing_point(this, a.animation, target.pos, 1)

				U.y_animation_play(this, an, af, store.tick_ts, 1, this.sid_bird)
				U.animation_start(this, "projectile", af, store.tick_ts, true, this.sid_bird)

				local fly_attack_time = 0.15
				local dest_fh = target.unit.hit_offset.y + 20
				local old_keys1 = this.tween.props[1].keys
				local old_keys2 = this.tween.props[2].keys

				this.tween.props[1].keys = {{0, v(0, this.flight_height)}, {fly_attack_time, v(0, dest_fh)}}
				this.tween.props[1].loop = false
				this.tween.props[2].keys = {{0, v(0.75, 0.75)}, {fly_attack_time, v(1, 1)}}
				this.tween.props[2].loop = false
				this.tween.ts = store.tick_ts

				local start_pos = V.vclone(this.pos)
				local ni = target.nav_path.ni + P:predict_enemy_node_advance(target, fly_attack_time)
				local dest_atk = P:node_pos(target.nav_path.pi, target.nav_path.spi, ni)

				U.y_ease_keys(store, {this.pos, this.pos}, {"x", "y"}, {start_pos.x, start_pos.y}, {dest_atk.x, dest_atk.y}, fly_attack_time)

				if target.health.dead or band(a.vis_flags, target.vis.bans) ~= 0 then
				-- block empty
				else
					if math.random() < a.sound_chance then
						S:queue(a.sound)
					end

					do
						local d = SU.create_attack_damage(a, target.id, this)

						queue_damage(store, d)

						local fx = E:create_entity(a.hit_fx)

						fx.pos.x, fx.pos.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
						fx.render.sprites[1].ts = store.tick_ts
						fx.render.sprites[1].runs = 0

						simulation:queue_insert_entity(fx)
					end

					fly_attack_time = fts(8)

					U.animation_start(this, "attack_out", nil, store.tick_ts, true, this.sid_bird)
				end

				local start_offset_y = this.render.sprites[1].offset.y

				this.tween.props[1].keys = {{0, v(0, start_offset_y)}, {fly_attack_time, v(0, this.flight_height)}}
				this.tween.props[2].keys = {{0, v(1, 1)}, {fly_attack_time, v(0.75, 0.75)}}
				this.tween.ts = store.tick_ts
				dest_atk.x = dest_atk.x - (start_pos.x - dest_atk.x)
				start_pos.x = this.pos.x
				dest_atk.y = dest_atk.y - (start_pos.y - dest_atk.y)
				start_pos.y = this.pos.y

				U.y_ease_keys(store, {this.pos, this.pos}, {"x", "y"}, {start_pos.x, start_pos.y}, {dest_atk.x, dest_atk.y}, fly_attack_time)

				this.tween.props[1].keys = old_keys1
				this.tween.props[1].loop = true
				this.tween.props[2].keys = old_keys2
				this.tween.props[2].loop = true
				this.tween.ts = store.tick_ts

				U.animation_start(this, "idle", nil, store.tick_ts, true, this.sid_bird)

				if this.duration and store.tick_ts - this.start_ts > this.duration then
					break
				end

				U.y_wait_unconditional(store, a.cooldown)

				local dx, dy = V.sub(target.pos.x, target.pos.y, start_pos.x, start_pos.y)
				local dist2 = V.len2(dx, dy)

				if this.duration and store.tick_ts - this.start_ts > this.duration then
					break
				end

				if not target.health.dead and dist2 < this.chase_range * this.chase_range then
					goto label_523_1
				end
			end
		end

		if V.dist2(this.pos.x, this.pos.y, start_pos.x, start_pos.y) > 25 then
			local dest = start_pos

			this.render.sprites[1].flip_x = dest.x < this.pos.x

			U.force_motion_step(this, store.tick_length, dest)
		end

		coroutine.yield()
	end

	::label_523_2::

	U.y_ease_keys(store, {sd, sd.offset, ss}, {"alpha", "y", "alpha"}, {255, this.flight_height, 255}, {0, 85, 0}, 0.4)
	simulation:queue_remove_entity(this)
end

local function hero_bird_ultimate_update(this, store)
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_POWER_3)

	if #nodes < 1 then
		log.error("hero_bird_ultimate: could not find valid node")
		simulation:queue_remove_entity(this)

		return
	end

	local node = {
		spi = 1,
		pi = nodes[1][1],
		ni = nodes[1][3]
	}
	local node_pos = P:node_pos(node.pi, node.spi, node.ni)
	local child1 = E:create_entity(this.child)

	child1.pos = V.vclone(node_pos)
	child1.pos.x = child1.pos.x - 50
	child1.render.sprites[1].flip_x = false
	child1.child_id = 1

	simulation:queue_insert_entity(child1)

	local child2 = E:create_entity(this.child)

	child2.pos = V.vclone(node_pos)
	child2.pos.x = child2.pos.x + 50
	child2.render.sprites[1].flip_x = true
	child2.child_id = 2

	simulation:queue_insert_entity(child2)
	S:queue(this.sound_cast)
	simulation:queue_remove_entity(this)
end

tt = RT("ps_bullet_hero_bird_cluster_bomb")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "gryph_skillproy_trail_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(15), fts(15)}
tt.particle_system.emission_rate = 20
tt.particle_system.emit_rotation_spread = math.pi / 2
tt = RT("ps_bullet_hero_bird_cluster_bomb_part")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "gryph_skillshot_part_trail_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(14), fts(14)}
tt.particle_system.emission_rate = 20
tt.particle_system.emit_rotation_spread = math.pi / 2
tt = RT("fx_bullet_hero_bird", "fx")
tt.render.sprites[1].name = "gryph_proy_explosion_run"
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("fx_bullet_hero_bird_cluster_bomb_air", "fx")
tt.render.sprites[1].name = "gryph_skillproy_explosion_run"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.render.sprites[1].anchor = v(0.43, 0.5)
tt = RT("fx_bullet_hero_bird_cluster_bomb", "fx")
tt.render.sprites[1].name = "gryph_skillproy_part_explosion_run"
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("fx_hero_bird_gattling", "fx")
tt.render.sprites[1].name = "gryph_bulletskill_enemyhitfx_run"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = RT("fx_hero_bird_cluster_bomb_ray", "fx")
tt.render.sprites[1].name = "gryph_skillshot_run"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.render.sprites[1].scale = vv(1)
tt = RT("fx_hero_bird_ultimate", "fx")
tt.render.sprites[1].name = "gryph_child_hit_run"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = RT("decal_hero_bird_tomb", "decal_scripted")

AC(tt, "tween")

tt.render.sprites[1].prefix = "gryph_deaththing"
tt.render.sprites[1].name = "death"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = decal_hero_bird_tomb_update
tt.tween.props[1].keys = {{0, 255}, {fts(10), 0}}
tt.tween.disabled = true
tt = RT("decal_bullet_hero_bird", "decal_tween")
tt.render.sprites[1].name = "gryph_proy_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.5, 0.45)
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {0.5, 255}, {1.25, 0}}
tt = RT("decal_hero_bird_shout_stun", "decal_timed")
tt.render.sprites[1].name = "gryph_stunskill_decal_run"
tt.render.sprites[1].z = Z_DECALS
tt.timed.duration = fts(23)
tt = RT("decal_hero_bird_gattling", "decal_timed")
tt.render.sprites[1].name = "gryph_bulletskill_decal_run"
tt.render.sprites[1].scale = vv(0.7)
tt.timed.duration = fts(27)
tt = RT("hero_bird", "hero")

AC(tt, "ranged", "timed_attacks", "tween")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {364, 390, 416, 442, 468, 494, 520, 546, 572, 598}
tt.hero.level_stats.melee_damage_max = {1, 2, 4, 4, 5, 6, 7, 8, 9, 10}
tt.hero.level_stats.melee_damage_min = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
tt.hero.level_stats.ranged_damage_min = {12, 14, 15, 17, 18, 20, 21, 23, 24, 26}
tt.hero.level_stats.ranged_damage_max = {18, 20, 23, 25, 27, 29, 32, 34, 37, 38}
tt.hero.skills.cluster_bomb = CC("hero_skill")
tt.hero.skills.cluster_bomb.cooldown = {20, 20, 20}
tt.hero.skills.cluster_bomb.explosion_damage_min = {16, 24, 36}
tt.hero.skills.cluster_bomb.explosion_damage_max = {16, 24, 36}
tt.hero.skills.cluster_bomb.fire_duration = {3, 6, 9}
tt.hero.skills.cluster_bomb.burn_damage_min = {1, 1, 1}
tt.hero.skills.cluster_bomb.burn_damage_max = {1, 1, 1}
tt.hero.skills.cluster_bomb.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.shout_stun = CC("hero_skill")
tt.hero.skills.shout_stun.cooldown = {20, 18, 16}
tt.hero.skills.shout_stun.stun_duration = {1, 1.5, 2}
tt.hero.skills.shout_stun.slow_duration = {3, 4, 6}
tt.hero.skills.shout_stun.xp_gain = {160, 288, 384}
tt.hero.skills.shout_stun.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.gattling = CC("hero_skill")
tt.hero.skills.gattling.cooldown = {12, 12, 12}
tt.hero.skills.gattling.duration = {3, 3, 3}
tt.hero.skills.gattling.damage_min = {1, 3, 4}
tt.hero.skills.gattling.damage_max = {3, 5, 6}
tt.hero.skills.gattling.xp_gain = {96, 192, 288}
tt.hero.skills.gattling.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.eat_instakill = CC("hero_skill")
tt.hero.skills.eat_instakill.cooldown = {25, 22, 20}
tt.hero.skills.eat_instakill.hp_max = {520, 1040, 1560}
tt.hero.skills.eat_instakill.xp_gain = {200, 352, 480}
tt.hero.skills.eat_instakill.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_bird_ultimate"
tt.hero.skills.ultimate.damage_min = {16, 25, 36, 50}
tt.hero.skills.ultimate.damage_max = {16, 25, 36, 50}
tt.hero.skills.ultimate.duration = {8, 10, 12, 15}
tt.hero.skills.ultimate.cooldown = {28, 28, 28, 28}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.flight_height = 80
tt.unit.flight_height = 80
tt.health.dead_lifetime = 15
tt.health_bar.draw_order = -1
tt.health_bar.offset = v(0, 120)
tt.health_bar.sort_y_offset = -171
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.health_bar.z = Z_FLYING_HEROES
tt.hero.fn_level_up = hero_bird_level_up
tt.idle_flip.cooldown = 10
tt.info.hero_portrait = "kr5_hero_portraits_0008"
tt.info.portrait = "kr5_info_portraits_heroes_0008"
tt.main_script.update = hero_bird_update
tt.motion.max_speed = 120
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.all_except_flying_nowalk = bor(TERRAIN_NONE, TERRAIN_LAND, TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_SHALLOW, TERRAIN_FAERIE, TERRAIN_ICE)
tt.nav_grid.valid_terrains = tt.all_except_flying_nowalk
tt.nav_grid.valid_terrains_dest = tt.all_except_flying_nowalk
tt.drag_line_origin_offset = v(0, tt.flight_height)
tt.regen.cooldown = 1
tt.render.sprites[1].offset.y = tt.flight_height
tt.render.sprites[1].prefix = "gryph_character"
tt.render.sprites[1].name = "respawn"
tt.render.sprites[1].angles.walk = {"fly"}
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[1].angles.gattling_in = {"shootskillback", "shootskill"}
tt.render.sprites[1].angles.gattling_loop = {"shootskillloopback", "shootskillloop"}
tt.render.sprites[1].angles.gattling_out = {"shootskillendback", "shootskillend"}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.sound_events.change_rally_point = "HeroBirdTaunt"
tt.sound_events.death = "HeroBirdDeath"
tt.sound_events.respawn = "HeroBirdTauntIntro"
tt.sound_events.hero_room_select = "HeroBirdTauntSelect"
tt.ui.click_rect = r(-37, tt.flight_height - 35, 75, 75)
tt.unit.hit_offset = v(0, tt.flight_height + 10)
tt.unit.mod_offset = v(0, tt.flight_height + 10)
tt.unit.hide_after_death = true
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_POISON)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.hero.tombstone_show_time = fts(30)
tt.hero.tombstone_decal = "decal_hero_bird_tomb"
tt.hero.tombstone_concurrent_with_death = true
tt.hero.tombstone_force_over_path = true
tt.hero.respawn_animation = "levelup"
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "bullet_hero_bird"
tt.ranged.attacks[1].bullet_start_offset = {v(20, tt.flight_height + 40), v(-20, tt.flight_height + 40)}
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].max_range = 200
tt.ranged.attacks[1].shoot_time = fts(9)
-- tt.ranged.attacks[1].sync_animation = true
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].node_prediction = fts(40)
tt.ranged.attacks[1].ignore_hit_offset = true
tt.ranged.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.ranged.attacks[1].basic_attack = true
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].animation = "skillthrowclusterbomb"
tt.timed_attacks.list[1].shoot_time = fts(18)
tt.timed_attacks.list[1].explosion_time = fts(21)
tt.timed_attacks.list[1].min_targets = 2
tt.timed_attacks.list[1].min_range = 100
tt.timed_attacks.list[1].max_range = 220
tt.timed_attacks.list[1].node_prediction = tt.timed_attacks.list[1].shoot_time + tt.timed_attacks.list[1].explosion_time + fts(25)
tt.timed_attacks.list[1].sync_animation = true
tt.timed_attacks.list[1].xp_from_skill = "cluster_bomb"
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_ENEMY)
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.timed_attacks.list[1].bullet = "bullet_hero_bird_cluster_bomb"
tt.timed_attacks.list[1].bullet_start_offset = {v(15, tt.flight_height + 15), v(-15, tt.flight_height + 15)}
tt.timed_attacks.list[1].first_explosion_height = 150
tt.timed_attacks.list[1].ray = "fx_hero_bird_cluster_bomb_ray"
tt.timed_attacks.list[1].ray_start_offset = {v(20, tt.flight_height + 40), v(-20, tt.flight_height + 40)}
tt.timed_attacks.list[1].ray_width = 300
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].mods = {"mod_hero_bird_shout_stun", "mod_hero_bird_shout_slow"}
tt.timed_attacks.list[2].decal = "decal_hero_bird_shout_stun"
tt.timed_attacks.list[2].sync_animation = true
tt.timed_attacks.list[2].animation = "stun"
tt.timed_attacks.list[2].shoot_time = fts(15)
tt.timed_attacks.list[2].node_prediction = tt.timed_attacks.list[2].shoot_time
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED, F_MOD)
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING, F_CLIFF)
tt.timed_attacks.list[2].xp_from_skill = "shout_stun"
tt.timed_attacks.list[2].radius = 100
tt.timed_attacks.list[2].min_targets = 2
tt.timed_attacks.list[2].sound = "HeroBirdTerrorShriekCast"
tt.timed_attacks.list[3] = CC("bullet_attack")
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].shoot_time = fts(18)
tt.timed_attacks.list[3].shoot_every = fts(4)
tt.timed_attacks.list[3].sync_animation = true
tt.timed_attacks.list[3].decal = "decal_hero_bird_gattling"
tt.timed_attacks.list[3].hit_fx = "fx_hero_bird_gattling"
tt.timed_attacks.list[3].animation_in = "gattling_in"
tt.timed_attacks.list[3].animation_loop = "gattling_loop"
tt.timed_attacks.list[3].animation_out = "gattling_out"
tt.timed_attacks.list[3].min_range = 80
tt.timed_attacks.list[3].max_range = 180
tt.timed_attacks.list[3].damage_type = DAMAGE_SHOT
tt.timed_attacks.list[3].xp_from_skill = "gattling"
tt.timed_attacks.list[3].sound = "HeroBirdBulletRainCast"
tt.timed_attacks.list[3].sound_end = "HeroBirdBulletRainEnd"
tt.timed_attacks.list[4] = CC("melee_attack")
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].animation = "instakill"
tt.timed_attacks.list[4].sync_animation = true
tt.timed_attacks.list[4].shoot_time = fts(19)
tt.timed_attacks.list[4].min_range = 0
tt.timed_attacks.list[4].max_range = 50
tt.timed_attacks.list[4].vis_flags = bor(F_INSTAKILL)
tt.timed_attacks.list[4].vis_bans = bor(F_FLYING, F_BOSS, F_MINIBOSS, F_CLIFF)
tt.timed_attacks.list[4].xp_from_skill = "eat_instakill"
tt.timed_attacks.list[4].node_prediction = tt.timed_attacks.list[4].shoot_time
tt.timed_attacks.list[4].eat_offset_x = 15
tt.timed_attacks.list[4].sound = "HeroBirdHuntingDiveCast"
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, vv(0.97)}, {fts(8), vv(1.03)}, {fts(16), vv(0.97)}}
tt.tween.props[2].name = "scale"
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].loop = true
tt.ultimate = {
	ts = 0,
	cooldown = 28
}
tt = RT("hero_bird_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.main_script.update = hero_bird_ultimate_update
tt.child = "hero_bird_ultimate_child"
tt.sound_cast = "HeroBirdBirdsOfPreyCast"
tt = RT("hero_bird_ultimate_child", "decal_scripted")

AC(tt, "force_motion", "melee", "tween")

tt.main_script.update = hero_bird_ultimate_child_update
tt.flight_height = 80
tt.force_motion.max_a = 1200
tt.force_motion.max_v = 180
tt.force_motion.ramp_radius = 30
tt.force_motion.fr = 0.05
tt.force_motion.a_step = 20
tt.render.sprites[1].prefix = "gryph_child"
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[1].offset.y = tt.flight_height
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "gryph_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.render.sprites[2].scale = vv(0.75)
tt.melee.attacks[1] = CC("bullet_attack")
tt.melee.attacks[1].animation = "attack_in"
tt.melee.attacks[1].cooldown = 0.1
tt.melee.attacks[1].range = 15
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].hit_time = fts(6)
tt.melee.attacks[1].hit_fx = "fx_hero_bird_ultimate"
tt.melee.attacks[1].search_cooldown = 0.1
tt.melee.attacks[1].sound = "HeroBirdBirdsOfPreyGryphonAttack"
tt.melee.attacks[1].sound_chance = 1
tt.tween.disabled = false
tt.tween.remove = false
tt.tween.props[1].name = "offset"

local fh = tt.flight_height

tt.tween.props[1].keys = {{0, v(0, fh - 5)}, {fts(10), v(0, fh + 5)}, {fts(20), v(0, fh - 5)}}
tt.tween.props[1].loop = true
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, vv(0.78)}, {fts(10), vv(0.72)}, {fts(20), vv(0.78)}}
tt.tween.props[2].name = "scale"
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].loop = true
tt.target_range = 180
tt.chase_range = 250
tt.sid_bird = 1
tt.sid_shadow = 2
tt = RT("bullet_hero_bird", "bomb")
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_radius = 75
tt.bullet.flight_time = fts(30)
tt.bullet.hit_fx = "fx_bullet_hero_bird"
tt.bullet.hit_decal = "decal_bullet_hero_bird"
tt.bullet.pop_chance = 0.5
tt.bullet.align_with_trajectory = false
tt.bullet.rotation_speed = 10 * FPS * math.pi / 180
tt.bullet.xp_gain_factor = 1.7
tt.sound_events.insert = "HeroBirdBasicAttackCast"
tt.sound_events.hit_water = nil
tt.sound_events.hit = "HeroBirdBasicAttackImpact"
tt.render.sprites[1].name = "gryph_proy"
tt.render.sprites[1].hidden = false
tt = RT("bullet_hero_bird_cluster_bomb", "bomb")
tt.bullet.flight_time = fts(22)
tt.bullet.hit_fx = "fx_bullet_hero_bird_cluster_bomb_air"
tt.bullet.hit_decal = nil
tt.bullet.particles_name = "ps_bullet_hero_bird_cluster_bomb"
tt.bullet.pop_chance = 0
tt.bullet.align_with_trajectory = false
tt.bullet.rotation_speed = 0
tt.bullet.hit_payload = "controller_bullet_hero_bird_cluster_bomb_part"
tt.sound_events.insert = "HeroBirdBasicCarpetBombingCast"
tt.sound_events.hit_water = nil
tt.sound_events.hit = nil
tt.render.sprites[1].name = "gryph_skillproy_decl"
tt.render.sprites[1].animated = true
tt.render.sprites[1].hidden = false
tt = RT("controller_bullet_hero_bird_cluster_bomb_part")

AC(tt, "main_script", "pos")

tt.main_script.update = controller_bullet_hero_bird_cluster_bomb_part_update
tt.explosion_height = 150
tt.part_template = "bullet_hero_bird_cluster_bomb_part"
tt = RT("bullet_hero_bird_cluster_bomb_part", "bomb")
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.damage_radius = 75
tt.bullet.flight_time = fts(25)
tt.bullet.hit_fx = "fx_bullet_hero_bird_cluster_bomb"
tt.bullet.hit_decal = nil
tt.bullet.hit_payload = "aura_hero_bird_cluster_bomb_fire"
tt.bullet.particles_name = "ps_bullet_hero_bird_cluster_bomb_part"
tt.bullet.pop_chance = 0
tt.bullet.align_with_trajectory = false
tt.sound_events.hit_water = nil
tt.sound_events.hit = "HeroBirdBasicCarpetBombingImpact"
tt.sound_events.insert = nil
tt = RT("aura_hero_bird_cluster_bomb_fire", "aura")

AC(tt, "render", "tween")

tt.aura.mod = "mod_hero_bird_cluster_bomb_burn"
tt.aura.radius = 50
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.vis_flags = F_RANGED
tt.aura.cycle_time = 0.2
tt.aura.duration = nil
tt.render.sprites[1].name = "gryph_skillproy_fire_run"
tt.render.sprites[1].anchor = v(0.5, 0.45)
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].scale = vv(1.2)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "gryph_skillproy_fireparticles_run"
tt.render.sprites[2].scale = vv(1.3)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.main_script.remove = aura_hero_bird_cluster_bomb_fire_remove
tt.tween.props[1].keys = {{0, 0}, {fts(3), 255}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, 0}, {fts(3), 255}}
tt.tween.props[2].sprite_id = 2
tt.tween.disabled = false
tt.tween.remove = false
tt = RT("mod_hero_bird_cluster_bomb_burn", "modifier")

AC(tt, "dps", "render")

tt.modifier.duration = 3
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = 0.25
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 2
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.damage = {1, 1, 1}
tt = RT("mod_hero_bird_shout_stun", "mod_stun")
tt.modifier.duration = nil
tt = RT("mod_hero_bird_shout_slow", "mod_slow")

AC(tt, "render")

tt.slow.factor = 0.5
tt.modifier.duration = nil
tt.modifier.health_bar_offset = v(0, -5)
tt.render.sprites[1].prefix = "gryph_slow_mod"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].anchor = v(0.5, 0.75)
tt.render.sprites[1].fps = 20
