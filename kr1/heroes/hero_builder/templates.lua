local scripts = require("scripts")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local bit = require("bit")
local apply_ultimate = HU.apply_ultimate
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local tt

local function hero_builder_level_up(this, store)
	level_up_basic(this)

	this.melee.attacks[1].damage_min = this.hero.level_stats.melee_damage_min[this.hero.level]
	this.melee.attacks[1].damage_max = this.hero.level_stats.melee_damage_max[this.hero.level]

	upgrade_skill(this, "overtime_work", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local e = E:get_template(a.entity)

		e.health.hp_max = s.hp_max[s.level]
		e.melee.attacks[1].damage_max = s.damage_max[s.level]
		e.melee.attacks[1].damage_min = s.damage_min[s.level]
	end)
	upgrade_skill(this, "lunch_break", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local m = E:get_template(a.mod)

		m.heal_hp = s.heal_hp[s.level]
	end)
	upgrade_skill(this, "demolition_man", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local e = E:get_template(a.aura)

		e.aura.duration = s.duration[s.level]
		e.aura.damage_min = s.damage_min[s.level]
		e.aura.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "defensive_turret", function(this, s)
		local a = this.timed_attacks.list[4]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local e = E:get_template(a.entity)

		e.bullet_attack.cooldown = s.attack_cooldown[s.level]
		e.duration = s.duration[s.level]

		local b = E:get_template(e.bullet_attack.bullet)

		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		local sl = s.level

		this.ultimate.disabled = nil

		local uc = E:get_template(s.controller_name)

		this.ultimate.cooldown = s.cooldown[sl]
		uc.cooldown = s.cooldown[sl]

		local projectile = E:get_template(uc.entity)
		local aura = E:get_template(projectile.bullet.aura)

		aura.aura.damage_min = s.damage[sl]
		aura.aura.damage_max = s.damage[sl]

		local m = E:get_template(aura.aura.mod)

		m.modifier.duration = s.stun_duration[sl]
	end)
	update_hp(this)
end

