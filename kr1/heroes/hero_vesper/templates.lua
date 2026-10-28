local scripts = require("scripts")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local bit = require("bit")
local HU = require("hero_utils")
local km = require("lib.klua.macros")
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local tt

local function hero_vesper_ricochet_bullet_update(this, store)
	local b = this.bullet
	local mspeed = b.min_speed
	local target, ps
	local bounce_count = 0
	local already_hit = {}

	b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	::label_241_0::

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		target = store.entities[b.target_id]

		if target and target.health and not target.health.dead then
			b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
		end

		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		coroutine.yield()
	end

	if target and not target.health.dead then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)

		if b.mod or b.mods then
			local mods = b.mods or {b.mod}

			for _, mod_name in ipairs(mods) do
				local m = E:create_entity(mod_name)

				m.modifier.source_id = this.id
				m.modifier.target_id = target.id
				m.modifier.level = b.level

				simulation:queue_insert_entity(m)
			end
		end

		table.insert(already_hit, target.id)
	end

	if b.hit_fx then
		local sfx = E:create_entity(b.hit_fx)

		sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
		sfx.render.sprites[1].ts = store.tick_ts
		sfx.render.sprites[1].runs = 0

		simulation:queue_insert_entity(sfx)
	end

	S:queue(this.sound)

	if bounce_count < this.bounces then
		local targets = U.find_enemies_in_range_filter_on(this.pos, this.bounce_range, b.vis_flags, b.vis_bans, function(v)
			return not table.contains(already_hit, v.id)
		end)

		if not targets then
			if target and not target.health.dead then
				already_hit = {target.id}
			else
				already_hit = {}
			end

			targets = U.find_enemies_in_range_filter_on(this.pos, this.bounce_range, b.vis_flags, b.vis_bans, function(v)
				return not table.contains(already_hit, v.id)
			end)
		end

		if targets then
			if bounce_count == 0 then
				this.render.sprites[1].name = this.bounce_arrow_name

				if ps then
					ps.particle_system.emit = false

					simulation:queue_remove_entity(ps)
				end

				b.particles_name = this.particle_after_bounce
				ps = E:create_entity(b.particles_name)
				ps.particle_system.track_id = this.id

				simulation:queue_insert_entity(ps)
			end

			table.sort(targets, function(e1, e2)
				return V.dist(this.pos.x, this.pos.y, e1.pos.x, e1.pos.y) < V.dist(this.pos.x, this.pos.y, e2.pos.x, e2.pos.y)
			end)

			local target = targets[1]

			bounce_count = bounce_count + 1
			b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
			b.target_id = target.id

			goto label_241_0
		end
	end

	if ps then
		ps.particle_system.emit = false

		simulation:queue_remove_entity(ps)
	end

	simulation:queue_remove_entity(this)
end

local function hero_vesper_level_up(this, store, initial)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[2].bullet)

	bt.bullet.damage_min = ls.ranged_short_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_short_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_long_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_long_damage_max[hl]

	upgrade_skill(this, "arrow_to_the_knee", function(this, s)
		local a = this.ranged.attacks[3]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local b = E:get_template(a.bullet)

		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]
		b.bullet.damage_type = DAMAGE_TRUE

		local m = E:get_template(b.bullet.mod)

		m.modifier.duration = s.stun_duration[s.level]
	end)
	upgrade_skill(this, "ricochet", function(this, s)
		local a = this.timed_attacks.list[1]
		local sl = s.level

		a.disabled = nil
		a.cooldown = s.cooldown[sl]
		a.level = sl

		local b = E:get_template(a.bullet)

		b.bullet.damage_min = s.damage_min[sl]
		b.bullet.damage_max = s.damage_max[sl]
		b.bounces = s.bounces[sl]
	end)
	upgrade_skill(this, "martial_flourish", function(this, s)
		local a = this.melee.attacks[3]
		local sl = s.level

		a.disabled = nil
		a.cooldown = s.cooldown[sl]
		a.damage_min = s.damage_min[sl]
		a.damage_max = s.damage_max[sl]
	end)
	upgrade_skill(this, "disengage", function(this, s)
		local d = this.dodge

		d.disabled = nil

		local sl = s.level

		d.cooldown = s.cooldown[sl]

		local b = E:get_template(d.bullet)

		b.bullet.damage_min = s.damage_min[sl]
		b.bullet.damage_max = s.damage_max[sl]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		local sl = s.level

		this.ultimate.disabled = nil
		this.ultimate.cooldown = s.cooldown[sl]
	end)
	update_hp(this)

	this.hero.melee_active_status = {}

	for index, attack in ipairs(this.melee.attacks) do
		this.hero.melee_active_status[index] = attack.disabled
	end
