local bit = require("bit")
local E = require("entity_db")
local GR = require("grid_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local scripts = require("scripts")
local log = require("lib.klua.log"):new("hero_crab")

require("lib.klua.table")
require("all.constants")

local band = bit.band
local bor = bit.bor
local v = V.v
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "battlehardened", function(this, s)
		this.invuln.disabled = nil
		this.invuln.chance = s.chance[s.level]
	end)
	upgrade_skill(this, "pincerattack", function(this, s)
		local pa = this.timed_attacks.list[1]

		pa.disabled = nil
		pa.damage_min = s.damage_min[s.level]
		pa.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "shouldercannon", function(this, s)
		local a = this.ranged.attacks[1]

		a.disabled = nil

		local b = E:get_template("crab_water_bomb")

		b.bullet.damage_max = s.damage[s.level]
		b.bullet.damage_min = s.damage[s.level]
		b.bullet.damage_radius = s.radius_inc[s.level] + b.bullet.damage_radius
		b.render.sprites[1].scale.x = b.bullet.damage_radius / 65
		b.render.sprites[1].scale.y = b.render.sprites[1].scale.x

		local aura = E:get_template("aura_slow_water_bomb")

		aura.aura.radius = aura.aura.radius + s.radius_inc[s.level]

		local m = E:get_template("mod_slow_water_bomb")

		m.modifier.duration = s.slow_duration[s.level]
		m.slow.factor = s.slow_factor[s.level]
	end)
	upgrade_skill(this, "burrow", function(this, s)
		this.burrow.disabled = nil
		this.burrow.extra_speed = s.extra_speed[s.level]
		this.nav_grid.valid_terrains = bor(TERRAIN_LAND, TERRAIN_WATER, TERRAIN_SHALLOW, TERRAIN_ICE)
		this.burrow.damage = s.damage[s.level]
	end)
	update_hp(this)
end

local function hero_on_damage(this, store, damage)
	log.paranoid("  CRAB DAMAGE: %s", damage.value)

	local h = this.health
	local i = this.invuln

	if (i.active or i.pending) and band(damage.damage_type, i.exclude_damage_types) == 0 then
		U.heal(this, damage.value * 0.5)

		return false
	end

	if i.disabled or this.unit.is_stunned or store.tick_ts - i.ts < i.cooldown or math.random() > i.chance then
		return true
	end

	local predicted_damage = U.predict_damage(this, damage)

	if h.hp - predicted_damage < i.trigger_factor * h.hp_max then
		i.pending = true

		return false
	end

	return true
end

