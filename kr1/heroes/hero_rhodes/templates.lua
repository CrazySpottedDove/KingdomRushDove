local bit = require("bit")
local E = require("entity_db")
local GR = require("grid_db")
local P = require("path_db")
local scripts = require("scripts")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")

require("all.constants")
require("lib.klua.table")

local band = bit.band
local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage
local fts = U.fts

local function rhodes_ray_update(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local hit_counter = 0
	local target_id = b.target_id

	local function update_sprite()
		local angle = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		s.r = angle
		s.scale.x = (V.dist(b.to.x, b.to.y, this.pos.x, this.pos.y) + (this.dist_offset or 0)) / this.image_width
	end

	local function create_fx(name)
		local fx = E:create_entity(name)
		local target = store.entities[target_id]

		if target then
			fx.pos.x, fx.pos.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
		else
			fx.pos.x, fx.pos.y = b.to.x, b.to.y
		end

		fx.render.sprites[1].ts = store.tick_ts
		simulation:queue_insert_entity(fx)
	end

	local function hit()
		hit_counter = hit_counter + 1

		local target = store.entities[target_id]

		if target and b.damage_type ~= DAMAGE_NONE then
			local d = SU.create_bullet_damage(b, target.id, this.id)

			d.track_kills = b.track_kills ~= nil
			queue_damage(store, d)
		end

		if b.mod or b.mods then
			local mods = b.mods or {b.mod}

			for _, mod_name in ipairs(mods) do
				local m = E:create_entity(mod_name)

				m.modifier.target_id = target_id
				m.modifier.source_id = this.id
				m.modifier.level = b.level
				m.modifier.damage_factor = b.damage_factor

				simulation:queue_insert_entity(m)
			end
		end

		if b.hit_payload then
			local hp = type(b.hit_payload) == "string" and E:create_entity(b.hit_payload) or b.hit_payload

			if hp.aura then
				local source = store.entities[b.source_id]

				hp.aura.level = b.level
				hp.aura.source_id = this.id
				hp.aura.damage_factor = b.damage_factor

				if source and source.unit then
					hp.aura.damage_min = hp.aura.damage_min + source.unit.damage_buff
					hp.aura.damage_max = hp.aura.damage_max + source.unit.damage_buff
					hp.aura.damage_factor = b.damage_factor
				end

				if target then
					hp.pos.x, hp.pos.y = target.pos.x, target.pos.y
				else
					hp.pos.x, hp.pos.y = b.to.x, b.to.y
				end
			else
				hp.pos.x, hp.pos.y = b.to.x, b.to.y
			end

			simulation:queue_insert_entity(hp)
		end

		if b.hit_fxs then
			for i = 1, #b.hit_fxs do
				create_fx(b.hit_fxs[i])
			end
		elseif b.hit_fx then
			create_fx(b.hit_fx)
		end

		if b.hit_decal and (not this.hit_decal_times or hit_counter % this.hit_decal_times == 0) then
			local decal = E:create_entity(b.hit_decal)

			if this.hit_decal_offset then
				decal.pos.x = b.to.x + math.random(-this.hit_decal_offset.x, this.hit_decal_offset.x)
				decal.pos.y = b.to.y + math.random(-this.hit_decal_offset.y, this.hit_decal_offset.y)
			else
				decal.pos.x, decal.pos.y = b.to.x, b.to.y
			end

			decal.render.sprites[1].ts = store.tick_ts
			decal.source_id = b.source_id

			simulation:queue_insert_entity(decal)
		end
	end

	s.scale = s.scale or V.v(1, 1)
	s.ts = store.tick_ts

	update_sprite()

	s.hidden = true

	if b.hit_time > fts(1) then
		while store.tick_ts - s.ts < b.hit_time do
			coroutine.yield()
		end
	end

	hit()

	local hit_ts = store.tick_ts

	while store.tick_ts - s.ts < this.ray_duration do
		if this.hit_over_duration and store.tick_ts - hit_ts > this.hit_cycle_time then
			hit_ts = store.tick_ts

			hit()
		end

		coroutine.yield()

		update_sprite()

		s.hidden = false
	end

	simulation:queue_remove_entity(this)
end

local function mod_rhodes_crust_update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos

	U.y_animation_wait(this, 1, 1)
	U.animation_start(this, this.anim_loop, nil, store.tick_ts, true, 1)

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or store.tick_ts - m.ts >= m.duration then
			simulation:queue_remove_entity(this)

			return
		end

		this.pos = target.pos

		coroutine.yield()
	end
end

local function aura_rhodes_skill_c_update(this, store)
	local first_hit_ts
	local last_hit_ts = store.tick_ts - this.aura.cycle_time
	local nearest_nodes = P:nearest_nodes(this.pos.x, this.pos.y, {this.pi}, {1})
	local pi, spi, ni = unpack(nearest_nodes[1])
	local starting_ni = ni
	local distSq = 0
	local is_backwards = true
	local origin = V.vclone(this.pos)
	local target_pos = P:node_pos(pi, spi, ni)
	local sound_flag = true

	if this.particles_name then
		local particle = E:create_entity(this.particles_name)

		particle.particle_system.track_id = this.id

		simulation:queue_insert_entity(particle)
	end

	local function hit_enemies()
		local targets = U.find_enemies_in_range(store, this.pos, 0, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans, function(v)
			return (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name)) and (not this.aura.filter_source or this.aura.source_id ~= v.id)
		end)

		if targets then
			local source = store.entities[this.aura.source_id]

			for _, target in ipairs(targets) do
				if target and not target.health.dead and target.enemy then
					local d = E:create_entity("damage")
					local value = math.random(this.damage_min, this.damage_max)

					if source and source.unit then
						value = (value + source.unit.damage_buff) * source.unit.damage_factor
					end

					d.damage_type = this.damage_type
					d.value = value
					d.source_id = this.id
					d.target_id = target.id

					queue_damage(store, d)

					local hit_fx = E:create_entity(this.hit_fx)

					hit_fx.pos = V.vclone(target.pos)
					hit_fx.pos.x, hit_fx.pos.y = hit_fx.pos.x + target.unit.hit_offset.x, hit_fx.pos.y + target.unit.hit_offset.y
					hit_fx.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(hit_fx)

					local new_mod = E:create_entity(this.aura.mod)

					new_mod.modifier.target_id = target.id
					new_mod.modifier.source_id = this.id

					if this.slow_factor then
						new_mod.slow.factor = this.slow_factor
					end

					simulation:queue_insert_entity(new_mod)
				end
			end
		end
	end

	local function go_step()
		if V.veq(this.pos, target_pos) then
			this.motion.arrived = true

			return false
		else
			U.set_destination(this, target_pos)

			if U.walk(this, store.tick_length) then
				return false
			else
				local an, af = U.animation_name_facing_point(this, "loop", this.motion.dest, 1, nil, true)

				U.animation_start(this, an, af, store.tick_ts, true)

				return true
			end
		end
	end

	local function run(is_backwards)
		distSq = V.dist2(target_pos.x, target_pos.y, this.pos.x, this.pos.y)

		if distSq < 25 then
			ni = ni + 3 * (is_backwards and -1 or 1)
			target_pos = P:node_pos(pi, spi, ni)
		end

		go_step()
	end

	S:queue(this.sound_loop)

	while true do
		if this.interrupt then
			last_hit_ts = 1e+99
		end

		if is_backwards and starting_ni - ni > this.max_nodes or ni <= 3 then
			is_backwards = false
		end

		if not is_backwards and starting_ni - ni < 3 then
			break
		end

		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
			if this.aura.apply_duration and first_hit_ts and store.tick_ts - first_hit_ts > this.aura.apply_duration then
				goto continue
			end

			first_hit_ts = first_hit_ts or store.tick_ts
			last_hit_ts = store.tick_ts

			hit_enemies()
		end

		run(is_backwards)

		::continue::

		coroutine.yield()
	end

	target_pos = origin

	while go_step() do
		distSq = V.dist2(target_pos.x, target_pos.y, this.pos.x, this.pos.y)

		if distSq < 25 and sound_flag then
			sound_flag = false

			S:stop(this.sound_loop)
			S:queue(this.sound_end)
		end

		coroutine.yield()
	end

	this.rhodes._waiting_for_spinner = false

	simulation:queue_remove_entity(this)