local function hero_builder_update(this, store)
	local h = this.health
	local a, skill, brk, sta
	local overtime_work_attack = this.timed_attacks.list[1]
	local lunch_break_attack = this.timed_attacks.list[2]
	local demolition_man_attack = this.timed_attacks.list[3]
	local defensive_turret_attack = this.timed_attacks.list[4]
	local last_target
	local base_speed = this.motion.max_speed

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
			U.update_max_speed(this, base_speed)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_builder_1
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local target = find_target_at_critical_moment(this, 200, F_AREA, F_FLYING, nil, nil, true)

				if target then
					apply_ultimate(this, store, target.pos, "levelup")
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			skill = this.hero.skills.overtime_work
			a = overtime_work_attack

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local enemies = U.find_enemies_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < a.min_targets then
					a.ts = a.ts + fts(10)
				else
					local start_ts = store.tick_ts

					S:queue(a.sound, {
						delay = fts(10)
					})
					U.animation_start_default(this, a.animation, nil, store.tick_ts, false)

					if SU.y_hero_wait(store, this, a.cast_time) then
						goto label_builder_1
					end

					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, skill)

					enemies = U.find_enemies_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

					local e = E:create_entity(a.entity)

					e.pos.x = this.pos.x + 10
					e.pos.y = this.pos.y - 10
					e.nav_rally.center = V.v(this.pos.x, this.pos.y)
					e.nav_rally.pos = V.vclone(e.pos)

					simulation:queue_insert_entity(e)

					local fx = E:create_entity(a.spawn_fx)

					fx.pos.x, fx.pos.y = e.pos.x, e.pos.y
					fx.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(fx)

					e = E:create_entity(a.entity)
					e.pos.x = this.pos.x - 10
					e.pos.y = this.pos.y + 10
					e.nav_rally.center = V.v(this.pos.x, this.pos.y)
					e.nav_rally.pos = V.vclone(e.pos)

					simulation:queue_insert_entity(e)

					fx = E:create_entity(a.spawn_fx)
					fx.pos.x, fx.pos.y = e.pos.x, e.pos.y
					fx.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(fx)
					SU.y_hero_animation_wait(this)

					goto label_builder_1
				end
			end

			a = lunch_break_attack
			skill = this.hero.skills.lunch_break

			if this.health.hp <= this.health.hp_max * a.lost_health and ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local start_ts = store.tick_ts

				U.animation_start_default(this, a.animation, nil, store.tick_ts, false)

				if SU.y_hero_wait(store, this, a.cast_time) then
					goto label_builder_1
				end

				a.ts = start_ts

				S:queue(a.sound, {
					delay = fts(10)
				})
				SU.hero_gain_xp_from_skill(this, skill)

				local mod = E:create_entity(a.mod)

				mod.modifier.target_id = this.id
				mod.modifier.source_id = this.id

				simulation:queue_insert_entity(mod)
				U.y_animation_wait_default(this)
			end

			skill = this.hero.skills.demolition_man
			a = demolition_man_attack

			if this.soldier.target_id and not last_target or this.soldier.target_id ~= last_target then
				last_target = this.soldier.target_id
			end

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local enemies = U.find_enemies_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < a.min_targets then
					a.ts = a.ts + fts(10)
				else
					local start_ts = store.tick_ts

					S:queue(a.sound, {
						delay = fts(10)
					})

					local fx = E:create_entity(a.fx)

					fx.pos = this.pos
					fx.render.sprites[1].ts = store.tick_ts
					fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x

					simulation:queue_insert_entity(fx)
					U.animation_start_default(this, a.animation .. "_start", nil, store.tick_ts, false)
					U.animation_start_default(fx, "start", nil, store.tick_ts, false)

					if SU.y_hero_wait(store, this, a.cast_time) then
						goto label_builder_1
					end

					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, skill)

					local aura = E:create_entity(a.aura)

					aura.aura.source_id = this.id
					aura.aura.ts = store.tick_ts
					aura.pos = this.pos

					simulation:queue_insert_entity(aura)
					U.animation_start_default(this, a.animation .. "_loop", nil, store.tick_ts, true)
					U.animation_start_default(fx, "loop", nil, store.tick_ts, true)

					if SU.y_hero_wait(store, this, aura.aura.duration - (store.tick_ts - a.ts)) then
					-- block empty
					end

					simulation:queue_remove_entity(aura)
					U.animation_start_default(fx, "end", nil, store.tick_ts, false)
					U.y_animation_play(this, a.animation .. "_end", nil, store.tick_ts, 1)
					SU.y_hero_animation_wait(this)
					simulation:queue_remove_entity(fx)

					goto label_builder_1
				end
			end

			skill = this.hero.skills.defensive_turret
			a = defensive_turret_attack

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local enemies = U.find_enemies_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < a.min_targets then
					a.ts = a.ts + fts(10)
				else
					local nearest = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)
					local pi, spi, ni = unpack(nearest[1])
					local turret_pos = P:node_pos(pi, spi, ni)
					local new_pos = {}

					new_pos.x, new_pos.y = turret_pos.x - a.spawn_offset.x, turret_pos.y

					if this.pos.x > turret_pos.x then
						new_pos.x = turret_pos.x + a.spawn_offset.x
					end

					local node_limit = math.floor(a.min_distance_from_border / P.average_node_dist)
					local nodes_to_goal = P:nodes_to_goal(pi, spi, ni)
					local nodes_from_start = P:nodes_from_start(pi, spi, ni)

					if nodes_to_goal < node_limit or nodes_from_start < node_limit then
						a.ts = a.ts + 0.13333333333333333
					else
						local start_ts = store.tick_ts

						this.nav_rally.new = true
						this.nav_rally.center = new_pos
						this.nav_rally.pos = new_pos

						U.update_max_speed(this, a.build_speed)

						local se = this.sound_events

						this.sound_events = nil

						while this.nav_rally.new do
							if SU.y_hero_new_rally(store, this) then
								break
							end

							if this.nav_rally.new then
								this.sound_events = se

								goto label_builder_0
							end
						end

						this.sound_events = se

						U.update_max_speed(this, base_speed)

						local an, af = U.animation_name_facing_point(this, a.animation, turret_pos)

						U.animation_start_default(this, an, af, store.tick_ts, false)

						this.health_bar.hidden = true

						local _vis = {}

						_vis.bans, _vis.flags = this.vis.bans, this.vis.flags

						U.bans_add(this.vis, F_ALL)
						U.flags_remove(this.vis, _vis.flags)

						this.ui.can_select = false

						SU.remove_modifiers(store, this)

						if SU.y_hero_wait(store, this, a.cast_time) then
							goto label_builder_1
						end

						a.ts = start_ts

						SU.hero_gain_xp_from_skill(this, skill)

						local e = E:create_entity(a.entity)
						local epos = turret_pos

						e.flip_x = this.render.sprites[1].flip_x
						e.pos = V.vclone(epos)

						simulation:queue_insert_entity(e)
						S:queue(a.sound_cast, {
							delay = fts(10)
						})

						e.sound_destroy = a.sound_destroy

						while not U.animation_finished_default(this) do
							coroutine.yield()
						end

						this.health_bar.hidden = false

						U.bans_remove(this.vis, F_ALL)
						U.flags_add(this.vis, _vis.flags)

						this.ui.can_select = true

						goto label_builder_1
					end
				end
			end

			::label_builder_0::

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			elseif SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_builder_1::

		coroutine.yield()
	end
