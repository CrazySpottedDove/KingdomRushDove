local scripts = require("scripts")
local E = require("entity_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local bit = require("bit")
local HU = require("hero_utils")
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

local function hero_raelyn_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "unbreakable", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local m = E:get_template(a.mod)

		m.modifier.duration = s.duration[s.level]
		m.shield_per_enemy = s.shield_per_enemy[s.level]
		m.shield_base = s.shield_base[s.level]
	end)
	upgrade_skill(this, "inspire_fear", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.damage = s.damage[s.level]

		local md = E:get_template(a.mods[1])

		md.modifier.duration = s.damage_duration[s.level]
		md.inflicted_damage_factor = s.inflicted_damage_factor[s.level]

		local ms = E:get_template(a.mods[2])

		ms.modifier.duration = s.stun_duration[s.level]

		local mf = E:get_template(a.mods[3])

		mf.modifier.duration = s.stun_duration[s.level]
	end)
	upgrade_skill(this, "brutal_slash", function(this, s)
		local a = this.melee.attacks[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.damage_max = s.damage_max[s.level]
		a.damage_min = s.damage_min[s.level]
	end)
	upgrade_skill(this, "onslaught", function(this, s)
		local a = this.melee.attacks[1]
		local o = this.timed_attacks.list[3]
		local hit_aura = E:get_template(s.hit_aura)

		hit_aura.aura.damage_max = a.damage_max * s.damage_factor[s.level]
		hit_aura.aura.damage_min = a.damage_min * s.damage_factor[s.level]
		o.melee_cooldown = s.melee_cooldown[s.level]
		o.duration = s.duration[s.level]
		o.cooldown = s.cooldown[s.level]
		o.disabled = nil
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		local uc = E:get_template(s.controller_name)

		uc.entity = string.format("%s_%i", uc.entity_prefix, s.level)
		this.ultimate.cooldown = s.cooldown[s.level]
		this.ultimate.disabled = nil
	end)

	if this.hero.skills.onslaught.level > 0 then
		local s = this.hero.skills.onslaught
		local a = this.melee.attacks[1]
		local hit_aura = E:get_template(s.hit_aura)

		hit_aura.aura.damage_max = a.damage_max * s.damage_factor[s.level]
		hit_aura.aura.damage_min = a.damage_min * s.damage_factor[s.level]
	end

	update_hp(this)

	this.hero.melee_active_status = {}

	for index, attack in ipairs(this.melee.attacks) do
		this.hero.melee_active_status[index] = attack.disabled
	end
end

local function hero_raelyn_insert(this, store)
	this.hero.fn_level_up(this, store)

	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

local function hero_raelyn_update(this, store)
	local h = this.health
	local a, skill, brk, sta
	local basic_attack = this.melee.attacks[1]
	local unbreakable_attack = this.timed_attacks.list[1]
	local inspire_fear_attack = this.timed_attacks.list[2]
	local onslaught_attack = this.timed_attacks.list[3]

	onslaught_attack.duration_ts = 0

	local onslaught_on = false

	this.health_bar.hidden = false

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				local dx = math.abs(this.nav_rally.pos.x - this.pos.x)

				if dx > 125 and dx < 300 then
					S:queue(this.sound_events.change_rally_point)
					U.unblock_target(store, this)

					this.nav_rally.new = false

					U.animation_start(this, "brutal_slash", this.pos.x > this.nav_rally.pos.x, store.tick_ts, false, 1)

					local jump_rate = (this.render.sprites[1].fps or FPS) / FPS
					local start_time = fts(8) / jump_rate
					local flight_time = fts(18) / jump_rate - start_time

					U.y_wait_unconditional(store, start_time)

					local expected_stop_time = store.tick_ts + flight_time
					local last_ts = store.tick_ts
					local this_pos = this.pos
					local g = -2 * V.dist(this.nav_rally.pos.x, this.nav_rally.pos.y, this.pos.x, this.pos.y) / (flight_time * flight_time)
					local v_x = (this.nav_rally.pos.x - this.pos.x) / flight_time
					local v_y = ((this.nav_rally.pos.y - this.pos.y) - 0.5 * g * flight_time * flight_time) / flight_time

					while store.tick_ts <= expected_stop_time do
						coroutine.yield()

						local dt = store.tick_ts - last_ts

						this_pos.x = this_pos.x + v_x * dt
						this_pos.y = this_pos.y + v_y * dt
						v_y = v_y + g * dt
						last_ts = store.tick_ts
					end

					U.y_animation_wait_default(this)

					this.nav_grid.waypoints = {}
				else
					if SU.y_hero_new_rally(store, this) then
						goto label_222_0
					end
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local target = find_target_at_critical_moment(this, 140, F_RANGED, F_FLYING, nil, false, true)

				if target and U.has_valid_rally_node_nearby(target.pos) then
					local start_ts = store.tick_ts

					U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
					S:queue(this.sound_events.change_rally_point)

					local e = E:create_entity(this.hero.skills.ultimate.controller_name)

					e.pos.x, e.pos.y = target.pos.x, target.pos.y
					e.damage_factor = this.unit.damage_factor
					e.level = this.hero.skills.ultimate.level

					simulation:queue_insert_entity(e)

					this.ultimate.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)

					onslaught_attack.duration_ts = onslaught_attack.duration_ts + store.tick_ts - start_ts
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			skill = this.hero.skills.inspire_fear
			a = inspire_fear_attack

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local enemies = U.find_enemies_in_range_filter_off(this.pos, a.max_range_trigger, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < a.min_targets then
					a.ts = a.ts + fts(10)
				else
					local start_ts = store.tick_ts

					S:queue(a.sound)

					if a.mod_decal then
						local d = E:create_entity(a.mod_decal)

						d.modifier.source_id = this.id
						d.modifier.target_id = this.id

						simulation:queue_insert_entity(d)
					end

					U.animation_start_default(this, a.animation, nil, store.tick_ts, false)

					if SU.y_soldier_wait(store, this, a.cast_time) then
					-- block empty
					else
						a.ts = start_ts

						SU.hero_gain_xp_from_skill(this, skill)

						enemies = U.find_enemies_in_range_filter_off(this.pos, a.max_range_effect, a.vis_flags, a.vis_bans)

						if enemies then
							for _, t in ipairs(enemies) do
								for _, mod in ipairs(a.mods) do
									local m = E:create_entity(mod)

									m.modifier.source_id = this.id
									m.modifier.target_id = t.id

									simulation:queue_insert_entity(m)
								end

								local d = E.assign_damage(a.damage_type, a.damage, this.id, t.id)

								queue_damage(store, d)
							end
						end

						SU.y_hero_animation_wait(this)

						onslaught_attack.duration_ts = onslaught_attack.duration_ts + store.tick_ts - start_ts
					end

					goto label_222_0
				end
			end

			skill = this.hero.skills.unbreakable
			a = unbreakable_attack

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) and not U.has_modifiers(store, this, a.mod) then
				local enemies = U.find_enemies_in_range_filter_off(this.pos, a.max_range_trigger, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < a.min_targets then
					a.ts = a.ts + fts(10)
				else
					local start_ts = store.tick_ts

					S:queue(a.sound)
					U.animation_start_default(this, a.animation, nil, store.tick_ts, false)

					if SU.y_soldier_wait(store, this, a.cast_time) then
					-- block empty
					else
						local d = E:create_entity(a.mod_decal)

						d.modifier.source_id = this.id
						d.modifier.target_id = this.id

						simulation:queue_insert_entity(d)

						a.ts = start_ts

						SU.hero_gain_xp_from_skill(this, skill)

						enemies = U.find_enemies_in_range_filter_off(this.pos, a.max_range_effect, a.vis_flags, a.vis_bans)

						local count

						if enemies then
							count = #enemies > a.max_targets and a.max_targets or #enemies
						else
							count = 0
						end

						local function apply_unbreakable(target, is_soldier)
							local m = E:create_entity(a.mod)
							local shield_max_damage = m.shield_base * target.health.hp_max

							shield_max_damage = shield_max_damage + target.health.hp_max * m.shield_per_enemy * count

							if is_soldier then
								shield_max_damage = shield_max_damage * skill.soldier_factor
								m.render.sprites[1].scale = v(0.71, 0.71)

								U.change_health_bar_offset_run_time(m.health_bar, m.health_bar.offset.y * 0.71)
							end

							m.modifier.source_id = this.id
							m.modifier.target_id = target.id
							m.shield_max_damage = shield_max_damage

							local mod_prefix

							if count <= #m.sprites_per_enemies then
								mod_prefix = m.sprites_per_enemies[count]
							else
								mod_prefix = m.sprites_per_enemies[#m.sprites_per_enemies]
							end

							m.render.sprites[1].prefix = mod_prefix

							simulation:queue_insert_entity(m)
						end

						apply_unbreakable(this, false)

						local soldiers = U.find_soldiers_in_range(store.soldiers, this.pos, 0, a.max_range_effect, a.vis_flags, a.vis_bans)

						if soldiers then
							for index, soldier in ipairs(soldiers) do
								if soldier.id ~= this.id and not U.has_modifiers(store, soldier, a.mod) then
									if index >= a.max_targets then
										break
									end

									if soldier.hero then
										apply_unbreakable(soldier, false)
									else
										apply_unbreakable(soldier, true)
									end
								end
							end
						end

						SU.y_hero_animation_wait(this)

						onslaught_attack.duration_ts = onslaught_attack.duration_ts + store.tick_ts - start_ts
					end

					goto label_222_0
				end
			end

			skill = this.hero.skills.onslaught
			a = onslaught_attack

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) and not onslaught_on then
				local enemies = U.find_enemies_in_range_filter_off(this.pos, a.max_range_trigger, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < a.min_targets then
					a.ts = a.ts + fts(10)
				else
					onslaught_on = true
					a.duration_ts = store.tick_ts
					a._sound = basic_attack.sound
					a._cooldown = basic_attack.cooldown
					a._hit_fx = basic_attack.hit_fx
					a._hit_offset = basic_attack.hit_offset
					basic_attack.hit_aura = a.hit_aura
					basic_attack.cooldown = a.melee_cooldown
					basic_attack.hit_decal = a.hit_decal
					basic_attack.hit_fx = nil
					basic_attack.hit_offset = a.hit_offset
					basic_attack.sound = a.sound

					U.speed_inc(this, this.motion.max_speed * skill.speed_inc_factor)

					this.melee.attacks[2].hit_aura = a.hit_aura

					SU.insert_unit_cooldown_buff(store.tick_ts, this, skill.cooldown_factor)
				end
			end

			if onslaught_on and store.tick_ts - a.duration_ts > a.duration then
				onslaught_on = false
				this.melee.attacks[2].hit_aura = nil
				basic_attack.hit_aura = nil
				basic_attack.cooldown = a._cooldown
				basic_attack.hit_decal = nil
				basic_attack.hit_fx = a._hit_fx
				basic_attack.hit_offset = a._hit_offset
				basic_attack.sound = a._sound
				a.ts = store.tick_ts

				U.speed_dec(this, this.motion.max_speed * skill.speed_inc_factor)
				SU.remove_unit_cooldown_buff(store.tick_ts, this, skill.cooldown_factor)
			end

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

		::label_222_0::

		coroutine.yield()
	end
end

local function hero_raelyn_ultimate_update(this, store)
	local x, y = this.pos.x, this.pos.y
	local e = E:create_entity(this.entity)

	e.pos.x = x
	e.pos.y = y
	e.nav_rally.center = V.v(x, y)
	e.nav_rally.pos = V.vclone(e.pos)

	simulation:queue_insert_entity(e)

	local d = E:create_entity(e.spawn_mod_decal)

	d.modifier.source_id = e.id
	d.modifier.target_id = e.id

	simulation:queue_insert_entity(d)
	simulation:queue_remove_entity(this)
end

tt = RT("hero_raelyn", "hero")

AC(tt, "melee", "timed_attacks")

tt.hero.level_stats.armor = {0.43, 0.46, 0.49, 0.52, 0.55, 0.58, 0.61, 0.64, 0.67, 0.7}
tt.hero.level_stats.hp_max = {286, 312, 338, 364, 390, 416, 442, 468, 494, 520}
tt.hero.level_stats.melee_damage_max = {20, 24, 26, 30, 34, 36, 39, 44, 48, 50}
tt.hero.level_stats.melee_damage_min = {14, 15, 17, 19, 22, 25, 26, 29, 30, 34}
tt.hero.skills.unbreakable = CC("hero_skill")
tt.hero.skills.unbreakable.cooldown = {25, 25, 25}
tt.hero.skills.unbreakable.duration = {6, 6, 6}
tt.hero.skills.unbreakable.shield_base = {0.2, 0.2, 0.2}
tt.hero.skills.unbreakable.shield_per_enemy = {0.1, 0.15, 0.2}
tt.hero.skills.unbreakable.soldier_factor = 0.6
tt.hero.skills.unbreakable.xp_gain = {280, 560, 840}
tt.hero.skills.unbreakable.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.inspire_fear = CC("hero_skill")
tt.hero.skills.inspire_fear.cooldown = {21, 21, 21}
tt.hero.skills.inspire_fear.damage_duration = {6, 6, 6}
tt.hero.skills.inspire_fear.stun_duration = {2, 2.5, 3}
tt.hero.skills.inspire_fear.slow_factor = nil
tt.hero.skills.inspire_fear.inflicted_damage_factor = {0.6, 0.4, 0.2}
tt.hero.skills.inspire_fear.xp_gain = {240, 480, 720}
tt.hero.skills.inspire_fear.damage = {45, 60, 75}
tt.hero.skills.inspire_fear.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.brutal_slash = CC("hero_skill")
tt.hero.skills.brutal_slash.cooldown = {20, 19, 18}
tt.hero.skills.brutal_slash.damage_max = {180, 360, 540}
tt.hero.skills.brutal_slash.damage_min = {180, 360, 540}
tt.hero.skills.brutal_slash.xp_gain = {240, 480, 720}
tt.hero.skills.brutal_slash.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.onslaught = CC("hero_skill")
tt.hero.skills.onslaught.damage_factor = {0.6, 0.8, 1}
tt.hero.skills.onslaught.melee_cooldown = {1, 1, 1}
tt.hero.skills.onslaught.duration = {6, 8, 10}
tt.hero.skills.onslaught.cooldown = {24, 20, 18}
tt.hero.skills.onslaught.hit_aura = "hero_raelyn_onslaught_aura"
tt.hero.skills.onslaught.speed_inc_factor = 0.4
tt.hero.skills.onslaught.cooldown_factor = 0.8
tt.hero.skills.onslaught.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_raelyn_ultimate"
tt.hero.skills.ultimate.cooldown = {48, 48, 48, 48}
tt.hero.skills.ultimate.xp_gain_factor = 48
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 40)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_raelyn_level_up
tt.info.hero_portrait = "kr5_hero_portraits_0002"
tt.info.portrait = "kr5_info_portraits_heroes_0002"
tt.main_script.insert = hero_raelyn_insert
tt.main_script.update = hero_raelyn_update
tt.motion.max_speed = 60
tt.regen.cooldown = 1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_raelyn_hero"
tt.render.sprites[1].draw_order = DO_HEROES
tt.soldier.melee_slot_offset = vec_2(10, 0)
tt.sound_events.change_rally_point = "HeroRaelynTaunt"
tt.sound_events.death = "HeroRaelynDeath"
tt.sound_events.respawn = "HeroRaelynTauntIntro"
tt.sound_events.hero_room_select = "HeroRaelynTauntSelect"
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.mod_offset = vec_2(0, 13)
tt.melee.range = 72
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animation = "melee_attack"
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].hit_fx = "hero_raelyn_melee_attack_hit"
tt.melee.attacks[1].hit_offset = vec_2(35, 15)
tt.melee.attacks[1].sound = "HeroRaelynBasicAttack"
tt.melee.attacks[1].xp_gain_factor = 2.6
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].damage_max = nil
tt.melee.attacks[2].damage_min = nil
tt.melee.attacks[2].hit_time = fts(18) --49 f
tt.melee.attacks[2].sound = "HeroRaelynBrutalSlashCast"
tt.melee.attacks[2].animation = "brutal_slash"
tt.melee.attacks[2].damage_type = bor(DAMAGE_TRUE, DAMAGE_FX_EXPLODE)
tt.melee.attacks[2].xp_gain_factor = nil
tt.melee.attacks[2].xp_from_skill = "brutal_slash"
tt.melee.attacks[2].pop = {"pop_whaam", "pop_kapow"}
tt.melee.attacks[2].pop_chance = 0.3
tt.melee.attacks[2].hit_decal = "hero_raelyn_brutal_slash_decal"
tt.melee.attacks[2].hit_offset = vec_2(35, 0)
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "unbreakable"
tt.timed_attacks.list[1].max_range_trigger = 72
tt.timed_attacks.list[1].max_range_effect = 140
tt.timed_attacks.list[1].min_targets = 1
tt.timed_attacks.list[1].max_targets = 4
tt.timed_attacks.list[1].mod = "hero_raelyn_unbreakable_mod"
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].cast_time = fts(8)
tt.timed_attacks.list[1].xp_from_skill = "unbreakable"
tt.timed_attacks.list[1].sound = "HeroRaelynUnbreakableCast"
tt.timed_attacks.list[1].mod_decal = "hero_raelyn_unbreakable_floor_decal_mod"
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].animation = "inspire_fear"
tt.timed_attacks.list[2].cast_time = fts(13)
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING, F_FRIEND)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[2].max_range_trigger = 72
tt.timed_attacks.list[2].min_range_trigger = 0
tt.timed_attacks.list[2].max_range_effect = 120
tt.timed_attacks.list[2].min_range_effect = 0
tt.timed_attacks.list[2].min_targets = 1
tt.timed_attacks.list[2].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[2].damage = 45
tt.timed_attacks.list[2].mods = {"hero_raelyn_inspire_fear_damage_mod", "hero_raelyn_inspire_fear_stun_mod", "hero_raelyn_inspire_fear_fx_mod"}
tt.timed_attacks.list[2].sound = "HeroRaelynInspireFearCast"
tt.timed_attacks.list[2].xp_from_skill = "inspire_fear"
tt.timed_attacks.list[2].mod_decal = "hero_raelyn_inspire_fear_floor_decal_mod"
tt.timed_attacks.list[3] = CC("custom_attack")
tt.timed_attacks.list[3].max_range_trigger = 150
tt.timed_attacks.list[3].min_targets = 2
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[3].hit_decal = "decal_hero_raelyn_onslaught_decal"
tt.timed_attacks.list[3].hit_offset = vec_2(35, 0)
tt.timed_attacks.list[3].hit_aura = "hero_raelyn_onslaught_aura"
tt.timed_attacks.list[3].sound = "HeroRaelynOnslaughtCast"
tt.ui.click_rect = r(-20, -5, 40, 43)
tt.ultimate = {
	ts = 0,
	cooldown = 48,
	disabled = true
}
tt = RT("hero_raelyn_melee_attack_hit", "fx")
tt.render.sprites[1].name = "hero_raelyn_melee_attack_hit"
tt = RT("hero_raelyn_brutal_slash_decal", "decal_tween")
tt.render.sprites[1].name = "hero_raelyn_brutal_slash_decal"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}
tt = RT("hero_raelyn_unbreakable_floor_decal_mod", "modifier")