end

local function hero_rhodes_level_up(this, store)
	if this.hero.level > 1 then
		S:queue(this.sound_events.level_up)
	end

	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "skill_a", function(this, s)
		this.timed_attacks.list[1].disabled = nil
		this.timed_attacks.list[1].cooldown = s.cooldown[s.level]
	end)
	upgrade_skill(this, "skill_b", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.cooldown = s.cooldown
		a.duration = s.duration
		a.hp_heal_ptg = s.hp_heal_ptg[s.level]
		a.armor_inc = s.armor_inc[s.level]
	end)
	upgrade_skill(this, "skill_c", function(this, s)
		this.timed_attacks.list[3].disabled = nil
		this.timed_attacks.list[3].cooldown = s.cooldown
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.timed_attacks.list[4].disabled = nil
	end)
	upgrade_skill(this, "talent_1", function(this, s)
	end)
	upgrade_skill(this, "talent_2", function(this, s)
		this.unit.ignore_stun = true
	end)
	update_hp(this)
end

local function hero_rhodes_update(this, store)
	local h = this.health
	local skills = this.hero.skills
	local sa, sb, sc, su, st1, st2 = skills.skill_a, skills.skill_b, skills.skill_c, skills.ultimate, skills.talent_1, skills.talent_2
	local saa = this.timed_attacks.list[1]
	local sba = this.timed_attacks.list[2]
	local sca = this.timed_attacks.list[3]
	local ua = this.timed_attacks.list[4]
	local brk, sta, about_to_block, started_blocking_ts, talent_1_armor_mod
	local delayed_attack_ult = false
	local ult_start_cd = store.wave_group_number == 0

	this.health_bar.hidden = false

	saa.ts = store.tick_ts - saa.cooldown * (this.unit.cooldown_factor or 1)
	sba.ts = store.tick_ts - sba.cooldown * (this.unit.cooldown_factor or 1)
	sca.ts = store.tick_ts - sca.cooldown * (this.unit.cooldown_factor or 1)
	ua.ts = store.tick_ts - ua.cooldown * (this.unit.cooldown_factor or 1)

	local function trigger_immune_to_stuns()
		this.unit.ignore_stun = true

		U.bans_add(this.vis, F_STUN)
	end

	local function trigger_affected_by_stuns()
		this.unit.ignore_stun = false

		U.bans_remove(this.vis, F_STUN)
	end

	local function shoot_bullet(attack, enemy)
		local shooting_right = not this.render.sprites[1].flip_x
		local roffset = attack.ray_start_offset
		local hoffset = V.vclone(enemy.unit.hit_offset)

		if enemy.render.sprites[1].flip_x then
			hoffset.x = -hoffset.x
		end

		local b = E:create_entity(attack.bullet)

		b.pos.x = this.pos.x + roffset.x * (shooting_right and 1 or -1)
		b.pos.y = this.pos.y + roffset.y
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = V.v(enemy.pos.x + hoffset.x, enemy.pos.y + hoffset.y)
		b.bullet.target_id = enemy.id
		b.bullet.source_id = this.id
		b.bullet.damage_min = sa.damage_min[sa.level] + this.unit.damage_buff
		b.bullet.damage_max = sa.damage_max[sa.level] + this.unit.damage_buff
		b.bullet.damage_factor = this.unit.damage_factor

		simulation:queue_insert_entity(b)
	end

	local function shoot_bullet_pos(attack, target_pos)
		local shooting_right = not this.render.sprites[1].flip_x
		local roffset = attack.ray_start_offset
		local b = E:create_entity(attack.bullet)

		b.pos.x = this.pos.x + roffset.x * (shooting_right and 1 or -1)
		b.pos.y = this.pos.y + roffset.y
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = V.v(target_pos.x, target_pos.y)
		b.bullet.source_id = this.id
		b.bullet.damage_min = sa.damage_min[sa.level] + this.unit.damage_buff
		b.bullet.damage_max = sa.damage_max[sa.level] + this.unit.damage_buff
		b.bullet.damage_factor = this.unit.damage_factor

		simulation:queue_insert_entity(b)
	end

	local function get_paths_im_on(paths)
		if not paths then
			paths = {}

			for i = 1, #P.paths do
				paths[#paths + 1] = i
			end
		end

		local nearest_nodes = P:nearest_nodes(this.pos.x, this.pos.y, paths, nil, true)
		local out = {}

		for _, node in ipairs(nearest_nodes) do
			if node[4] < P:path_width(node[1]) then
				out[#out + 1] = node[1]
			end
		end

		return #out > 0 and out or nil
	end

	local function count_paths(enemies)
		local counts = {}
		local order = {}

		for _, enemy in ipairs(enemies) do
			local pi = enemy.nav_path.pi

			if counts[pi] then
				counts[pi] = counts[pi] + 1
			else
				counts[pi] = 1
				order[#order + 1] = pi
			end
		end

		return counts, order
	end

	local function find_most_populated_path(enemies, min_enemies)
		local counts, order = count_paths(enemies)
		local best, best_count

		for _, pi in ipairs(order) do
			local count = counts[pi]

			if not best_count or count > best_count then
				best, best_count = pi, count
			end
		end

		return best_count and best_count >= min_enemies and best or nil
	end

	local function find_most_populated_path_that_we_are_on(enemies, min_enemies)
		local counts = count_paths(enemies)
		local paths = get_paths_im_on()

		if not paths then
			return nil
		end

		local total = 0
		local best, best_count

		for _, pi in ipairs(paths) do
			local count = counts[pi] or 0

			total = total + count

			if count > 0 and (not best_count or count > best_count) then
				best, best_count = pi, count
			end
		end

		return total >= min_enemies and best or nil
	end

	local function is_about_to_block()
		local center = this.nav_rally and this.nav_rally.center or this.pos
		local target = U.find_nearest_enemy(store, center, 0, this.melee.range, F_BLOCK, bor(F_CLIFF), function(e)
			return (not e.enemy.max_blockers or #e.enemy.blockers == 0) and band(GR:cell_type(e.pos.x, e.pos.y), TERRAIN_NOWALK) == 0 and (not this.melee.fn_can_pick or this.melee.fn_can_pick(this, e))
		end)

		return target ~= nil
	end

	local function ult_walk(pos, dt, dest, speed, max_speed)
		local vx, vy = V.sub(dest.x, dest.y, pos.x, pos.y)
		local v_angle = V.angleTo(vx, vy)
		local v_len = V.len(vx, vy)
		local step = max_speed * dt
		local nx, ny = V.normalize(V.rotate(v_angle, 1, 0))

		if v_len <= step then
			pos.x, pos.y = dest.x, dest.y
			speed.x, speed.y = 0, 0

			return true
		end

		local sx, sy = V.mul(math.min(step, v_len), nx, ny)

		pos.x, pos.y = V.add(pos.x, pos.y, sx, sy)
		speed.x, speed.y = sx / dt, sy / dt

		return false
	end

	if st2.level > 0 then
		trigger_immune_to_stuns()
	end

	while true do
		if ult_start_cd and store.wave_group_number > 0 then
			ult_start_cd = false
			ua.ts = store.tick_ts
		end

		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if not this.unit.ignore_stun and this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					break
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "level_up", nil, store.tick_ts, 1)
			end

			if st1.level > 0 and talent_1_armor_mod == nil and this.health.hp > this.health.hp_max * st1.hp_threshold then
				talent_1_armor_mod = E:create_entity(st1.mod)
				talent_1_armor_mod.modifier.source_id = this.id
				talent_1_armor_mod.modifier.target_id = this.id

				simulation:queue_insert_entity(talent_1_armor_mod)
			end

			if talent_1_armor_mod ~= nil and this.health.hp <= this.health.hp_max * st1.hp_threshold then
				simulation:queue_remove_entity(talent_1_armor_mod)

				talent_1_armor_mod = nil
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if this.health.dead then
			-- block empty
			else
				if sta ~= A_NO_TARGET and sta ~= A_DONE then
					if started_blocking_ts == nil then
						started_blocking_ts = store.tick_ts
					end
				else
					started_blocking_ts = nil
				end

				if not brk and sta ~= A_IN_COOLDOWN and sta ~= A_DONE then
					about_to_block = is_about_to_block()
				else
					about_to_block = false
				end

				if delayed_attack_ult and store.tick_ts - sca.ts > sca.cooldown then
					delayed_attack_ult = false
				end

				local ult_ready = ready_to_use_skill(ua, store, this.unit.cooldown_factor)

				if not ua.disabled and (ult_ready and this.motion.arrived and this.soldier.target_id == nil or (ult_ready or delayed_attack_ult) and about_to_block) then
					local a = ua
					local det_range = about_to_block and a.range_pre_block or a.range
					local target, targets = U.find_foremost_enemy(store, this.pos, 0, det_range, a.prediction_time, a.vis_flags, a.vis_bans)

					if not target or #targets == 0 then
						delayed_attack_ult = true

						SU.delay_attack(store, a, fts(10))

						goto continue
					end

					local ray_t = E:get_template(a.bullet)
					local _, ray_targets = U.find_foremost_enemy(store, target.pos, 0, ray_t.ray_duration * a.move_speed, fts(31), a.vis_flags, a.vis_bans)

					if not ray_targets or #ray_targets == 0 then
						delayed_attack_ult = true

						SU.delay_attack(store, a, fts(10))

						goto continue
					end

					local path = find_most_populated_path(ray_targets, a.min_targets)

					if not path then
						delayed_attack_ult = true

						SU.delay_attack(store, a, fts(10))

						goto continue
					end

					delayed_attack_ult = false

					S:queue(ua.sound_cast)
					S:queue(a.sound_taunt)
					U.animation_start(this, a.animation_start, nil, store.tick_ts, false, 1)

					while not U.animation_finished(this, 1) do
						if SU.soldier_interrupted(this) then
							S:stop(ua.sound_cast)

							goto continue
						end

						coroutine.yield()
					end

					local first_enemy_on_path

					for _, enemy in ipairs(targets) do
						if enemy.nav_path.pi == path then
							first_enemy_on_path = enemy

							break
						end
					end

					local first_nodes = first_enemy_on_path and P:nearest_nodes(first_enemy_on_path.pos.x, first_enemy_on_path.pos.y, {path}, nil, true) or nil

					if not first_nodes or #first_nodes == 0 then
						S:stop(ua.sound_cast)

						delayed_attack_ult = true

						SU.delay_attack(store, a, fts(10))
						U.animation_start(this, a.animation_end, nil, store.tick_ts, false, 1)
						SU.y_hero_animation_wait(this)

						goto continue
					end

					U.animation_start(this, a.animation_loop, nil, store.tick_ts, true, 1)

					local first_ni = first_nodes[1][3]
					local direction = -1
					local dest_ni = first_ni + 3 * direction
					local start = P:node_pos(path, 1, first_ni)
					local dest = P:node_pos(path, 1, dest_ni)
					local ray = E:create_entity(a.bullet)

					ray.bullet.from = V.v(this.pos.x + a.ray_start_offset.x * (this.render.sprites[1].flip_x and 1 or -1), this.pos.y + a.ray_start_offset.y)
					ray.bullet.to = V.vclone(start)
					ray.pos.x, ray.pos.y = ray.bullet.from.x, ray.bullet.from.y
					ray.bullet.source_id = this.id
					ray.bullet.damage_factor = this.unit.damage_factor
					ray.render.sprites[1].sort_y_offset = ray.bullet.to.y - ray.pos.y

					simulation:queue_insert_entity(ray)
					S:queue(ua.sound_ray_cast)

					local particles = E:create_entity(a.particles_name)

					simulation:queue_insert_entity(particles)

					local hit_decal = E:create_entity(a.hit_decal)

					hit_decal.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(hit_decal)

					local ray_begin_ts = store.tick_ts
					local aux_speed = {
						x = 0,
						y = 0
					}

					while store.tick_ts - ray_begin_ts < ray.ray_duration - ray.anim_end_duration do
						particles.pos.x, particles.pos.y = ray.bullet.to.x + a.hit_offset.x, ray.bullet.to.y + a.hit_offset.y
						hit_decal.pos.x, hit_decal.pos.y = ray.bullet.to.x, ray.bullet.to.y

						if ult_walk(ray.bullet.to, store.tick_length, dest, aux_speed, a.move_speed) then
							dest_ni = dest_ni + 3 * direction
							dest = P:node_pos(path, 1, dest_ni)
						end

						coroutine.yield()

						ray.render.sprites[1].sort_y_offset = ray.bullet.to.y - ray.pos.y
					end

					simulation:queue_remove_entity(particles)
					simulation:queue_remove_entity(hit_decal)
					U.animation_start(ray, ray.anim_end, nil, store.tick_ts, false, 1)
					SU.hero_gain_xp_from_skill(this, su)

					ua.ts = store.tick_ts
					this.nav_rally.new = nil

					U.animation_start(this, a.animation_end, nil, store.tick_ts, false, 1)

					while not U.animation_finished(this, 1) do
						if SU.soldier_interrupted(this) then
							goto continue
						end

						coroutine.yield()
					end

					goto continue
				end

				if not sca.disabled and ready_to_use_skill(sca, store, this.unit.cooldown_factor) and this.motion.arrived then
					local a = sca
					local sc_aura = E:get_template(a.aura)
					local real_prediction = a.prediction_time + sc_aura.max_nodes * P.average_node_dist / sc_aura.motion.max_speed
					local target, targets = U.find_foremost_enemy(store, this.pos, 0, a.max_range, real_prediction, a.vis_flags, a.vis_bans, function(v)
						return v.nav_path
					end)
					local path = targets and find_most_populated_path_that_we_are_on(targets, a.min_targets) or nil

					if not path then
						SU.delay_attack(store, a, fts(10))
					else
						U.animation_start(this, a.animation_start, nil, store.tick_ts, false, 1)
						S:queue(a.sound_start)

						while not U.animation_finished(this, 1) do
							if SU.soldier_interrupted(this) then
								goto continue
							end

							coroutine.yield()
						end

						path = find_most_populated_path_that_we_are_on(targets, a.min_targets)

						if not path then
							local nearest = P:nearest_nodes(this.pos.x, this.pos.y, get_paths_im_on(), {1}, true)

							path = nearest[1] and nearest[1][1] or nil
						end

						if not path then
							SU.delay_attack(store, a, fts(10))
							U.animation_start(this, a.animation_end, nil, store.tick_ts, false, 1)
							S:queue(a.sound_end)
							SU.y_hero_animation_wait(this)
						else
							if st2.level == 0 then
								trigger_immune_to_stuns()
							end

							local top = E:create_entity(a.aura)

							top.pos.x, top.pos.y = this.pos.x, this.pos.y
							top.pi = path
							top.rhodes = this
							top.damage_min = sc.damage_min[sc.level]
							top.damage_max = sc.damage_max[sc.level]
							top.slow_factor = sc.slow_factor[sc.level]

							simulation:queue_insert_entity(top)
							U.animation_start(this, a.animation_loop, nil, store.tick_ts, true, 1)

							this._waiting_for_spinner = true

							while this._waiting_for_spinner and not top.pending_removal do
								coroutine.yield()
							end

							if st2.level == 0 then
								trigger_affected_by_stuns()
							end

							SU.hero_gain_xp_from_skill(this, sc)

							sca.ts = store.tick_ts
							this.nav_rally.new = nil

							U.animation_start(this, a.animation_end, nil, store.tick_ts, false, 1)
							S:queue(a.sound_end)

							while not U.animation_finished(this, 1) do
								if SU.soldier_interrupted(this) then
									goto continue
								end

								coroutine.yield()
							end

							goto continue
						end
					end
				end

				if not saa.disabled and ready_to_use_skill(saa, store, this.unit.cooldown_factor) and this.motion.arrived then
					local a = saa
					local trigger_target, targets = U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans)

					if not targets or #targets == 0 then
						SU.delay_attack(store, a, fts(10))
					else
						local target_pos = V.vclone(trigger_target.pos)

						this.render.sprites[1].flip_x = P:predict_enemy_pos(trigger_target, a.cast_time).x < this.pos.x

						U.animation_start(this, a.animation, nil, store.tick_ts, nil, 1)
						S:queue(saa.sound)

						if not SU.y_hero_wait(store, this, a.cast_time) then
							local shooting_right = not this.render.sprites[1].flip_x
							local ray_start_fx_1 = E:create_entity(saa.ray_fx_1)

							ray_start_fx_1.pos.x, ray_start_fx_1.pos.y = this.pos.x + saa.ray_start_offset.x * (shooting_right and 1 or -1), this.pos.y + saa.ray_start_offset.y
							ray_start_fx_1.render.sprites[1].ts = store.tick_ts

							simulation:queue_insert_entity(ray_start_fx_1)

							local target = U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans)

							if not trigger_target or trigger_target.health.dead then
								if not target then
									shoot_bullet_pos(saa, target_pos)
								else
									shoot_bullet(a, target)
								end
							else
								shoot_bullet(a, trigger_target)
							end

							SU.hero_gain_xp_from_skill(this, sa)

							saa.ts = store.tick_ts
							this.nav_rally.new = nil

							while not U.animation_finished(this, 1) do
								if SU.soldier_interrupted(this) then
									goto continue
								end

								coroutine.yield()
							end

							goto continue
						end
					end
				end

				if not sba.disabled and ready_to_use_skill(sba, store, this.unit.cooldown_factor) and this.motion.arrived and this.soldier.target_id ~= nil and (this.health.hp <= this.health.hp_max * (1 - sba.trigger_hp_ptg) or started_blocking_ts and store.tick_ts - started_blocking_ts > sba.time_blocking_to_trigger) then
					local blocker = store.entities[this.soldier.target_id]
					local a = sba

					U.animation_start(this, a.animation, nil, store.tick_ts, false)
					S:queue(sba.sound, {
						delay = fts(14)
					})

					if not SU.y_hero_wait(store, this, a.cast_time) then
						if not blocker then
							this.soldier.target_id = nil
						else
							a.ts = store.tick_ts

							SU.hero_gain_xp_from_skill(this, sb)

							local mod_a = E:create_entity(a.mod_armor)

							mod_a.modifier.source_id = this.id
							mod_a.modifier.target_id = this.id
							mod_a.armor_buff.max_factor = a.armor_inc

							simulation:queue_insert_entity(mod_a)

							local mod_h = E:create_entity(a.mod_heal)

							mod_h.modifier.source_id = this.id
							mod_h.modifier.target_id = this.id
							mod_h.hps.heal_min = this.health.hp_max * a.hp_heal_ptg
							mod_h.hps.heal_max = mod_h.hps.heal_min

							simulation:queue_insert_entity(mod_h)
							SU.y_hero_animation_wait(this)
							U.animation_start(this, "idle", nil, store.tick_ts, true)

							goto continue
						end
					end
				end

				if brk or sta ~= A_NO_TARGET then
				-- block empty
				elseif SU.soldier_go_back_step(store, this) then
				-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::continue::

		coroutine.yield()
	end
end

local tt

tt = RT("hero_rhodes", "hero")
AC(tt, "melee", "timed_attacks")
tt.hero.level_stats.armor = {0.23, 0.26, 0.29, 0.32, 0.35, 0.38, 0.41, 0.44, 0.47, 0.5}
tt.hero.level_stats.hp_max = {180, 205, 230, 255, 280, 305, 330, 355, 380, 405}
tt.hero.level_stats.melee_damage_min = {8, 10, 11, 12, 13, 14, 16, 17, 18, 19}
tt.hero.level_stats.melee_damage_max = {13, 14, 16, 18, 20, 22, 23, 25, 27, 29}
tt.hero.skills.skill_a = CC("hero_skill")
tt.hero.skills.skill_a.cooldown = {10, 9, 8}
tt.hero.skills.skill_a.damage_min = {16, 28, 40}
tt.hero.skills.skill_a.damage_max = {24, 42, 60}
tt.hero.skills.skill_a.damage_type = DAMAGE_TRUE
tt.hero.skills.skill_a.xp_gain = {40, 80, 120}
tt.hero.skills.skill_a.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.skill_b = CC("hero_skill")
tt.hero.skills.skill_b.cooldown = 22
tt.hero.skills.skill_b.duration = 6
tt.hero.skills.skill_b.hp_heal_ptg = {0.3, 0.4, 0.5}
tt.hero.skills.skill_b.armor_inc = {0.3, 0.4, 0.5}
tt.hero.skills.skill_b.trigger_hp_ptg = 0.7
tt.hero.skills.skill_b.time_blocking_to_trigger = 5
tt.hero.skills.skill_b.xp_gain = {88, 176, 264}
tt.hero.skills.skill_b.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.skill_c = CC("hero_skill")
tt.hero.skills.skill_c.cooldown = 16
tt.hero.skills.skill_c.damage_min = {10, 10, 12}
tt.hero.skills.skill_c.damage_max = {15, 15, 18}
tt.hero.skills.skill_c.slow_factor = {0.8, 0.7, 0.7}
tt.hero.skills.skill_c.xp_gain = {64, 128, 192}
tt.hero.skills.skill_c.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.cooldown = 35
tt.hero.skills.ultimate.xp_gain = {140}
tt.hero.skills.ultimate.xp_level_steps = {
	[5] = 1
}
tt.hero.skills.talent_1 = CC("hero_skill")
tt.hero.skills.talent_1.hp_threshold = 0.75
tt.hero.skills.talent_1.mod = "mod_rhodes_talent_1_armor"
tt.hero.skills.talent_1.xp_level_steps = {
	[1] = 1
}
tt.hero.skills.talent_2 = CC("hero_skill")
tt.hero.skills.talent_2.xp_level_steps = {
	[1] = 1
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 67)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_rhodes_level_up
tt.hero.respawn_animation = "level_up"
tt.info.hero_portrait = "kr6_hero_portraits_0007"
tt.info.portrait = "kr6_info_portraits_heroes_0007"
tt.main_script.update = hero_rhodes_update
tt.motion.max_speed = 32
tt.regen.cooldown = 1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].prefix = "hero_rhodesDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = DO_HEROES
tt.render.sprites[1].scale = vec_2(1, 1)
tt.sound_events.change_rally_point = "HeroRhodesTaunt"
tt.sound_events.death = "HeroRhodesDeath"
tt.sound_events.insert = "HeroRhodesTauntIntro"
tt.sound_events.level_up = "HeroRhodesTauntLevelUp"
tt.sound_events.respawn = "HeroRhodesTauntIntro"
tt.sound_events.hero_room_select = "HeroRhodesTauntSelect"
tt.soldier.melee_slot_offset = vec_2(20, 0)
tt.ui.click_rect = r(-30, -5, 65, 65)
tt.unit.hit_offset = vec_2(0, 25)
tt.unit.marker_offset = vec_2(0, -1)
tt.unit.mod_offset = vec_2(0, 30)
tt.unit.pop_offset = vec_2(0, 15)
tt.unit.blood_color = BLOOD_NONE
tt.vis.bans = bor(tt.vis.bans, F_BLOOD, F_POISON)
tt.melee.cooldown = 1.5
tt.melee.range = 93.6
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animation = "attack_1"
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_bans = 0
tt.melee.attacks[1].damage_flags = 0
tt.melee.attacks[1].hit_time = fts(16)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeBlunt"
tt.melee.attacks[1].sound_args = {
	delay = fts(16)
}
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 2
tt.melee.attacks[1].hit_fx = "fx_rhodes_hit"
tt.melee.attacks[1].hit_offset = vec_2(45, 10)
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack_2"
tt.melee.attacks[2].chance = 0.5
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "sunbeam"
tt.timed_attacks.list[1].bullet = "bullet_rhodes_skill_a"
tt.timed_attacks.list[1].cast_time = fts(14)
tt.timed_attacks.list[1].cooldown = 10
tt.timed_attacks.list[1].damage_min = 16
tt.timed_attacks.list[1].damage_max = 24
tt.timed_attacks.list[1].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].max_range = 200
tt.timed_attacks.list[1].min_range = 50
tt.timed_attacks.list[1].node_prediction = fts(14)
tt.timed_attacks.list[1].ray_fx_1 = "fx_rhodes_skill_a_start"
tt.timed_attacks.list[1].ray_start_offset = vec_2(23, 28)
tt.timed_attacks.list[1].sound = "HeroRhodesSunbeamCast"
tt.timed_attacks.list[1].vis_flags = bor(F_FLYING, F_STUN)
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animation = "strong_crust"
tt.timed_attacks.list[2].armor_inc = 0.3
tt.timed_attacks.list[2].cast_time = fts(16)
tt.timed_attacks.list[2].cooldown = 22
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].duration = 6
tt.timed_attacks.list[2].hp_heal_ptg = 0.3
tt.timed_attacks.list[2].mod_armor = "mod_rhodes_skill_b_armor"
tt.timed_attacks.list[2].mod_heal = "mod_rhodes_skill_b_heal"
tt.timed_attacks.list[2].sound = "HeroRhodesStrongCrustCast"
tt.timed_attacks.list[2].time_blocking_to_trigger = 5
tt.timed_attacks.list[2].trigger_hp_ptg = 0.7
tt.timed_attacks.list[3] = CC("custom_attack")
tt.timed_attacks.list[3].animation_start = "spinner_start"
tt.timed_attacks.list[3].animation_loop = "spinner_loop"
tt.timed_attacks.list[3].animation_end = "spinner_end"
tt.timed_attacks.list[3].aura = "aura_rhodes_skill_c"
tt.timed_attacks.list[3].cooldown = 16
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].max_range = 150
tt.timed_attacks.list[3].max_range_pre_block = 175
tt.timed_attacks.list[3].min_targets = 3
tt.timed_attacks.list[3].prediction_time = fts(25)
tt.timed_attacks.list[3].sound_start = "HeroRhodesTwistingTopStart"
tt.timed_attacks.list[3].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[3].vis_flags = bor(F_AREA)
tt.timed_attacks.list[4] = CC("custom_attack")
tt.timed_attacks.list[4].animation_start = "ultimate_start"
tt.timed_attacks.list[4].animation_loop = "ultimate_loop"
tt.timed_attacks.list[4].animation_end = "ultimate_end"
tt.timed_attacks.list[4].bullet = "bullet_rhodes_ultimate_ray"
tt.timed_attacks.list[4].cooldown = 35
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].hit_decal = "decal_rhodes_ultimate_ray"
tt.timed_attacks.list[4].hit_offset = vec_2(0, -13)
tt.timed_attacks.list[4].min_targets = 3
tt.timed_attacks.list[4].move_speed = 40
tt.timed_attacks.list[4].particles_name = "ps_rhodes_ultimate_debris"
tt.timed_attacks.list[4].prediction_time = fts(31)
tt.timed_attacks.list[4].range = 225
tt.timed_attacks.list[4].range_pre_block = 250
tt.timed_attacks.list[4].ray_start_offset = vec_2(-7, 87)
tt.timed_attacks.list[4].sound_cast = "HeroRhodesSolarFlareCast"
tt.timed_attacks.list[4].sound_ray_cast = "HeroRhodesSolarFlareRayCast"
tt.timed_attacks.list[4].sound_taunt = "HeroRhodesTauntUltimate"
tt.timed_attacks.list[4].vis_bans = bor(F_FLYING)