end

local function decal_hero_builder_ultimate_projectile_update(this, store)
	local b = this.bullet
	local speed = b.max_speed

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) >= 2 * (speed * store.tick_length) do
		b.speed.x, b.speed.y = V.mul(speed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		coroutine.yield()
	end

	this.pos:copy(b.to)

	local shake = E:create_entity("aura_screen_shake")

	shake.aura.amplitude = 0.4
	shake.aura.duration = 1
	shake.aura.freq_factor = 2

	simulation:queue_insert_entity(shake)

	local aura = E:create_entity(b.aura)

	aura.pos:copy(b.to)

	aura.aura.damage_factor = b.damage_factor

	simulation:queue_insert_entity(aura)
	SU.insert_sprite(store, this.bullet.arrive_decal, this.pos)
	simulation:queue_remove_entity(this)
end

local function mod_hero_builder_lunch_break_insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	U.heal(target, this.heal_hp)

	return true
end

local function hero_builder_ultimate_update(this, store)
	local b = E:create_entity(this.entity)

	b.bullet.from:set(this.pos.x, this.pos.y + REF_H)
	b.bullet.to:copy(this.pos)

	b.bullet.damage_factor = this.damage_factor
	b.sound = this.sound

	b.pos:copy(b.bullet.from)
	simulation:queue_insert_entity(b)
	simulation:queue_remove_entity(this)
end

local function decal_hero_builder_ultimate_ball_update(this, store)
	U.animation_start(this, "hero_obdul_ultimate_decal", nil, store.tick_ts, false, 9)
	U.animation_start(this, "hero_obdul_ultimate_decal", nil, store.tick_ts, false, 10)
	U.animation_start(this, "hero_obdul_ultimate_decal", nil, store.tick_ts, false, 11)
	U.animation_start(this, "in", nil, store.tick_ts, false, 1)

	for i = 1, 4 do
		U.animation_start(this, "rock_0" .. i .. "_in", nil, store.tick_ts, false, i + 2)
	end

	U.animation_start(this, "dust_over_ball_run", nil, store.tick_ts, false, 7)
	U.animation_start(this, "ball", nil, store.tick_ts, false, 2)

	for i = 11, 16 do
		U.animation_start(this, "dust_cloud", nil, store.tick_ts, false, i)
	end

	local start_ts = store.tick_ts

	while true do
		if store.tick_ts - start_ts > this.duration then
			this.tween.ts = store.tick_ts
			this.tween.disabled = false

			U.y_wait_unconditional(store, this.tween.props[1].keys[2][1])
		end

		coroutine.yield()
	end
end

local function decal_hero_builder_defensive_turret_update(this, store)
	local a = this.bullet_attack
	local soldier_sid = 2

	for i = 1, 3 do
		this.render.sprites[i].flip_x = this.flip_x
	end

	U.y_animation_play_group(this, "spawn", nil, store.tick_ts, false, "layers")

	a.ts = store.tick_ts - a.cooldown
	this.start_ts = store.tick_ts

	while true do
		if store.tick_ts - this.start_ts > this.duration then
			S:queue(this.sound_destroy, {
				delay = fts(10)
			})
			U.y_animation_play_group(this, "death", nil, store.tick_ts, false, "layers")

			break
		end

		if store.tick_ts - a.ts > a.cooldown then
			local target = U.find_foremost_enemy_in_range_filter_off(this.pos, a.max_range, false, a.vis_flags, a.vis_bans)

			if not target then
				a.ts = a.ts + 0.2
			else
				a.ts = store.tick_ts

				if target and target.health and not target.health.dead then
					local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

					U.animation_start(this, an, af, store.tick_ts, false, soldier_sid)
					U.animation_start(this, an, nil, store.tick_ts, false, 1)
					U.y_wait_unconditional(store, a.shoot_time)

					local idx = 1

					if this.render.sprites[soldier_sid].flip_x then
						idx = 2
					end

					local b = E:create_entity(a.bullet)

					b.bullet.from = V.v(this.pos.x + a.bullet_start_offset[idx].x, this.pos.y + a.bullet_start_offset[idx].y)
					b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
					b.bullet.target_id = target.id
					b.bullet.source_id = this.id

					b.pos:copy(b.bullet.from)
					simulation:queue_insert_entity(b)
					U.y_animation_wait_default(this)
				end
			end
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

tt = RT("fx_hero_builder_melee_attack_hit", "fx")
tt.render.sprites[1].name = "hero_obdul_basic_attack_hit"
tt = RT("fx_hero_builder_overtime_work_raise", "fx")
tt.render.sprites[1].name = "hero_obdul_skill_5_soldier_spawn_decal"
tt.render.sprites[1].z = Z_DECALS
tt = RT("hero_builder", "hero")

AC(tt, "melee", "ranged", "timed_attacks")

tt.hero.level_stats.armor = {0.03, 0.06, 0.09, 0.12, 0.15, 0.18, 0.21, 0.24, 0.27, 0.3}
tt.hero.level_stats.hp_max = {325, 364, 403, 442, 481, 520, 559, 598, 637, 676}
tt.hero.level_stats.melee_damage_max = {16, 19, 21, 23, 24, 26, 28, 30, 32, 34}
tt.hero.level_stats.melee_damage_min = {10, 12, 14, 15, 16, 18, 19, 20, 21, 22}
tt.hero.skills.overtime_work = E:clone_c("hero_skill")
tt.hero.skills.overtime_work.cooldown = {11, 11, 11}
tt.hero.skills.overtime_work.damage_min = {2, 4, 6}
tt.hero.skills.overtime_work.damage_max = {4, 8, 12}
tt.hero.skills.overtime_work.hp_max = {50, 75, 100}
tt.hero.skills.overtime_work.xp_gain = {100, 200, 300}
tt.hero.skills.overtime_work.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.lunch_break = E:clone_c("hero_skill")
tt.hero.skills.lunch_break.cooldown = {30, 28, 26}
tt.hero.skills.lunch_break.heal_hp = {125, 250, 375}
tt.hero.skills.lunch_break.xp_gain = {240, 480, 720}
tt.hero.skills.lunch_break.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.demolition_man = E:clone_c("hero_skill")
tt.hero.skills.demolition_man.cooldown = {16, 16, 16}
tt.hero.skills.demolition_man.duration = {1.25, 1.25, 1.25}
tt.hero.skills.demolition_man.damage_min = {5, 10, 15}
tt.hero.skills.demolition_man.damage_max = {8, 16, 24}
tt.hero.skills.demolition_man.xp_gain = {160, 320, 480}
tt.hero.skills.demolition_man.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.defensive_turret = E:clone_c("hero_skill")
tt.hero.skills.defensive_turret.cooldown = {30, 30, 30}
tt.hero.skills.defensive_turret.attack_cooldown = {0.8, 0.8, 0.8}
tt.hero.skills.defensive_turret.duration = {12, 13.5, 15}
tt.hero.skills.defensive_turret.damage_min = {8, 16, 24}
tt.hero.skills.defensive_turret.damage_max = {12, 24, 36}
tt.hero.skills.defensive_turret.xp_gain = {240, 480, 720}
tt.hero.skills.defensive_turret.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.controller_name = "controller_hero_builder_ultimate"
tt.hero.skills.ultimate.damage = {120, 180, 240, 300}
tt.hero.skills.ultimate.stun_duration = {2, 2, 2, 2}
tt.hero.skills.ultimate.cooldown = {35, 35, 35, 35}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 53)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_builder_level_up
tt.info.hero_portrait = "kr5_hero_portraits_0005"
tt.info.portrait = "kr5_info_portraits_heroes_0005"
tt.main_script.update = hero_builder_update
tt.motion.max_speed = 75
tt.regen.cooldown = 1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_obdul_hero"
tt.render.sprites[1].draw_order = DO_HEROES
tt.render.sprites[1].scale = v(0.9, 0.9)
tt.ui.click_rect = r(-30, -4, 60, 50)
tt.soldier.melee_slot_offset = v(20, 0)
tt.sound_events.change_rally_point = "HeroBuilderTaunt"
tt.sound_events.death = "HeroBuilderDeath"
tt.sound_events.respawn = "HeroBuilderTauntIntro"
tt.sound_events.hero_room_select = "HeroBuilderTauntSelect"
tt.unit.hit_offset = v(0, 14)
tt.unit.mod_offset = v(0, 13)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.melee.range = 72
tt.melee.attacks[1] = E:clone_c("melee_attack")
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].hit_fx = "fx_hero_builder_melee_attack_hit"
tt.melee.attacks[1].hit_offset = v(45, 15)
tt.melee.attacks[1].sound = "HeroBuilderBasicAttack"
tt.melee.attacks[1].sound_args = {
	delay = fts(14)
}
tt.melee.attacks[1].xp_gain_factor = 2.6
tt.melee.attacks[1].basic_attack = true
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "skill_5"
tt.timed_attacks.list[1].cast_time = fts(10)
tt.timed_attacks.list[1].entity = "soldier_hero_builder_worker"
tt.timed_attacks.list[1].max_range = 120
tt.timed_attacks.list[1].min_targets = 2
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1].sound = "HeroBuilderMenAtWork"
tt.timed_attacks.list[1].min_cooldown = 5
tt.timed_attacks.list[1].spawn_fx = "fx_hero_builder_overtime_work_raise"
tt.timed_attacks.list[2] = E:clone_c("mod_attack")
tt.timed_attacks.list[2].animation = "skill_2"
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].lost_health = 0.4
tt.timed_attacks.list[2].cast_time = fts(15)
tt.timed_attacks.list[2].mod = "mod_hero_builder_lunch_break"
tt.timed_attacks.list[2].sound = "HeroBuilderLunchBreak"
tt.timed_attacks.list[2].min_cooldown = 5
tt.timed_attacks.list[3] = E:clone_c("custom_attack")
tt.timed_attacks.list[3].animation = "skill_3"
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].cast_time = fts(15)
tt.timed_attacks.list[3].sound = "HeroBuilderDemolitionMan"
tt.timed_attacks.list[3].max_range = 75
tt.timed_attacks.list[3].min_targets = 2
tt.timed_attacks.list[3].aura = "aura_hero_builder_demolition_man"
tt.timed_attacks.list[3].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[3].fx = "fx_hero_builder_demolition_man"
tt.timed_attacks.list[3].min_cooldown = 5
tt.timed_attacks.list[3].min_fight_cooldown = 2
tt.timed_attacks.list[4] = E:clone_c("custom_attack")
tt.timed_attacks.list[4].animation = "skill_4"
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].cast_time = fts(14)
tt.timed_attacks.list[4].sound_cast = "HeroBuilderDefensiveTurretCast"
tt.timed_attacks.list[4].sound_destroy = "HeroBuilderDefensiveTurretDestroy"
tt.timed_attacks.list[4].entity = "decal_hero_builder_defensive_turret"
tt.timed_attacks.list[4].max_range = 180
tt.timed_attacks.list[4].build_speed = 168
tt.timed_attacks.list[4].min_targets = 1
tt.timed_attacks.list[4].spawn_offset = v(51, 0)
tt.timed_attacks.list[4].min_cooldown = 5
tt.timed_attacks.list[4].min_distance_from_border = 100
tt.ultimate = {
	ts = 0,
	cooldown = 35
}
tt = RT("soldier_hero_builder_worker", "soldier_militia")