end

local function hero_vesper_insert(this, store)
	this.hero.fn_level_up(this, store)

	this.melee.order = {3, 2, 1}
	this.ranged.order = U.attack_order(this.ranged.attacks)

	return true
end

local function hero_vesper_can_dodge(store, this, ranged_attack, attack, enemy)
	local skill = this.hero.skills.disengage

	if enemy and enemy.health and not enemy.health.dead and not this.dodge.disabled then
		local enp = enemy.nav_path
		local new_ni = enp.ni
		local node_limit = math.floor(skill.min_distance_from_end / P.average_node_dist)
		local node_jump = math.floor(skill.distance / P.average_node_dist)
		local nodes_to_goal = P:nodes_to_goal(enp.pi, enp.spi, enp.ni)

		if node_limit < nodes_to_goal then
			new_ni = new_ni + math.min(nodes_to_goal - 1, node_jump)

			local new_pos = P:node_pos(enp.pi, enp.spi, new_ni)

			this.dodge.new_pos = new_pos

			return true
		end
	end

	return false
end

local function hero_vesper_update(this, store)
	local h = this.health
	local brk, sta
	local basic_attack = this.ranged.attacks[1]
	local ricochet_attack = this.timed_attacks.list[1]

	local function shoot_arrow_after_dodge(enemy, enemy_pos, enemy_id)
		local pos, bullet_to, target_id

		if enemy then
			pos = enemy.pos
			bullet_to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
			target_id = enemy.id
		else
			pos = enemy_pos
			bullet_to = enemy_pos
			target_id = enemy_id
		end

		local an, af, ai = U.animation_name_facing_point(this, this.dodge.animation_attack_start, pos)

		U.animation_start_default(this, an, af, store.tick_ts, false)
		U.y_wait_unconditional(store, this.dodge.shoot_time)

		local bo = this.dodge.bullet_start_offset[ai]
		local b = E:create_entity(this.dodge.bullet)

		b.pos:copy(this.pos)

		b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * bo.x, b.pos.y + bo.y

		b.bullet.from:copy(b.pos)

		b.bullet.to = bullet_to
		b.bullet.target_id = target_id

		simulation:queue_insert_entity(b)
		U.y_animation_wait_default(this)

		local an, af = U.animation_name_facing_point(this, this.dodge.animation_attack_end, pos)

		U.animation_start_default(this, an, af, store.tick_ts, false)
		U.y_animation_wait_default(this)
	end

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_239_0
				end
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local enemy = find_target_at_critical_moment(this, this.ranged.attacks[1].max_range, F_RANGED, F_NONE, nil, true)

				if enemy and enemy.pos then
					U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
					S:queue(this.sound_events.change_rally_point)

					local ultimate_entity = E:create_entity(this.hero.skills.ultimate.controller_name)

					ultimate_entity.damage_factor = this.unit.damage_factor
					ultimate_entity.pos = V.vclone(enemy.pos)
					ultimate_entity.level = this.hero.skills.ultimate.level

					simulation:queue_insert_entity(ultimate_entity)

					this.ultimate.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			if not ricochet_attack.disabled and store.tick_ts - ricochet_attack.ts > ricochet_attack.cooldown then
				local enemy, enemies = U.find_foremost_enemy_between_range_filter_off(this.pos, ricochet_attack.min_range, ricochet_attack.max_range_trigger, ricochet_attack.node_prediction, ricochet_attack.vis_flags, ricochet_attack.vis_bans)

				if not enemy then
					ricochet_attack.ts = ricochet_attack.ts + fts(10)
				elseif enemies and #enemies < ricochet_attack.min_targets then
					ricochet_attack.ts = ricochet_attack.ts + fts(10)
				else
					local start_ts = store.tick_ts

					if SU.y_soldier_do_ranged_attack(store, this, enemy, ricochet_attack, V.vclone(enemy.pos)) then
						ricochet_attack.ts = start_ts
					end
				end
			end

			if not this.dodge.disabled and this.dodge.active and this.vis.bans ~= F_ALL then
				local enemy = store.entities[this.soldier.target_id]

				if not enemy then
				-- block empty
				else
					local enemy_pos = enemy.pos
					local enemy_id = enemy.id

					this.dodge.active = false
					this.dodge.ts = store.tick_ts

					local new_pos = this.dodge.new_pos

					S:queue(this.dodge.sound)
					U.unblock_target(store, this)

					local bans = this.vis.bans

					U.bans_add(this.vis, F_ALL)
					SU.hide_modifiers(store, this, true)
					SU.hide_auras(store, this, true)
					U.animation_start_default(this, this.dodge.animation_dissapear, nil, store.tick_ts, false)
					U.y_animation_wait_default(this)
					U.y_wait_unconditional(store, fts(1))

					this.pos.x, this.pos.y = new_pos.x, new_pos.y
					this.nav_rally.center = V.vclone(this.pos)
					this.nav_rally.pos = V.vclone(this.pos)

					SU.hero_gain_xp_from_skill(this, this.hero.skills.disengage)
					U.y_animation_play(this, this.dodge.animation_appear, nil, store.tick_ts)
					U.bans_remove(this.vis, F_ALL)
					SU.show_modifiers(store, this, true)
					SU.show_auras(store, this, true)

					ricochet_attack.ts = -ricochet_attack.cooldown
					this.ranged.attacks[3].ts = -this.ranged.attacks[3].cooldown

					local targets = U.find_enemies_in_range_filter_off(enemy_pos, 100, this.vis.flags, bans)

					if not targets then
						targets = U.find_enemies_in_range_filter_off(this.pos, this.ranged.attacks[1].max_range, this.vis.flags, bans)
					end

					if targets then
						for i = 1, this.dodge.total_shoots do
							local target = targets[1 + i % #targets]

							shoot_arrow_after_dodge(target, target.pos, target.id)
						end
					else
						for i = 1, this.dodge.total_shoots do
							shoot_arrow_after_dodge(enemy, enemy_pos, enemy_id)
						end
					end

					U.animation_start_default(this, this.dodge.animation_attack_end, nil, store.tick_ts, false)

					basic_attack.ts = store.tick_ts

					U.animation_start_default(this, "idle", nil, store.tick_ts, true)
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			elseif SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
				-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_239_0::

		coroutine.yield()
	end
end

local function hero_vesper_ultimate_decal_insert(this, store)
	this.render.sprites[1].ts = store.tick_ts
	this.render.sprites[1].r = U.frandom(-10, 5) * math.pi / 180

	return true
end

local function hero_vesper_ultimate_arrow_update(this, store)
	local b = this.bullet
	local speed = b.max_speed

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) >= 2 * (speed * store.tick_length) do
		b.speed.x, b.speed.y = V.mul(speed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		coroutine.yield()
	end

	local targets = U.find_targets_in_range(store.entities, b.to, 0, b.damage_radius, b.damage_flags, b.damage_bans)

	if targets then
		for _, target in ipairs(targets) do
			local d = E.assign_damage(b.damage_type, b.damage_max, this.id, target.id)

			queue_damage(store, d)

			if b.mod then
				local mod = E:create_entity(b.mod)

				mod.modifier.target_id = target.id

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

		simulation:queue_insert_entity(decal)
	end

	simulation:queue_remove_entity(this)
end

local function hero_vesper_ultimate_update(this, store)
	local distance = 2

	local function spawn_arrow(pi, spi, ni)
		spi = spi or math.random(1, 3)

		local pos = P:node_pos(pi, spi, ni)

		pos.x = pos.x + math.random(-4, 4)
		pos.y = pos.y + math.random(-5, 5)

		local b = E:create_entity(this.bullet)

		b.bullet.damage_max = this.damage[this.level]
		b.bullet.damage_min = this.damage[this.level]
		b.bullet.damage_type = DAMAGE_TRUE
		b.bullet.from = V.v(pos.x + math.random(-170, -140), pos.y + REF_H)
		b.bullet.to = pos

		b.pos:copy(b.bullet.from)
		simulation:queue_insert_entity(b)
	end

	local function is_valid_path(pi)
		return (not store.level.ignore_walk_backwards_paths or not table.contains(store.level.ignore_walk_backwards_paths, pi)) and P:is_path_active(pi)
	end

	local available_paths = {}

	for k, v in pairs(P.paths) do
		table.insert(available_paths, k)
	end

	if store.level.ignore_walk_backwards_paths then
		available_paths = table.filter(available_paths, is_valid_path)
	end

	local nearest = P:nearest_nodes(this.pos.x, this.pos.y, available_paths, nil, true)

	if #nearest > 0 then
		local pi, _, ni = unpack(nearest[1])
		local count = this.spread[this.level]
		local enemies = U.find_enemies_in_range_filter_off(this.pos, this.enemies_range, this.vis_flags, this.vis_bans)

		if enemies and #enemies > 0 and is_valid_path(enemies[1].nav_path.pi) then
			local enemy_pi = enemies[1].nav_path.pi

			nearest = P:nearest_nodes(this.pos.x, this.pos.y, {enemy_pi})

			if #nearest > 0 then
				pi, _, ni = unpack(nearest[1])
			end
		end

		ni = ni + this.node_prediction_offset + distance

		S:queue(this.sounds[this.level])

		for i = 1, count do
			if P:is_node_valid(pi, ni - i * distance) then
				spawn_arrow(pi, 1, ni - i * distance)
				spawn_arrow(pi, math.random(2, 3), ni - i * distance)
				U.y_wait_unconditional(store, this.duration / count)
			end
		end
	end

	simulation:queue_remove_entity(this)
end

tt = E:register_t("ps_hero_vesper_arrow_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "hero_vesper_attack_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.animation_fps = 15
tt.particle_system.emission_rate = 100
tt.particle_system.track_rotation = true
tt = E:register_t("ps_hero_vesper_arrow_to_the_knee_bullet_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "hero_vesper_arrow_to_the_knee_particles"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 300
tt.particle_system.animation_fps = 15
tt.particle_system.track_rotation = true
tt.particle_system.scales_y = {1.5, 0.7}
tt.particle_system.scales_x = {1.5, 0.7}
tt = E:register_t("ps_hero_vesper_ricochet_bullet_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "hero_vesper_ricochet_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.animation_fps = 35
tt.particle_system.emission_rate = 180
tt.particle_system.track_rotation = true
tt.particle_system.scales_y = {1.5, 0.7}
tt.particle_system.scales_x = {1.5, 0.7}
tt = E:register_t("ps_hero_vesper_ricochet_bullet_trail_bounce")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "hero_vesper_ricochet_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.animation_fps = 30
tt.particle_system.emission_rate = 180
tt.particle_system.track_rotation = true
tt.particle_system.scales_y = {1, 0.7}
tt.particle_system.scales_x = {1, 0.7}
tt = E:register_t("fx_hero_vesper_attack_hit", "fx")
tt.render.sprites[1].name = "hero_vesper_attack_hit"
tt.render.sprites[1].hide_after_runs = 1
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("hero_vesper", "hero")

E:add_comps(tt, "melee", "ranged", "dodge", "timed_attacks", "teleport")

tt.hero.level_stats.armor = {0.18, 0.21, 0.24, 0.27, 0.3, 0.33, 0.36, 0.39, 0.42, 0.45}
tt.hero.level_stats.hp_max = {220, 240, 260, 280, 300, 320, 340, 360, 380, 400}
tt.hero.level_stats.melee_damage_max = {13, 14, 17, 18, 21, 22, 25, 26, 29, 30}
tt.hero.level_stats.melee_damage_min = {13, 14, 17, 18, 21, 22, 25, 26, 29, 30}
tt.hero.level_stats.ranged_short_damage_max = {13, 14, 17, 18, 21, 22, 25, 26, 29, 30}
tt.hero.level_stats.ranged_short_damage_min = {8, 9, 10, 12, 13, 14, 16, 17, 19, 20}
tt.hero.level_stats.ranged_long_damage_max = {28, 30, 37, 39, 46, 48, 55, 57, 63, 66}
tt.hero.level_stats.ranged_long_damage_min = {17, 19, 22, 26, 28, 30, 35, 37, 41, 44}
tt.hero.skills.arrow_to_the_knee = E:clone_c("hero_skill")
tt.hero.skills.arrow_to_the_knee.cooldown = {15, 13, 11}
tt.hero.skills.arrow_to_the_knee.damage_min = {54, 108, 162}
tt.hero.skills.arrow_to_the_knee.damage_max = {72, 144, 216}
tt.hero.skills.arrow_to_the_knee.stun_duration = {1, 1.5, 2}
tt.hero.skills.arrow_to_the_knee.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.arrow_to_the_knee.xp_gain = {120, 180, 360}
tt.hero.skills.ricochet = E:clone_c("hero_skill")
tt.hero.skills.ricochet.cooldown = {15, 13, 11}
tt.hero.skills.ricochet.damage_min = {45, 50, 55}
tt.hero.skills.ricochet.damage_max = {45, 50, 55}
tt.hero.skills.ricochet.bounces = {3, 5, 7}
tt.hero.skills.ricochet.xp_gain = {112, 196, 240}
tt.hero.skills.ricochet.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.martial_flourish = E:clone_c("hero_skill")
tt.hero.skills.martial_flourish.cooldown = {16, 14, 12}
tt.hero.skills.martial_flourish.damage_min = {50, 80, 120}
tt.hero.skills.martial_flourish.damage_max = {50, 80, 120}
tt.hero.skills.martial_flourish.xp_gain = {144, 256, 384}
tt.hero.skills.martial_flourish.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.disengage = E:clone_c("hero_skill")
tt.hero.skills.disengage.cooldown = {16, 14, 12}
tt.hero.skills.disengage.damage_min = {60, 110, 160}
tt.hero.skills.disengage.damage_max = {60, 110, 160}
tt.hero.skills.disengage.min_distance_from_end = 300
tt.hero.skills.disengage.distance = 130
tt.hero.skills.disengage.xp_gain = {160, 320, 480}
tt.hero.skills.disengage.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_vesper_ultimate"
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.duration = 0.8
tt.hero.skills.ultimate.cooldown = {40, 40, 40, 40}
tt.hero.skills.ultimate.xp_gain_factor = 40
tt.health.armor = nil
tt.health.dead_lifetime = 15
tt.health.hp_max = nil
tt.health_bar.offset = v(0, 39)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_vesper_level_up
tt.idle_flip.cooldown = 4
tt.info.hero_portrait = "kr5_hero_portraits_0001"
tt.info.portrait = "kr5_info_portraits_heroes_0001"
tt.main_script.insert = hero_vesper_insert
tt.main_script.update = hero_vesper_update
tt.motion.max_speed = 105
tt.regen.cooldown = 1
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].angles.ranged = {"shoot"}
tt.render.sprites[1].name = "idle_1"
tt.render.sprites[1].prefix = "hero_vesper_vesper"
tt.render.sprites[1].scale = v(1.05, 1.05)
tt.render.sprites[1].draw_order = DO_HEROES
tt.sound_events.change_rally_point = "HeroVesperTaunt"
tt.sound_events.death = "HeroVesperDeath"
tt.sound_events.respawn = "HeroVesperTauntIntro"
tt.sound_events.hero_room_select = "HeroVesperTauntSelect"
tt.soldier.melee_slot_offset.x = 5
tt.unit.marker_offset = v(0, -1)
tt.unit.mod_offset = v(0, 19.9)
tt.dodge.disabled = true
tt.dodge.ranged = false
tt.dodge.chance = 1
tt.dodge.bullet = "arrow_hero_vesper_disengage"
tt.dodge.animation_dissapear = "disengage_disappear"
tt.dodge.animation_appear = "disengage_appear"
tt.dodge.animation_attack_start = "disengage_attack_start"
tt.dodge.animation_attack_end = "disengage_attack_end"
tt.dodge.animation_end = "disengage_end"
tt.dodge.total_shoots = 3
tt.dodge.can_dodge = hero_vesper_can_dodge
tt.dodge.bullet_start_offset = {v(9, 28)}
tt.dodge.shoot_time = fts(2)
tt.dodge.sound = "HeroVesperDisengageCast"
tt.melee.attacks[1] = E:clone_c("melee_attack")
tt.melee.attacks[1].animation = "melee_attack_2"
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 2
tt.melee.attacks[1].hit_fx = "fx_hero_vesper_attack_hit"
tt.melee.attacks[1].hit_offset = v(30, 20)
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "melee_attack_1"
tt.melee.attacks[2].chance = 0.2
tt.melee.attacks[2].hit_time = fts(16)
tt.melee.attacks[2].hit_offset = v(30, 15)
tt.melee.attacks[3] = E:clone_c("melee_attack")
tt.melee.attacks[3].animations = {nil, "martial_flourish"}
tt.melee.attacks[3].damage_max = nil
tt.melee.attacks[3].damage_min = nil
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].xp_from_skill = "martial_flourish"
tt.melee.attacks[3].sound = "HeroVesperMartialFlourishCast"
tt.melee.attacks[3].hit_times = {fts(8), fts(15), fts(23)}
tt.melee.attacks[3].loops = 1
tt.melee.attacks[3].mod = "mod_hero_vesper_martial_flourish_fx"
tt.melee.cooldown = 1
tt.melee.range = 72
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].animation = "ranged_attack"
tt.ranged.attacks[1].bullet = "arrow_hero_vesper_long_arrow"
tt.ranged.attacks[1].bullet_start_offset = {v(7, 26)}
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].max_range = 205
tt.ranged.attacks[1].min_range = 150
tt.ranged.attacks[1].shoot_time = fts(8)
tt.ranged.attacks[1].shared_cooldown = true
tt.ranged.attacks[1].node_prediction = fts(8) + fts(15)
tt.ranged.attacks[1].basic_attack = true
tt.ranged.attacks[2] = E:clone_c("bullet_attack")
tt.ranged.attacks[2].animation = "ranged_attack"
tt.ranged.attacks[2].bullet = "arrow_hero_vesper_short_arrow"
tt.ranged.attacks[2].bullet_start_offset = {v(7, 26)}
tt.ranged.attacks[2].cooldown = 1
tt.ranged.attacks[2].max_range = 150
tt.ranged.attacks[2].min_range = 70
tt.ranged.attacks[2].shoot_time = fts(8)
tt.ranged.attacks[2].shared_cooldown = true
tt.ranged.attacks[2].node_prediction = fts(8) + fts(15)
tt.ranged.attacks[2].basic_attack = true
tt.ranged.attacks[3] = E:clone_c("bullet_attack")
tt.ranged.attacks[3].animation = "arrow_to_the_knee"
tt.ranged.attacks[3].bullet = "hero_vesper_arrow_to_the_knee_arrow"
tt.ranged.attacks[3].bullet_start_offset = {v(0, 20), v(0, 20)}
tt.ranged.attacks[3].cooldown = 15
tt.ranged.attacks[3].disabled = true
tt.ranged.attacks[3].max_range = 225
tt.ranged.attacks[3].min_range = 67.5
tt.ranged.attacks[3].xp_from_skill = "arrow_to_the_knee"
tt.ranged.attacks[3].vis_flag = bor(F_STUN)
tt.ranged.attacks[3].vis_bans = bor(F_BOSS)
tt.ranged.attacks[3].shoot_time = fts(16)
tt.ranged.attacks[3].node_prediction = fts(10)
tt.ranged.attacks[3].sound = "HeroVesperArrowToTheKneeCast"
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "ricochet"
tt.timed_attacks.list[1].bullet = "arrow_hero_vesper_ricochet"
tt.timed_attacks.list[1].bullet_start_offset = {v(0, 20)}
tt.timed_attacks.list[1].cooldown = 15
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].max_range = 205
tt.timed_attacks.list[1].min_range = 70
tt.timed_attacks.list[1].xp_from_skill = "ricochet"
tt.timed_attacks.list[1].shoot_time = fts(19)
tt.timed_attacks.list[1].min_targets = 2
tt.timed_attacks.list[1].max_range_trigger = 200
tt.timed_attacks.list[1].sound = "HeroVesperRicochetCast"
tt.teleport.min_distance = tt.melee.range * 2
tt.teleport.sound = "HeroVesperDisengageCast"
tt.teleport.animations = {"disengage_disappear", "teleport_out"}
tt.ui.click_rect = r(-19, -5, 38, 43)
tt.ultimate = {
	ts = 0,
	cooldown = 40
}
tt = E:register_t("hero_vesper_arrow_to_the_knee_arrow_mod", "mod_stun")
tt.modifier.duration = nil
tt = E:register_t("hero_vesper_arrow_to_the_knee_hit", "fx")
tt.render.sprites[1].name = "hero_vesper_arrow_to_the_knee_hit"
tt = E:register_t("hero_vesper_ricochet_bullet_hit_fx", "fx")
tt.render.sprites[1].name = "hero_vesper_ricochet_hit"
tt = E:register_t("hero_vesper_ultimate")