tt = RT("bullet_rhodes_skill_a", "bullet")
tt.bullet.damage_max = 24
tt.bullet.damage_min = 16
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.flight_time = fts(6)
tt.bullet.hit_fxs = {"fx_rhodes_skill_a_hit", "fx_rhodes_skill_a_end"}
tt.bullet.hit_time = fts(1)
tt.bullet.level = 1
tt.bullet.mod = "mod_rhodes_skill_a_stun"
tt.bullet.pop = {"pop_zap_arcane"}
tt.image_width = 205
tt.main_script.update = rhodes_ray_update
tt.ray_duration = fts(22)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].prefix = "heroes_rhodes_fx_sunbeam"
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].z = Z_BULLETS

tt = RT("bullet_rhodes_ultimate_ray", "bullet")
tt.anim_end = "end"
tt.anim_end_duration = fts(10)
tt.bullet.damage_max = 0
tt.bullet.damage_min = 0
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.flight_time = fts(6)
tt.bullet.hit_decal = "decal_rhodes_ultimate_ray_ground"
tt.bullet.hit_payload = "aura_rhodes_ultimate_ray"
tt.bullet.hit_time = fts(1)
tt.bullet.level = 1
tt.hit_cycle_time = 0.25
tt.hit_decal_offset = vec_2(5, 5)
tt.hit_decal_times = 2
tt.hit_over_duration = true
tt.image_width = 205
tt.main_script.update = rhodes_ray_update
tt.ray_duration = 3
tt.render.sprites[1].loop = true
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].prefix = "heroes_rhodes_fx_ult_beam"
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.track_target = false