local function hero_update(this, store)
	local h = this.health
	local a, skill, brk, sta

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				local b = this.burrow
				local r = this.nav_rally

				if not b.disabled and V.dist(this.pos.x, this.pos.y, r.pos.x, r.pos.y) > b.min_distance then
					r.new = false

					U.unblock_target(store, this)
					U.bans_add(this.vis, F_ALL)

					this.health.immune_to = F_ALL

					local original_speed = this.motion.max_speed

					U.speed_inc_self(this, b.init_accel)

					this.unit.marker_hidden = true

					S:queue(this.sound_events.change_rally_point)
					S:queue(this.sound_events.burrow_in)
					U.y_animation_play(this, "burrow_in", r.pos.x < this.pos.x, store.tick_ts)

					this.health_bar._orig_offset_y = this.health_bar.offset.y

					U.change_health_bar_offset_run_time(this.health_bar, b.health_bar_offset.y)

					this.unit._orig_hit_offset = this.unit.hit_offset
					this.unit.hit_offset = b.hit_offset
					this.unit._orig_mod_offset = this.unit.mod_offset
					this.unit.mod_offset = b.mod_offset

					local water_trail = E:create_entity("ps_water_trail")

					water_trail.particle_system.track_id = this.id
					water_trail.particle_system.emit = false
					water_trail.particle_system.z = Z_OBJECTS - 1

					simulation:queue_insert_entity(water_trail)

					::label_400_0::

					local last_t = band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_TYPES_MASK)
					local dest = r.pos
					local n = this.nav_grid

					while not V.veq(this.pos, dest) do
						local w = table.remove(n.waypoints, 1) or dest

						U.set_destination(this, w)

						local ani = last_t == TERRAIN_WATER and "burrow_water" or "burrow_land"
						local an, af = U.animation_name_facing_point(this, ani, this.motion.dest)

						U.animation_start_default(this, an, af, store.tick_ts, true)

						while not this.motion.arrived do
							if r.new then
								r.new = false

								goto label_400_0
							end

							U.walk(this, store.tick_length, b.extra_speed)
							coroutine.yield()

							this.motion.speed.x, this.motion.speed.y = 0, 0

							local t = band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_TYPES_MASK)

							if t ~= last_t then
								if last_t and bor(last_t, t) == bor(TERRAIN_WATER, TERRAIN_LAND) then
									local fx = E:create_entity("fx_enemy_splash")

									fx.render.sprites[1].name = "big"
									fx.render.sprites[1].ts = store.tick_ts
									fx.render.sprites[1].sort_y_offset = 0

									fx.pos:copy(this.pos)
									simulation:queue_insert_entity(fx)

									if this.sound_events and this.sound_events.water_splash then
										S:queue(this.sound_events.water_splash)
									end
								end

								local in_water = t == TERRAIN_WATER
								local ani = in_water and "burrow_water" or "burrow_land"
								local an, af = U.animation_name_facing_point(this, ani, this.motion.dest)

								U.animation_start_default(this, an, af, store.tick_ts, true)

								water_trail.particle_system.emit = in_water
								last_t = t
							end
						end
					end

					if this.motion.real_speed >= b.stun_speed and store.tick_ts - b.ts >= b.cooldown then
						local enemies = U.find_enemies_in_range_filter_off(this.pos, b.radius, F_STUN, bor(F_BOSS, F_FLYING))

						if enemies then
							local rate = (this.motion.real_speed - 60) / (b.stun_speed - 60)

							for _, e in ipairs(enemies) do
								if not e.health.dead then
									local mod = E:create_entity("mod_stun_burrow")

									mod.modifier.target_id = e.id
									mod.modifier.source_id = this.id

									simulation:queue_insert_entity(mod)

									local d = E.assign_damage(DAMAGE_EXPLOSION, (b.damage + this.unit.damage_buff) * this.unit.damage_factor * rate, this.id, e.id)

									queue_damage(store, d)
								end
							end

							SU.hero_gain_xp_from_skill(this, this.hero.skills.burrow)

							b.ts = store.tick_ts
						end

						for i, pos in pairs({v(10, -16), v(-12, -14), v(22, -1), v(-24, -1)}) do
							local fx = E:create_entity("fx")

							fx.render.sprites[1].name = "fx_hero_crab_quake"
							fx.render.sprites[1].ts = store.tick_ts + (i - 1) * 0.1
							fx.render.sprites[1].scale = v(0.8, 0.8)
							fx.render.sprites[1].alpha = 166
							fx.render.sprites[1].anchor.y = 0.24
							fx.pos.x, fx.pos.y = this.pos.x + pos.x, this.pos.y + pos.y

							simulation:queue_insert_entity(fx)
						end
					end

					U.change_health_bar_offset_run_time(this.health_bar, this.health_bar._orig_offset_y)

					this.unit.hit_offset = this.unit._orig_hit_offset
					this.unit.mod_offset = this.unit._orig_mod_offset

					S:queue(this.sound_events.burrow_out)
					U.y_animation_play(this, "burrow_out", r.pos.x < this.pos.x, store.tick_ts)
					U.update_max_speed(this, original_speed)
					U.bans_remove(this.vis, F_ALL)

					this.health.immune_to = 0
					this.unit.marker_hidden = nil
				elseif SU.y_hero_new_rally(store, this) then
					goto label_400_2
				end
			end

			if this.invuln and this.invuln.pending then
				local e = E:create_entity(this.invuln.aura_name)

				e.aura.ts = store.tick_ts
				e.aura.source_id = this.id

				simulation:queue_insert_entity(e)

				local skill = this.hero.skills.battlehardened

				SU.hero_gain_xp_from_skill(this, skill)
				S:queue(this.invuln.sound)
				U.y_animation_play(this, this.invuln.animation, nil, store.tick_ts)

				this.invuln.ts = store.tick_ts
				this.invuln.pending = nil
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.pincerattack

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local left_targets, right_targets = {}, {}
				local targets = U.find_enemies_between_range_filter_on(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, function(v)
					local px, py = this.pos.x, this.pos.y
					local vx, vy = v.pos.x, v.pos.y
					local rx, ry = a.damage_size.x, a.damage_size.y

					if vy >= py - ry * 0.5 and vy < py + ry * 0.5 then
						if px < vx and vx < px + rx then
							table.insert(right_targets, v)

							return true
						elseif vx < px and vx > px - rx then
							table.insert(left_targets, v)

							return true
						end
					end

					return false
				end)

				if not targets or #left_targets < a.min_count and #right_targets < a.min_count then
					a.ts = a.ts + 0.13333333333333333

					goto label_400_1
				end

				if #left_targets > #right_targets then
					targets = left_targets
				else
					targets = right_targets
				end

				local start_ts = store.tick_ts

				S:queue(a.sound)

				local an, af = U.animation_name_facing_point(this, a.animation, targets[1].pos)

				U.animation_start_default(this, an, af, store.tick_ts, false)

				local flip_x = this.render.sprites[1].flip_x

				while store.tick_ts - start_ts < a.hit_time do
					if SU.hero_interrupted(this) then
						goto label_400_2
					end

					coroutine.yield()
				end

				a.ts = start_ts

				SU.hero_gain_xp_from_skill(this, skill)

				targets = U.find_enemies_between_range_filter_on(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, function(v)
					local px, py = this.pos.x, this.pos.y
					local vx, vy = v.pos.x, v.pos.y
					local rx, ry = a.damage_size.x, a.damage_size.y

					if vy >= py - ry * 0.5 and vy < py + ry * 0.5 then
						if px < vx and vx < px + rx then
							table.insert(right_targets, v)

							return true
						elseif vx < px and vx > px - rx then
							table.insert(left_targets, v)

							return true
						end
					end

					return false
				end)

				if targets then
					for _, t in ipairs(targets) do
						local d = E.assign_damage(a.damage_type, math.random(a.damage_min, a.damage_max), this.id, t.id)

						queue_damage(store, d)
					end
				end

				while not U.animation_finished_default(this) do
					if SU.hero_interrupted(this) then
						goto label_400_2
					end

					coroutine.yield()
				end

				goto label_400_2

				this.render.sprites[1].flip_x = flip_x
			end

			::label_400_1::

			brk, sta = SU.y_soldier_ranged_attacks(store, this)

			if brk then
			-- block empty
			else
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
		end

		::label_400_2::

		coroutine.yield()
	end