AC(tt, "render")

tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].name = "hero_raelyn_unbreakable_fx_idle"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hide_after_runs = 1
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_raelyn_unbreakable_shield_floor_glow"
tt.render.sprites[2].hidden = false
tt.modifier.use_mod_offset = false
tt.modifier.duration = fts(17)
tt = RT("hero_raelyn_unbreakable_mod", "modifier")

AC(tt, "render", "health_bar", "health")

tt.modifier.vis_flags = bor(F_MOD)
tt.modifier.use_mod_offset = false
tt.damage_taken = 0
tt.main_script.insert = scripts.mod_shield.insert
tt.main_script.remove = scripts.mod_shield.remove
tt.main_script.update = scripts.mod_shield.update
tt.health_bar.offset = vec_2(0, 42)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.colors = {}
tt.health_bar.colors.fg = {255, 255, 0, 255}
tt.health_bar.colors.bg = {0, 0, 0, 255}
tt.health_bar.sort_y_offset = -2
tt.health_bar.disable_fade = true
tt.sprites_per_enemies = {"hero_raelyn_unbreakable_shield_lvl1", "hero_raelyn_unbreakable_shield_lvl1", "hero_raelyn_unbreakable_shield_lvl1"}
tt.animation_start = "start"
tt.animation_loop = "idle"
tt.animation_end = "end"
tt.render.sprites[1].prefix = "hero_raelyn_unbreakable_shield_lvl1"
tt.render.sprites[1].name = "idle"
tt = RT("hero_raelyn_inspire_fear_floor_decal_mod", "modifier")