tt = RT("aura_rhodes_skill_c", "aura")
AC(tt, "render", "motion")
tt.aura.cycle_time = 0.25
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.duration = 1e+99
tt.aura.mod = "mod_rhodes_skill_c_slow"
tt.aura.radius = 75
tt.aura.vis_bans = bor(F_FLYING)
tt.aura.vis_flags = bor(F_AREA)
tt.damage_max = 15
tt.damage_min = 10
tt.hit_fx = "fx_rhodes_hit"
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = aura_rhodes_skill_c_update
tt.max_nodes = 18
tt.motion.max_speed = 200
tt.particles_name = "ps_rhodes_skill_c_dust"
tt.render.sprites[1].loop = true
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].prefix = "heroes_rhodes_fx_spinner"
tt.sound_end = "HeroRhodesTwistingTopLoopEnd"
tt.sound_loop = "HeroRhodesTwistingTopLoop"

tt = RT("aura_rhodes_ultimate_ray", "aura")
tt.aura.cycle_time = fts(1)
tt.aura.cycles = 1
tt.aura.damage_max = 42
tt.aura.damage_min = 30
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.duration = 1e+99
tt.aura.mod = "mod_rhodes_ult_slow"
tt.aura.radius = 55
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND, F_HERO)
tt.aura.vis_flags = bor(F_AREA)
tt.main_script.update = scripts.aura_apply_damage.update

