local scripts = require("scripts")
local E = require("entity_db")
local GR = require("grid_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local bit = require("bit")
local km = require("lib.klua.macros")
local HU = require("hero_utils")
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

local function hero_lava_ultimate_update(this, store)
	local start_y = store.visible_coords and store.visible_coords.top or REF_H
	local ts
	local burst_interval = 0.33

	for i = 1, this.fireball_count do
		if i <= this.fireball_count then
			local e = E:create_entity(this.bullet)
			local p, tries = nil, 0

			while not p and tries < 5 do
				p = V.v(this.pos.x + math.random(-this.max_spread, this.max_spread), this.pos.y + math.random(-this.max_spread, this.max_spread))

				local oy = GR.cell_size

				if band(GR:cell_type(p.x, p.y + oy), TERRAIN_CLIFF) ~= 0 or band(GR:cell_type(p.x, p.y - oy), TERRAIN_CLIFF) ~= 0 then
					p = nil
					tries = tries + 1
				end
			end

			if p then
				e.pos.x, e.pos.y = p.x, start_y

				e.bullet.from:copy(e.pos)

				e.bullet.to = V.v(p.x, p.y)

				simulation:queue_insert_entity(e)
			end
		end

		ts = store.tick_ts

		while burst_interval > store.tick_ts - ts do
			coroutine.yield()
		end
	end

	simulation:queue_remove_entity(this)
end

local function bullet_ultimate_hero_lava_update(this, store, script)
	local b = this.bullet
	local mspeed = 10 * FPS
	local particle = E:create_entity(this.particles)

	particle.particle_system.track_id = this.id

	simulation:queue_insert_entity(particle)

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		coroutine.yield()
	end

	this.pos.x, this.pos.y = b.to.x, b.to.y
	particle.particle_system.source_lifetime = 0

	local enemies = {}

	for _, v in pairs(store.entities) do
		if v.enemy and v.vis and v.health and not v.health.dead and band(v.vis.flags, b.damage_bans) == 0 and band(v.vis.bans, b.damage_flags) == 0 and U.is_inside_ellipse(v.pos, b.to, b.damage_radius) then
			table.insert(enemies, v)
		elseif v.template_name == "hero_lava" and v.health.hp > 0 and U.is_inside_ellipse(v.pos, b.to, b.damage_radius) then
			v._death_by_ultimate = true
			v.health.hp = 0
		end
	end

	local damage_value = math.ceil(b.damage_factor * math.random(b.damage_min, b.damage_max))

	for _, enemy in ipairs(enemies) do
		local d = E.assign_damage(b.damage_type, damage_value, this.id, enemy.id)

		queue_damage(store, d)
	end

	S:queue(this.sound_events.hit)

	local cell_type = GR:cell_type(b.to.x, b.to.y)

	if band(cell_type, TERRAIN_WATER) ~= 0 then
		local fx = E:create_entity("fx_explosion_water")

		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(fx)
	else
		if b.hit_decal then
			local decal = E:create_entity(b.hit_decal)

			decal.pos:copy(b.to)

			decal.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(decal)
		end

		if b.hit_fx then
			local fx = E:create_entity(b.hit_fx)

			fx.pos.x, fx.pos.y = b.to.x, b.to.y
			fx.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(fx)
		end

		local scorched = E:create_entity(this.aura)

		scorched.pos.x, scorched.pos.y = b.to.x, b.to.y

		simulation:queue_insert_entity(scorched)
	end

	simulation:queue_remove_entity(this)
end

local function soldier_hero_lava_double_trouble_update(this, store, script)
	local brk, stam, star

	this.reinforcement.ts = store.tick_ts
	this.render.sprites[1].ts = store.tick_ts
	this.ui.can_click = false

	U.y_animation_play(this, "spawn", nil, store.tick_ts, -1)
	U.animation_start_default(this, "idle", nil, store.tick_ts, true)

	this.nav_rally.pos = V.vclone(this.pos)
	this.ui.can_click = true

	while true do
		if this.health.dead or this.reinforcement.duration and store.tick_ts - this.reinforcement.ts > this.reinforcement.duration then
			if this.health.hp > 0 then
				this.reinforcement.hp_before_timeout = 0
			end

			this.health.hp = 0
			this.render.sprites[1].z = Z_DECALS

			SU.remove_modifiers(store, this)
			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_1336_1
				end
			end

			if this.melee then
				brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
					goto label_1336_1
				end
			end

			if this.ranged then
				brk, star = SU.y_soldier_ranged_attacks(store, this)

				if brk or star == A_DONE then
					goto label_1336_1
				elseif star == A_IN_COOLDOWN then
					goto label_1336_0
				end
			end

			if this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
				goto label_1336_1
			end

			if SU.soldier_go_back_step(store, this) then
				goto label_1336_1
			end

			::label_1336_0::

			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_1336_1::

		coroutine.yield()
	end
end

local function hero_lava_level_up(this, store, initial)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "temper_tantrum", function(this, s)
		local a = this.melee.attacks[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.damage_max = s.damage_max[s.level]
		a.damage_min = s.damage_min[s.level]
	end)
	upgrade_skill(this, "hotheaded", function(this, s)
		local md = E:get_template(s.mods[1])

		md.modifier.duration = s.durations[s.level]
		md.damage_factor = s.damage_factors[s.level]

		local ms = E:get_template(s.mods[2])

		ms.modifier.duration = s.durations[s.level]
	end)
	upgrade_skill(this, "double_trouble", function(this, s)
		local a = this.ranged.attacks[1]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local b = E:get_template(a.bullet)

		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]

		local pl = E:get_template(b.bullet.hit_payload)

		pl.health.hp_max = s.soldier_hp_max[s.level]
		pl.melee.attacks[1].damage_min = s.soldier_damage_min[s.level]
		pl.melee.attacks[1].damage_max = s.soldier_damage_max[s.level]
	end)
	upgrade_skill(this, "wild_eruption", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local m = E:get_template(a.mod)

		m.modifier.duration = s.duration[s.level]
		m.dps.damage_min = s.damage_min[s.level]
		m.dps.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil
		this.ultimate.cooldown = s.cooldown[s.level]

		local uc = E:get_template(s.controller_name)

		uc.cooldown = s.cooldown[s.level]
		uc.fireball_count = s.fireball_count[s.level]

		local b = E:get_template(uc.bullet)

		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]

		local a = E:get_template(b.aura)

		a.aura.damage_min = s.scorch_damage_min[s.level]
		a.aura.damage_max = s.scorch_damage_max[s.level]

		local bc = E:get_template(this._combo_ultimate.bullet)

		bc.bullet.damage_min = b.bullet.damage_min
		bc.bullet.damage_max = b.bullet.damage_max
	end)
	update_hp(this)