AC(tt, "render")

tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].name = "hero_raelyn_inspire_fear_fx_area_idle"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].hide_after_runs = 1
tt.modifier.use_mod_offset = false
tt.modifier.duration = fts(28)
tt = RT("hero_raelyn_inspire_fear_damage_mod", "modifier")

AC(tt, "render")

tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.remove = scripts.mod_damage_factors.remove
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].name = "hero_raelyn_inspire_fear_decal"
tt.render.sprites[1].draw_order = 20
tt.modifier.use_mod_offset = false
tt = RT("hero_raelyn_inspire_fear_stun_mod", "mod_stun")
tt.modifier.duration = nil
tt.render.sprites[1].hidden = true
tt = RT("hero_raelyn_inspire_fear_fx_mod", "modifier")
tt.main_script.update = scripts.mod_track_target.update
tt = RT("hero_raelyn_onslaught_aura", "aura")
tt.aura.duration = fts(11)
tt.aura.cycle_time = fts(11)
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.radius = 75
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.vis_flags = bor(F_RANGED)
tt.main_script.update = scripts.aura_apply_damage.update
tt = RT("hero_raelyn_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.entity_prefix = "hero_raelyn_ultimate_entity"
tt.main_script.update = hero_raelyn_ultimate_update
tt.sound_events.insert = "HeroRaelynUltimateCast"
tt = RT("decal_hero_raelyn_onslaught_decal", "decal_tween")
tt.render.sprites[1].name = "hero_raelyn_onslaught_fx_idle"
tt.render.sprites[1].hide_after_runs = 1
tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}