AC(tt, "reinforcement", "tween")

tt.health.armor = 0.15
tt.health.hp_max = nil
tt.health_bar.offset = v(0, 35)
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.info.portrait = "kr5_info_portraits_soldiers_0003"
tt.info.random_name_format = "SOLDIER_HERO_BUILDER_WORKER_%i_NAME"
tt.info.random_name_count = 8
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.range = 80
tt.motion.max_speed = 60
tt.regen.health = 0
tt.reinforcement.duration = 12
tt.render.sprites[1].prefix = "hero_obdul_skill_5_soldier"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].anchor = v(0.5, 0.36)
tt.soldier.melee_slot_offset = v(3, 0)
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.unit.hit_offset = v(0, 5)
tt.unit.mod_offset = v(0, 14)
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
tt = RT("decal_hero_builder_defensive_turret", "decal_scripted")

AC(tt, "bullet_attack")

for i = 1, 3 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "hero_obdul_skill_4_tower_layer" .. i
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].group = "layers"
end

tt.bullet_attack.max_range = 150
tt.bullet_attack.bullet = "arrow_hero_builder_defensive_turret"
tt.bullet_attack.shoot_time = fts(6)
tt.bullet_attack.bullet_start_offset = {v(10, 55), v(-10, 55)}
tt.bullet_attack.animation = "attack"
tt.bullet_attack.vis_bans = bor(F_FRIEND)
tt.main_script.update = decal_hero_builder_defensive_turret_update
tt = RT("decal_hero_builder_ultimate_projectile", "decal_scripted")