E:add_comps(tt, "pos", "main_script")

tt.main_script.update = hero_vesper_ultimate_update
tt.bullet = "hero_vesper_ultimate_arrow"
tt.offset_back = -2
tt.spread = {8, 10, 12, 14}
tt.damage = {26, 32, 39, 45}
tt.duration = 0.8
tt.enemies_range = 100
tt.node_prediction_offset = 0
tt.vis_flags = F_RANGED
tt.vis_bans = 0
tt.sounds = {"HeroVesperUltimateLvl1", "HeroVesperUltimateLvl2", "HeroVesperUltimateLvl3"}
tt = E:register_t("hero_vesper_ultimate_arrow", "bullet")
tt.main_script.update = hero_vesper_ultimate_arrow_update
tt.bullet.damage_radius = 40
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_bans = F_FRIEND
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.arrive_decal = "hero_vesper_ultimate_decal"
tt.bullet.max_speed = 1500
tt.bullet.mod = "hero_vesper_ultimate_mod"
tt.render.sprites[1].name = "hero_vesper_ultimate_arrow"
tt.render.sprites[1].animated = false
tt.sound_events.insert = "ArrowSound"
tt = E:register_t("hero_vesper_ultimate_mod", "mod_slow")
tt.modifier.duration = 1
tt.slow.factor = 0.5
tt = E:register_t("hero_vesper_ultimate_decal", "decal_tween")