end

local function aura_crab_invuln_update(this, store)
	local hero = store.entities[this.aura.source_id]

	this.pos = hero.pos

	local a = this.aura

	U.bans_add(hero.vis, F_STUN)

	hero.invuln.active = true
	-- hero.health.immune_to = F_ALL
	this.tween.ts = store.tick_ts

	U.y_wait_unconditional(store, fts(20))

	this.tween.props[3].disabled = true
	this.tween.props[4].disabled = nil

	while not this.interrupt and not hero.health.dead and not hero.nav_rally.new and store.tick_ts - a.ts < a.duration do
		coroutine.yield()
	end

	U.bans_remove(hero.vis, F_STUN)

	-- hero.health.immune_to = 0
	hero.invuln.active = false
	this.tween.ts = store.tick_ts - a.duration
	this.tween.props[4].disabled = true

	U.y_wait_unconditional(store, fts(15))
	simulation:queue_remove_entity(this)
end

local tt

tt = RT("hero_crab", "hero")

AC(tt, "water", "melee", "ranged", "timed_attacks")

tt.hero.level_stats.hp_max = {320, 340, 360, 380, 400, 420, 440, 460, 480, 500}
tt.hero.level_stats.armor = {0.17, 0.19, 0.21, 0.23, 0.25, 0.27, 0.29, 0.31, 0.33, 0.35}
tt.hero.level_stats.melee_damage_min = {15, 16, 17, 25, 25, 26, 34, 35, 36, 44}
tt.hero.level_stats.melee_damage_max = {30, 33, 36, 46, 48, 51, 61, 63, 65, 74}
tt.hero.skills.battlehardened = CC("hero_skill")
tt.hero.skills.battlehardened.chance = {0.35, 0.5, 0.65}
tt.hero.skills.battlehardened.xp_gain_factor = 120
tt.hero.skills.battlehardened.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.pincerattack = CC("hero_skill")
tt.hero.skills.pincerattack.damage_min = {34, 61, 88}
tt.hero.skills.pincerattack.damage_max = {54, 101, 148}
tt.hero.skills.pincerattack.xp_gain_factor = 96
tt.hero.skills.pincerattack.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.shouldercannon = CC("hero_skill")
tt.hero.skills.shouldercannon.damage = {40, 60, 80}
tt.hero.skills.shouldercannon.slow_factor = {0.6, 0.55, 0.5}
tt.hero.skills.shouldercannon.slow_duration = {4, 5, 6}
tt.hero.skills.shouldercannon.radius_inc = {5, 5, 5}
tt.hero.skills.shouldercannon.xp_gain_factor = 36
tt.hero.skills.shouldercannon.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.burrow = CC("hero_skill")
tt.hero.skills.burrow.extra_speed = {22, 28, 35, 41}
tt.hero.skills.burrow.damage = {32, 48, 64, 80}
tt.hero.skills.burrow.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.burrow.xp_gain_factor = 50
tt.health.armor = nil
tt.health.dead_lifetime = 15
tt.health.hp_max = nil
tt.health.on_damage = hero_on_damage
tt.health_bar.offset = vec_2(0, 60)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(66)
tt.info.hero_portrait = "kr2_hero_portraits_0011"
tt.info.portrait = "kr2_info_portraits_heroes_0011"
tt.main_script.update = hero_update
tt.motion.max_speed = 60
tt.motion.speed_limit = 260
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.26785714285714285
tt.render.sprites[1].prefix = "hero_crab"
tt.render.sprites[1].angles.walk = {"running"}
tt.render.sprites[1].angles.burrow_land = {"burrow_side", "burrow_up", "burrow_down"}
tt.render.sprites[1].angles.burrow_water = {"burrow_side_water", "burrow_up_water", "burrow_down_water"}
tt.soldier.melee_slot_offset.x = 20
tt.sound_events.change_rally_point = "HeroCrabTaunt"
tt.sound_events.death = "HeroCrabDeath"
tt.sound_events.respawn = "HeroCrabTauntIntro"
tt.sound_events.insert = "HeroCrabTauntIntro"
tt.sound_events.hero_room_select = "HeroCrabTauntSelect"
tt.sound_events.water_splash = "SpecialMermaid"
tt.sound_events.burrow_in = "HeroCrabBurrowIn"
tt.sound_events.burrow_out = "HeroCrabBurrowOut"
tt.unit.hit_offset = vec_2(0, 17)
tt.unit.mod_offset = vec_2(0, 23)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.burrow = {}
tt.burrow.disabled = true
tt.burrow.health_bar_offset = vec_2(0, 30)
tt.burrow.hit_offset = vec_2(0, -13)
tt.burrow.min_distance = 100
tt.burrow.mod_offset = vec_2(0, -7)
tt.burrow.stun_speed = 160
tt.burrow.radius = 80
tt.burrow.damage = 15
tt.burrow.init_accel = 40
tt.burrow.cooldown = 3
tt.burrow.ts = 0
tt.invuln = {}
tt.invuln.animation = "invuln"
tt.invuln.aura_name = "aura_crab_invuln"
tt.invuln.cooldown = 4
tt.invuln.disabled = true
tt.invuln.duration = 4
tt.invuln.exclude_damage_types = bor(DAMAGE_INSTAKILL, DAMAGE_DISINTEGRATE, DAMAGE_DISINTEGRATE, DAMAGE_EAT)
tt.invuln.sound = "HeroCrabShield"
tt.invuln.trigger_factor = 0.4
tt.invuln.ts = 0
tt.melee.cooldown = 1.2
tt.melee.range = 83.2
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_time = fts(18)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 2.5
tt.melee.attacks[1].sound = "MeleeSword"
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].disabled = true
tt.ranged.attacks[1].animation = "small_cannon"
tt.ranged.attacks[1].bullet = "crab_water_bomb"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(9, 50)}
tt.ranged.attacks[1].cooldown = 9
tt.ranged.attacks[1].max_range = 256
tt.ranged.attacks[1].shoot_time = fts(15)
tt.ranged.attacks[1].xp_from_skill = "shouldercannon"
tt.ranged.attacks[1].node_prediction = fts(35)
tt.ranged.attacks[1].check_target_before_shot = true
tt.timed_attacks.list[1] = CC("area_attack")
tt.timed_attacks.list[1].animation = "pincer"
tt.timed_attacks.list[1].cooldown = 7.2
tt.timed_attacks.list[1].damage_max = nil
tt.timed_attacks.list[1].damage_min = nil
tt.timed_attacks.list[1].damage_size = vec_2(120, 25)
tt.timed_attacks.list[1].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].hit_time = fts(12)
tt.timed_attacks.list[1].max_range = 110
tt.timed_attacks.list[1].min_count = 1
tt.timed_attacks.list[1].sound = "HeroCrabPrincer"
tt.timed_attacks.list[1].xp_from_skill = "pincerattack"
tt.vis.flags = bor(tt.vis.flags, F_MOCKING)
tt = RT("crab_water_bomb", "bomb")
tt.bullet.damage_radius = 60
tt.bullet.flight_time = fts(20)
tt.bullet.hit_decal = nil
tt.bullet.hit_fx = "fx_crab_water_bomb_explosion"
tt.bullet.hit_fx_water = "fx_crab_water_bomb_explosion"
tt.bullet.hit_payload = "aura_slow_water_bomb"
tt.sound_events.insert = "HeroCrabCannon"
tt.sound_events.hit = "HeroCrabCannonExplosion"
tt.sound_events.hit_water = "HeroGiantExplosionRock"
tt.render.sprites[1].name = "hero_crabman_proy"
tt.render.sprites[1].scale = vec_1(1)
tt = RT("aura_slow_water_bomb", "aura")
tt.aura.mod = "mod_slow_water_bomb"
tt.aura.cycle_time = fts(1)
tt.aura.duration = fts(5)
tt.aura.radius = 60
tt.aura.vis_bans = F_FRIEND
tt.aura.vis_flags = F_MOD
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt = RT("mod_slow_water_bomb", "mod_slow")
tt.modifier.duration = nil
tt.slow.factor = nil
tt = RT("fx_crab_water_bomb_explosion", "fx")
tt.render.sprites[1].name = "fx_hero_crab_splash"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].anchor.y = 0.21212121212121213
tt.render.sprites[1].sort_y_offset = -5
tt = RT("mod_stun_burrow", "mod_stun")
tt.modifier.duration = 2.2
tt = RT("aura_crab_invuln", "aura")