tt = RT("mod_rhodes_skill_a_stun", "mod_stun")
tt.modifier.duration = 0.5
tt.modifier.vis_bans = bor(F_BOSS)
tt.modifier.vis_flags = bor(F_MOD, F_STUN)

tt = RT("mod_rhodes_skill_b_armor", "modifier")
AC(tt, "render", "armor_buff", "tween")
tt.anim_loop = "loop"
tt.armor_buff.cycle_time = 1e+99
tt.armor_buff.max_factor = 0.3
tt.main_script.insert = scripts.mod_armor_buff.insert
tt.main_script.remove = scripts.mod_armor_buff.remove
tt.main_script.update = mod_rhodes_crust_update
tt.modifier.duration = 6
tt.modifier.use_mod_offset = false
tt.modifier.vis_bans = 0
tt.modifier.vis_flags = bor(F_MOD)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "start"
tt.render.sprites[1].prefix = "heroes_rhodes_fx_crust_fx"
tt.tween.disabled = false
tt.tween.props[1].keys = {{0, 0}, {1, 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.tween.reverse = false
tt.tween.run_once = true

tt = RT("mod_rhodes_skill_b_heal", "modifier")
AC(tt, "hps")
tt.hps.heal_every = 1
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update
tt.modifier.duration = 0.9

tt = RT("mod_rhodes_skill_c_slow", "mod_slow")
tt.modifier.duration = 4
tt.modifier.vis_flags = bor(F_MOD)
tt.slow.factor = 0.8

tt = RT("mod_rhodes_ult_slow", "mod_slow")
tt.modifier.duration = 1
tt.modifier.vis_flags = bor(F_MOD)
tt.slow.factor = 0.5

tt = RT("mod_rhodes_talent_1_armor", "modifier")
AC(tt, "armor_buff")
tt.armor_buff.cycle_time = 1e+99
tt.armor_buff.max_factor = 0.2
tt.main_script.insert = scripts.mod_armor_buff.insert
tt.main_script.remove = scripts.mod_armor_buff.remove
tt.modifier.duration = 1e+99

tt = RT("fx_rhodes_hit", "fx")
AC(tt, "main_script")
tt.render.sprites[1].name = "run"
tt.render.sprites[1].prefix = "heroes_rhodes_fx_hit_fx"

tt = RT("fx_rhodes_skill_a_hit", "fx")
AC(tt, "main_script")
tt.render.sprites[1].name = "run"
tt.render.sprites[1].prefix = "heroes_rhodes_fx_sunbeam_hit"
tt.render.sprites[1].sort_y_offset = -1.1
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("fx_rhodes_skill_a_start", "fx")
AC(tt, "main_script")
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].prefix = "heroes_rhodes_fx_sunbeam_origin"
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("fx_rhodes_skill_a_end", "fx")
AC(tt, "main_script")
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].prefix = "heroes_rhodes_fx_sunbeam_end"
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("decal_rhodes_tombstone", "decal")
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "tomb"
tt.render.sprites[1].prefix = "hero_rhodesDef"
tt.render.sprites[1].scale = vec_2(1, 1)