AC(tt, "bullet")

tt.render.sprites[1].name = "hero_obdul_ultimate_projectile"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.2, 0.5)
tt.bullet.max_speed = 3000
tt.bullet.arrive_decal = "decal_hero_builder_ultimate_ball"
tt.bullet.aura = "aura_hero_builder_ultimate"
tt.main_script.update = decal_hero_builder_ultimate_projectile_update
tt = RT("decal_hero_builder_ultimate_ball", "decal_scripted")

AC(tt, "tween")

tt.render.sprites[1].prefix = "hero_obdul_ultimate"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "hero_obdul_ultimate"
tt.render.sprites[2].name = "ball"
tt.render.sprites[2].loop = false

for i = 1, 4 do
	tt.render.sprites[i + 2] = E:clone_c("sprite")
	tt.render.sprites[i + 2].prefix = "hero_obdul_ultimate"
	tt.render.sprites[i + 2].name = "rock_0" .. i .. "_in"
	tt.render.sprites[i + 1].loop = false
end

tt.render.sprites[7] = E:clone_c("sprite")
tt.render.sprites[7].prefix = "hero_obdul_ultimate"
tt.render.sprites[7].name = "dust_over_ball_run"
tt.render.sprites[7].loop = false
tt.render.sprites[8] = E:clone_c("sprite")
tt.render.sprites[8].name = "hero_obdul_ultimate_decal"
tt.render.sprites[8].offset = v(0, 20)
tt.render.sprites[8].loop = false
tt.render.sprites[8].animated = false
tt.render.sprites[8].z = Z_DECALS
tt.render.sprites[8].scale = v(0.8, 0.8)
tt.render.sprites[9] = E:clone_c("sprite")
tt.render.sprites[9].name = "hero_obdul_ultimate_decal"
tt.render.sprites[9].offset = v(-20, -7)
tt.render.sprites[9].loop = false
tt.render.sprites[9].animated = false
tt.render.sprites[9].z = Z_DECALS
tt.render.sprites[9].scale = v(0.8, 0.8)
tt.render.sprites[10] = E:clone_c("sprite")
tt.render.sprites[10].name = "hero_obdul_ultimate_decal"
tt.render.sprites[10].offset = v(20, -7)
tt.render.sprites[10].loop = false
tt.render.sprites[10].animated = false
tt.render.sprites[10].z = Z_DECALS
tt.render.sprites[10].scale = v(0.8, 0.8)