AC(tt, "render", "tween")

local dur = 4

tt.aura.duration = dur
tt.aura.track_source = true
tt.main_script.update = aura_crab_invuln_update
tt.render.sprites[1].name = "fx_hero_crab_bubbles"
tt.render.sprites[1].anchor.y = 0.09722222222222222
tt.render.sprites[1].scale = vec_2(0.8, 0.8)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_crabman_invulnerable_effect"
tt.render.sprites[2].anchor.y = 0.09722222222222222
tt.render.sprites[2].scale = vec_2(0, 0)
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fts(11), 0}, {fts(16), 255}, {dur, 255}, {dur + fts(15), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].keys = {{0, 0}, {fts(19), 255}, {dur, 255}, {dur + fts(15), 0}}
tt.tween.props[3] = CC("tween_prop")
tt.tween.props[3].name = "scale"
tt.tween.props[3].sprite_id = 2
tt.tween.props[3].keys = {{0, vec_2(0, 0)}, {fts(20), vec_2(0.75, 0.85)}}
tt.tween.props[4] = CC("tween_prop")
tt.tween.props[4].disabled = true
tt.tween.props[4].name = "scale"
tt.tween.props[4].sprite_id = 2
tt.tween.props[4].keys = {{0, vec_2(0.75, 0.85)}, {fts(10), vec_2(0.8, 0.8)}, {fts(20), vec_2(0.75, 0.85)}}
tt.tween.props[4].loop = true