tt = RT("decal_rhodes_ultimate_ray", "decal")
AC(tt, "main_script")
tt.render.sprites[1].animated = true
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].prefix = "heroes_rhodes_fx_ult_beam_end"
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].z = Z_OBJECTS + 1

tt = RT("decal_rhodes_ultimate_ray_ground", "decal_tween")
AC(tt, "main_script")
tt.main_script.remove = scripts.tween_utils.reverse_remove
tt.main_script.update = scripts.tween_utils.wait_update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "heroes_rhodes_fx_ult_decal"
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = false
tt.tween.props[1].keys = {{0, 0}, {1, 255}}
tt.tween.remove = false
tt.tween.run_once = true
tt.wait_time = 2.5

tt = RT("ps_rhodes_skill_c_dust", "particle_system")
tt.particle_system.animated = true
tt.particle_system.emit_area_spread = vec_2(3, 3)
tt.particle_system.emission_rate = 10
tt.particle_system.loop = false
tt.particle_system.name = "heroes_rhodes_fx_spinner_dust_run"
tt.particle_system.particle_lifetime = {fts(15), fts(15)}
tt.particle_system.track_rotation = true
tt.particle_system.z = Z_DECALS

tt = RT("ps_rhodes_ultimate_debris", "particle_system")
tt.particle_system.animated = true
tt.particle_system.emit_area_spread = vec_2(3, 3)
tt.particle_system.emission_rate = 6
tt.particle_system.loop = false
tt.particle_system.name = "heroes_rhodes_fx_ult_trail_loop"
tt.particle_system.particle_lifetime = {fts(11), fts(11)}
tt.particle_system.sort_y_offset = -2
tt.particle_system.z = Z_OBJECTS + 1