end

local function hero_lava_update(this, store)
	local h = this.health
	local a, skill, brk, sta
	local hotheaded_skill = this.hero.skills.hotheaded
	local hotheaded_attack = this.timed_attacks.list[1]
	local wild_eruption = this.timed_attacks.list[2]

	local function ultimate_extra_fireballs()
		local a = this._combo_ultimate
		local max_dist2 = 10000

		local function shuffle_table(nodes)
			for i = #nodes, 2, -1 do
				local j = math.random(i)

				nodes[i], nodes[j] = nodes[j], nodes[i]
			end

			return nodes
		end

		local function shoot_bullet(pos)
			local b = E:create_entity(a.bullet)

			b.pos.x, b.pos.y = this.pos.x + a.bullet_start_offset.x, this.pos.y + a.bullet_start_offset.y

			b.bullet.from:copy(b.pos)

			b.bullet.to = pos
			b.bullet.source_id = this.id
			b.sound_events.insert = nil

			simulation:queue_insert_entity(b)
		end

		local targets = U.find_enemies_in_range_filter_off(this.pos, a.max_radius, a.vis_flags, a.vis_bans)

		if targets then
			shuffle_table(targets)
		end

		local selected_positions = {}

		for i = 1, a.max_targets do
			if not targets or #targets == 0 or #selected_positions > a.max_targets / 2 then
				goto label_457_0
			end

			local sel_target = targets[1]
			local node_offset = P:predict_enemy_node_advance(sel_target, a.cast_time + a.node_prediction)
			local e_ni = sel_target.nav_path.ni + node_offset
			local e_pos = P:node_pos(sel_target.nav_path.pi, sel_target.nav_path.spi, e_ni)

			table.insert(selected_positions, e_pos)
			table.remove(targets, 1)

			for i = #targets, 1, -1 do
				local e = targets[i]

				if max_dist2 > V.dist2(sel_target.pos.x, sel_target.pos.y, e.pos.x, e.pos.y) then
					table.remove(targets, i)
				end
			end
		end

		if #selected_positions == a.max_targets then
			goto label_457_1
		end

		::label_457_0::

		do
			local nodes = P:get_all_valid_pos(this.pos.x, this.pos.y, a.min_radius, a.max_radius, bor(TERRAIN_LAND, TERRAIN_ICE))

			shuffle_table(nodes)

			for i = #selected_positions + 1, a.max_targets do
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

		::label_457_1::

		shuffle_table(selected_positions)

		for _, p in pairs(selected_positions) do
			shoot_bullet(p)
			U.y_wait_unconditional(store, a.wait_between_shots)
		end
	end

	this.health_bar.hidden = false

	while true do
		if h.dead then
			S:queue(this.sound_events.death)
			U.unblock_target(store, this)

			local death_ts = store.tick_ts
			local flags = this.vis.flags
			local prefix = this.render.sprites[1].prefix

			U.bans_add(this.vis, F_ALL)
			U.flags_remove(this.vis, flags)

			this.health.ignore_damage = true

			if this._death_by_ultimate then
				S:queue(this.sound_death_ulti)
				U.animation_start_default(this, "idle", nil, store.tick_ts)
				U.y_wait_unconditional(store, 0.5)
				U.animation_start_default(this, "ultimate", nil, store.tick_ts)
				U.y_wait_unconditional(store, 0.5)
				ultimate_extra_fireballs()
				U.y_animation_wait_default(this)

				this.health.hp = 0
				this._death_by_ultimate = false
			else
				U.y_animation_play(this, "death", nil, store.tick_ts)
			end

			this.render.sprites[1].prefix = prefix .. "_death"

			local aura = E:create_entity(this.death_aura)

			aura.pos = this.pos

			simulation:queue_insert_entity(aura)
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)

			this.health.dead = false

			while store.tick_ts - death_ts < this.health.dead_lifetime and not this.force_respawn do
				this.render.sprites[1].z = Z_OBJECTS

				SU.y_hero_new_rally(store, this)

				this.render.sprites[1].z = Z_DECALS + 1
				this.health.ignore_damage = true

				coroutine.yield()
			end

			simulation:queue_remove_entity(aura)

			this.force_respawn = nil
			this.render.sprites[1].z = Z_OBJECTS

			U.bans_remove(this.vis, F_ALL)
			U.flags_add(this.vis, flags)

			this.render.sprites[1].prefix = prefix

			update_hp(this)

			this.health.dead = false
			this.health.ignore_damage = false

			S:queue(this.sound_events.respawn)
			U.y_animation_play(this, "respawn", nil, store.tick_ts)

			this.health_bar.hidden = false

			if hotheaded_skill.level > 0 then
				local towers = U.find_towers_in_range(store.towers, this.pos, hotheaded_attack, function(t)
					return t.tower.can_be_mod
				end)

				if not towers or #towers <= 0 then
					goto label_455_0
				end

				U.animation_start_default(this, hotheaded_attack.animation, nil, store.tick_ts, false)
				S:queue(hotheaded_attack.sound)

				for _, tower in ipairs(towers) do
					local m = E:create_entity(hotheaded_skill.mods[1])

					m.modifier.source_id = this.id
					m.modifier.target_id = tower.id

					simulation:queue_insert_entity(m)

					m = E:create_entity(hotheaded_skill.mods[2])
					m.modifier.source_id = this.id
					m.modifier.target_id = tower.id
					m.pos.x, m.pos.y = tower.pos.x, tower.pos.y

					simulation:queue_insert_entity(m)
				end

				SU.hero_gain_xp_from_skill(this, hotheaded_skill)
				SU.y_hero_animation_wait(this)
			end
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_455_0
				end
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

			skill = this.hero.skills.wild_eruption
			a = wild_eruption

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local enemies = U.find_enemies_in_range_filter_off(this.pos, a.max_range_trigger, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < a.min_targets then
					a.ts = a.ts + fts(10)
				else
					S:queue(a.sound)
					U.y_animation_play(this, wild_eruption.animation_in, nil, store.tick_ts, 1)

					local sts = store.tick_ts

					U.animation_start_default(this, wild_eruption.animation_loop, nil, store.tick_ts, true)

					local lats = store.tick_ts - a.tick

					while store.tick_ts - sts < a.loop_duration do
						if store.tick_ts - lats > a.tick then
							local enemies = U.find_enemies_in_range_filter_off(this.pos, a.max_range_effect, a.vis_flags, a.vis_bans)

							if enemies then
								for _, t in ipairs(enemies) do
									local mod = E:create_entity(a.mod)

									mod.modifier.target_id = t.id
									mod.modifier.source_id = this.id

									simulation:queue_insert_entity(mod)
								end
							end

							lats = store.tick_ts
						end

						coroutine.yield()
					end

					SU.hero_gain_xp_from_skill(this, skill)
					U.y_animation_play(this, wild_eruption.animation_out, nil, store.tick_ts, 1)

					a.ts = store.tick_ts
				end
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

		::label_455_0::

		coroutine.yield()
	end
end

local function mod_hero_lava_hotheaded_fx_update(this, store)
	local m = this.modifier

	m.ts = store.tick_ts

	U.y_animation_play(this, "in", nil, store.tick_ts, 1)
	U.animation_start_default(this, "idle", nil, store.tick_ts, true)

	while true do
		local target = store.entities[m.target_id]

		if not target or m.duration >= 0 and store.tick_ts - m.ts > m.duration then
			U.y_animation_play(this, "out", nil, store.tick_ts, 1)
			simulation:queue_remove_entity(this)

			return
		end

		coroutine.yield()
	end
end

tt = RT("ps_hero_lava_double_trouble")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_lava_skill_3_particle_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.animation_fps = 30
tt.particle_system.emission_rate = 20
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_area_spread = v(2, 2)
tt = RT("ps_ultimate_hero_lava")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_lava_ultimate_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.animation_fps = 15
tt.particle_system.emission_rate = 25
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_area_spread = v(2, 2)
tt = RT("fx_ultimate_hero_lava", "fx")
tt.render.sprites[1].name = "hero_lava_ultimate_hit"
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("soldier_hero_lava_double_trouble", "soldier_militia")

AC(tt, "reinforcement")

tt.health.armor = 0
tt.health.hp_max = nil
tt.health_bar.offset = v(0, 30)
tt.info.enc_icon = 12
tt.info.portrait = "kr5_info_portraits_soldiers_0037" -- TODO: 暂无对应头像（FL: 0056）
tt.main_script.update = soldier_hero_lava_double_trouble_update
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].sound = "CommonNoSwordAttack"
tt.melee.attacks[1].sound_args = {
	delay = fts(14)
}
tt.melee.range = 72
tt.motion.max_speed = 36
tt.reinforcement.duration = 10
tt.reinforcement.fade = false
tt.reinforcement.fade_out = false
tt.render.sprites[1].prefix = "hero_lava_skill_3_double"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].scale = vv(1.1)
tt.soldier.melee_slot_offset = v(3, 0)
tt.unit.hit_offset = v(0, 5)
tt.unit.mod_offset = v(0, 14)
tt.unit.fade_time_after_death = 1
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
tt = RT("hero_lava", "hero")