AC(tt, "main_script")

tt.main_script.insert = hero_vesper_ultimate_decal_insert
tt.tween.props[1].keys = {{0, 255}, {2, 255}, {3, 0}}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.render.sprites[1].name = "hero_vesper_ultimate_arrow_decal"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("arrow_hero_vesper_short_arrow", "arrow5_fixed_height")
tt.render.sprites[1].name = "hero_vesper_arrow"
tt.bullet.fixed_height = 35
tt.bullet.g = -1000
tt.bullet.hit_blood_fx = nil
tt.bullet.pop = {"pop_archer"}
tt.bullet.hide_radius = 1
tt.bullet.prediction_error = false
tt.bullet.predict_target_pos = false
tt.bullet.miss_decal = "hero_vesper_arrow_miss"
tt.bullet.particles_name = "ps_hero_vesper_arrow_trail"
tt.bullet.xp_gain_factor = 2
tt = E:register_t("arrow_hero_vesper_long_arrow", "arrow_hero_vesper_short_arrow")
tt.bullet.xp_gain_factor = 2
tt = E:register_t("hero_vesper_arrow_to_the_knee_arrow", "arrow")
tt.main_script.insert = scripts.arrow_straight_forward.insert
tt.main_script.update = scripts.arrow_straight_forward.update
tt.render.sprites[1].name = "hero_vesper_arrow_to_the_knee_arrow"
tt.bullet.miss_decal = "hero_vesper_arrow_to_the_knee_arrow_miss"
tt.bullet.flight_time = fts(12)
tt.bullet.hide_radius = nil
tt.bullet.mod = "hero_vesper_arrow_to_the_knee_arrow_mod"
tt.bullet.particles_name = "ps_hero_vesper_arrow_to_the_knee_bullet_trail"
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.hit_fx = "hero_vesper_arrow_to_the_knee_hit"
tt.bullet.reset_to_target_pos = true
tt.bullet.hit_blood_fx = nil
tt.bullet.straight_forward_distance = 275
tt.bullet.damage_radius = 35
tt.sound_events.hit = "HeroVesperArrowToTheKneeImpact"
tt = E:register_t("arrow_hero_vesper_disengage", "arrow")
tt.render.sprites[1].name = "hero_vesper_arrow"
tt.bullet.miss_decal = "archer_hero_proy_0002-f"
tt.bullet.flight_time_min = fts(4)
tt.bullet.flight_time_per_dist = 0.0011
tt.bullet.pop = {"pop_archer"}
tt.bullet.hide_radius = 1
tt.bullet.particles_name = "ps_hero_vesper_arrow_trail"
tt.bullet.g = 0
tt = E:register_t("arrow_hero_vesper_ricochet", "bullet")
tt.main_script.update = hero_vesper_ricochet_bullet_update
tt.render.sprites[1].name = "hero_vesper_ricochet_arrow"
tt.render.sprites[1].animated = false
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bounce_arrow_name = "hero_vesper_ricochet_arrow"
tt.particle_after_bounce = "ps_hero_vesper_ricochet_bullet_trail_bounce"
tt.bullet.hit_fx = "hero_vesper_ricochet_bullet_hit_fx"
tt.bullet.acceleration_factor = 0.2
tt.bullet.min_speed = 600
tt.bullet.max_speed = 600
tt.bullet.mods = {"mod_vesper_ricochet_slow"}
tt.bullet.particles_name = "ps_hero_vesper_ricochet_bullet_trail"
tt.bullet.g = -1.8 / (fts(1) * fts(1))
tt.bounce_range = 120
tt.sound = "HeroVesperRicochetImpact"
tt = E:register_t("mod_vesper_ricochet_slow", "mod_slow")
tt.modifier.duration = 2
tt.slow.factor = 0.7
tt = E:register_t("mod_hero_vesper_martial_flourish_fx", "modifier")

E:add_comps(tt, "render")

tt.modifier.duration = fts(23)
tt.render.sprites[1].name = "hero_vesper_martial_flourish_hit"
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].loop = false
tt.main_script.update = scripts.mod_track_target.update