local dust_scales = {v(0.8, 0.8), v(0.7, 0.7), v(0.7, 0.7), v(0.8, 0.8), v(0.7, 0.7), v(0.7, 0.7)}
local dust_offset = {v(-30, 20), v(-35, 0), v(-20, -10), v(30, 20), v(35, 0), v(20, -10)}

for i = 1, 6 do
	tt.render.sprites[10 + i] = E:clone_c("sprite")
	tt.render.sprites[10 + i].prefix = "hero_obdul_ultimate"
	tt.render.sprites[10 + i].name = "dust_cloud"
	tt.render.sprites[10 + i].loop = false
	tt.render.sprites[10 + i].scale = dust_scales[i]
	tt.render.sprites[10 + i].offset = dust_offset[i]
end

tt.main_script.update = decal_hero_builder_ultimate_ball_update
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {fts(20), 0}}

for i = 2, 16 do
	tt.tween.props[i] = table.deepclone(tt.tween.props[1])
	tt.tween.props[i].sprite_id = i
end

tt.duration = 2.5
tt = RT("arrow_hero_builder_defensive_turret", "arrow")
tt.render.sprites[1].name = "hero_obdul_skill_4_tower_projectile"
tt.bullet.miss_decal = nil
tt.bullet.flight_time_variance = 3
tt.bullet.flight_time = fts(15)
tt.bullet.hide_radius = 1
tt.bullet.g = -2 / (fts(1) * fts(1))
tt.bullet.align_with_trajectory = false
tt.bullet.rotation_speed = 30 * FPS * math.pi / 180
tt.bullet.mod = "mod_hero_builder_defensive_turret_stun"
tt = RT("mod_hero_builder_defensive_turret_stun", "mod_stun")
tt.modifier.duration = 0.25
tt = RT("aura_hero_builder_demolition_man", "aura")
tt.aura.duration = nil
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.track_source = true
tt.aura.cycle_time = 0.25
tt.aura.radius = 100
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.vis_flags = F_RANGED
tt.main_script.update = scripts.aura_apply_damage.update
tt.aura.mods = {"mod_hero_builder_demolition_man_hit_fx", "mod_hero_builder_demolition_man_stun"}
tt = RT("aura_hero_builder_ultimate", "aura")
tt.aura.cycles = 1
tt.aura.cycle_time = 0.3
tt.aura.damage_type = DAMAGE_AGAINST_ARMOR
tt.aura.track_source = nil
tt.aura.radius = 80
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.vis_flags = F_RANGED
tt.aura.mod = "mod_hero_builder_ultimate_stun"
tt.main_script.update = scripts.aura_apply_damage.update
tt = RT("mod_hero_builder_lunch_break", "modifier")
tt.main_script.insert = mod_hero_builder_lunch_break_insert
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.bans = {}
tt.modifier.duration = 1
tt = RT("mod_hero_builder_ultimate_stun", "mod_stun")
tt.modifier.duration = nil
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt = RT("mod_hero_builder_demolition_man_hit_fx", "modifier")

AC(tt, "render")

tt.render.sprites[1].name = "hero_obdul_skill_3_hit"
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = fts(7)
tt = RT("mod_hero_builder_demolition_man_stun", "mod_stun")
tt.modifier.duration = E:get_template("mod_hero_builder_demolition_man_hit_fx").modifier.duration
tt = RT("controller_hero_builder_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.entity = "decal_hero_builder_ultimate_projectile"
tt.main_script.update = hero_builder_ultimate_update
tt.sound = "HeroBuilderWreckingBall"