AC(tt, "melee", "ranged", "timed_attacks")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {292, 305, 318, 331, 344, 357, 370, 383, 396, 409}
tt.hero.level_stats.melee_damage_max = {15, 17, 18, 20, 21, 23, 24, 26, 28, 32}
tt.hero.level_stats.melee_damage_min = {10, 11, 12, 13, 14, 15, 16, 17, 18, 20}
tt.hero.skills.temper_tantrum = CC("hero_skill")
tt.hero.skills.temper_tantrum.cooldown = {15, 15, 15}
tt.hero.skills.temper_tantrum.damage_max = {28, 52, 80}
tt.hero.skills.temper_tantrum.damage_min = {19, 35, 54}
tt.hero.skills.temper_tantrum.xp_gain = {120, 240, 360}
tt.hero.skills.temper_tantrum.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.hotheaded = CC("hero_skill")
tt.hero.skills.hotheaded.mods = {"mod_hero_lava_hotheaded", "mod_hero_lava_hotheaded_fx"}
tt.hero.skills.hotheaded.durations = {6, 6, 6}
tt.hero.skills.hotheaded.damage_factors = {1.2, 1.3, 1.4}
tt.hero.skills.hotheaded.xp_gain = {2560, 3600, 4640}
tt.hero.skills.hotheaded.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.double_trouble = CC("hero_skill")
tt.hero.skills.double_trouble.cooldown = {20, 20, 20}
tt.hero.skills.double_trouble.damage_min = {30, 50, 75}
tt.hero.skills.double_trouble.damage_max = {30, 50, 75}
tt.hero.skills.double_trouble.soldier_damage_min = {10, 13, 16}
tt.hero.skills.double_trouble.soldier_damage_max = {14, 19, 24}
tt.hero.skills.double_trouble.soldier_hp_max = {97, 130, 162}
tt.hero.skills.double_trouble.xp_gain = {160, 320, 480}
tt.hero.skills.double_trouble.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.wild_eruption = CC("hero_skill")
tt.hero.skills.wild_eruption.cooldown = {30, 30, 30}
tt.hero.skills.wild_eruption.damage_min = {10, 12, 15}
tt.hero.skills.wild_eruption.damage_max = {10, 12, 15}
tt.hero.skills.wild_eruption.duration = {4, 4, 4}
tt.hero.skills.wild_eruption.xp_gain = {240, 480, 720}
tt.hero.skills.wild_eruption.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_lava_ultimate"
tt.hero.skills.ultimate.cooldown = {48, 48, 48, 48}
tt.hero.skills.ultimate.damage_min = {40, 80, 130, 200}
tt.hero.skills.ultimate.damage_max = {40, 80, 130, 200}
tt.hero.skills.ultimate.fireball_count = {3, 4, 5, 6}
tt.hero.skills.ultimate.scorch_damage_min = {1, 1, 1, 1}
tt.hero.skills.ultimate.scorch_damage_max = {1, 1, 1, 1}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.ultimate = {
	ts = 0,
	cooldown = 48
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 50)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_lava_level_up
tt.info.hero_portrait = "kr5_hero_portraits_0016"
tt.info.portrait = "kr5_info_portraits_heroes_0016"
tt.main_script.update = hero_lava_update
tt.motion.max_speed = 55
tt.regen.cooldown = 1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_lava_hero"
tt.render.sprites[1].scale = v(1.05, 1.05)
tt.render.sprites[1].draw_order = DO_HEROES
tt.soldier.melee_slot_offset = v(10, 0)
tt.sound_events.change_rally_point = "HeroKratoaTaunt"
tt.sound_events.death = "HeroKratoaDeath"
tt.sound_events.respawn = "HeroKratoaTauntIntro"
tt.sound_events.hero_room_select = "HeroKratoaTauntSelect"
tt.unit.hit_offset = v(0, 14)
tt.unit.mod_offset = v(0, 13)
tt.melee.range = 72
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animation = "melee_attack"
tt.melee.attacks[1].cooldown = 1.25
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].sound = "HeroKratoaBasicAttack"
tt.melee.attacks[1].xp_gain_factor = 1.8
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].damage_max = nil
tt.melee.attacks[2].damage_min = nil
tt.melee.attacks[2].loops = 1
tt.melee.attacks[2].hit_times = {fts(15), fts(25), fts(43)}
tt.melee.attacks[2].sound = "HeroKratoaTemperTantrum"
tt.melee.attacks[2].animations = {nil, "skill_1"}
tt.melee.attacks[2].damage_type = bor(DAMAGE_PHYSICAL, DAMAGE_TRUE)
tt.melee.attacks[2].xp_from_skill = "temper_tantrum"
tt.melee.attacks[2].hit_offset = v(35, 0)
tt.melee.attacks[2].mod = "mod_hero_lava_temper_tantrum_stun"
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "skill_2"
tt.timed_attacks.list[1].cooldown = 0
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].max_range = 180
tt.timed_attacks.list[1].mod = "mod_hero_lava_hotheaded"
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].cast_time = fts(8)
tt.timed_attacks.list[1].sound = "HeroKratoaHotheaded"
tt.timed_attacks.list[1].mod_decal = "mod_hero_lava_hotheaded_fx"
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "skill_3"
tt.ranged.attacks[1].bullet = "bomb_hero_lava_double_touble"
tt.ranged.attacks[1].bullet_start_offset = {v(20, 40)}
tt.ranged.attacks[1].cooldown = 20
tt.ranged.attacks[1].min_range = 100
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].shoot_time = fts(23)
tt.ranged.attacks[1].vis_bans = bor(F_FLYING)
tt.ranged.attacks[1].shared_cooldown = true
tt.ranged.attacks[1].node_prediction = fts(8) + fts(15)
tt.ranged.attacks[1].disabled = true
tt.ranged.attacks[1].xp_from_skill = "double_trouble"
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].animation_in = "skill_4_in"
tt.timed_attacks.list[2].animation_loop = "skill_4_loop"
tt.timed_attacks.list[2].animation_out = "skill_4_out"
tt.timed_attacks.list[2].tick = 1
tt.timed_attacks.list[2].cast_time = fts(13)
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING, F_FRIEND)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED, F_STUN)
tt.timed_attacks.list[2].max_range_trigger = 60
tt.timed_attacks.list[2].min_range_trigger = 0
tt.timed_attacks.list[2].max_range_effect = 100
tt.timed_attacks.list[2].min_range_effect = 0
tt.timed_attacks.list[2].loop_duration = 1.5
tt.timed_attacks.list[2].min_targets = 3
tt.timed_attacks.list[2].mod = "mod_hero_lava_wild_eruption_burning"
tt.timed_attacks.list[2].sound = "HeroKratoaWildEruption"
tt.ui.click_rect = r(-20, -5, 40, 43)
tt.death_aura = "aura_hero_lava_death"
tt._combo_ultimate = {}
tt._combo_ultimate.bullet_start_offset = v(0, 30)
tt._combo_ultimate.bullet = "bullet_combo_ultimate_hero_lava"
tt._combo_ultimate.min_radius = 100
tt._combo_ultimate.max_radius = 400
tt._combo_ultimate.vis_flags = bor(F_RANGED, F_STUN)
tt._combo_ultimate.vis_bans = bor(F_FLYING, F_FRIEND)
tt._combo_ultimate.max_targets = 12
tt._combo_ultimate.cast_time = 0
tt._combo_ultimate.node_prediction = fts(8) + fts(15)
tt._combo_ultimate.wait_between_shots = fts(3)
tt.sound_death_ulti = "HeroKratoaRageOutburstDeath"
tt = RT("hero_lava_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.max_spread = 30
tt.bullet = "bullet_ultimate_hero_lava"
tt.main_script.update = hero_lava_ultimate_update
tt = RT("fx_explosion_hero_lava_double_trouble", "fx")
tt.render.sprites[1].name = "hero_lava_ultimate_hit"
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("decal_ultimate_hero_lava", "decal_tween")
tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}
tt.render.sprites[1].name = "hero_lava_ultimate_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = v(1.2, 1.2)
tt = RT("bullet_ultimate_hero_lava", "bullet")
tt.bullet.min_speed = 0
tt.bullet.max_speed = 15 * FPS
tt.bullet.acceleration_factor = 0.05
tt.bullet.hit_fx = "fx_ultimate_hero_lava"
tt.bullet.hit_decal = "decal_ultimate_hero_lava"
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_radius = 60
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.damage_flags = F_AREA
tt.render.sprites[1].name = "hero_lava_ultimate_projectile_idle"
tt.particles = "ps_ultimate_hero_lava"
tt.main_script.update = bullet_ultimate_hero_lava_update
tt.aura = "aura_bullet_ultimate_hero_lava"
tt.sound_events.insert = "HeroKratoaRageOutburstCast"
tt.sound_events.hit = "HeroKratoaRageOutburstImpact"
tt = RT("bullet_combo_ultimate_hero_lava", "bullet_ultimate_hero_lava")
tt.main_script.insert = scripts.bomb.insert
tt.main_script.update = scripts.bomb.update
tt.bullet.flight_time = fts(28)
tt.bullet.g = -1.5 / (fts(1) * fts(1))
tt.bullet.align_with_trajectory = true
tt = RT("aura_bullet_ultimate_hero_lava", "aura")
tt.main_script.update = scripts.aura_apply_damage.update
tt.aura.duration = 4
tt.aura.radius = 60
tt.aura.cycle_time = 0.25
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.vis_flags = bor(F_MOD)
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt = RT("aura_hero_lava_death", "aura")
tt.main_script.update = scripts.aura_apply_damage.update
tt.aura.duration = 1e+99
tt.aura.radius = 70
tt.aura.cycle_time = 0.25
tt.aura.damage_min = 5
tt.aura.damage_max = 7
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.vis_flags = bor(F_MOD)
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.mod = "mod_hero_lava_burn"
tt = RT("bomb_hero_lava_double_touble", "bomb")
tt.bullet.flight_time = fts(15)
tt.render.sprites[1].prefix = "hero_lava_skill_3_projectile"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.bullet.fixed_height = 35
tt.bullet.g = -1000
tt.bullet.hide_radius = 0
tt.bullet.prediction_error = true
tt.bullet.predict_target_pos = false
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.damage_radius = 70
tt.bullet.ignore_hit_offset = true
tt.bullet.hit_fx = "fx_explosion_hero_lava_double_trouble"
tt.bullet.hit_payload = "soldier_hero_lava_double_trouble"
tt.bullet.particles_name = "ps_hero_lava_double_trouble"
tt.sound_events.insert = "HeroKratoaDoubleTroubleCast"
tt.sound_events.hit = "HeroKratoaDoubleTroubleImpact"
tt = RT("mod_hero_lava_hotheaded", "modifier")
tt.main_script.insert = scripts.mod_tower_factors.insert
tt.main_script.remove = scripts.mod_tower_factors.remove
tt.main_script.update = scripts.mod_tower_arcane_wizard_power_empowerment.update
tt.range_factor = 1
tt.modifier.duration = 1e+99
tt.modifier.use_mod_offset = false
tt = RT("mod_hero_lava_hotheaded_fx", "modifier")

AC(tt, "render")

tt.main_script.update = mod_hero_lava_hotheaded_fx_update
tt.modifier.duration = 1e+99
tt.modifier.use_mod_offset = false
tt.modifier.keep_on_tower_upgrade = true
tt.render.sprites[1].prefix = "hero_lava_respawn_tower_FX"
tt.render.sprites[1].offset.y = 5
tt.render.sprites[1].sort_y_offset = -5
tt.sound_events.insert = "TowerArcaneWizardEmpowerment"
tt = RT("mod_hero_lava_burn", "modifier")

AC(tt, "render")

tt.modifier.duration = 1
tt.render.sprites[1].prefix = "brute_welder_attack_mod"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].draw_order = 2
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update
tt = RT("mod_hero_lava_wild_eruption_burning", "modifier")

AC(tt, "dps", "render")

tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = 0.25
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 2
tt = RT("mod_hero_lava_temper_tantrum_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
