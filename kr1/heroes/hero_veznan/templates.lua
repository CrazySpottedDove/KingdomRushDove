local scripts = require("scripts")
local E = require("entity_db")
local P = require("path_db")
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
local tt

local function decal_veznan_soulburn_ball_update(this, store)
	local af = this.to.x > this.from.x

	this.pos.y = this.from.y + this.offset.y
	this.pos.x = this.from.x + (af and -1 or 1) * this.offset.x

	local dist = V.dist(this.pos.x, this.pos.y, this.to.x, this.to.y)
	local r = V.angleTo(this.to.x - this.pos.x, this.to.y - this.pos.y)
	local duration = dist / this.speed
	local fx = E:create_entity(this.spawn_fx)

	fx.pos.x, fx.pos.y = this.from.x, this.from.y
	fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.target.unit.size]
	fx.render.sprites[1].ts = store.tick_ts
	fx.render.sprites[1].flip_x = af

	simulation:queue_insert_entity(fx)
	U.y_animation_wait_default(fx)

	local ps = E:create_entity(this.particles_name)

	ps.particle_system.track_id = this.id

	simulation:queue_insert_entity(ps)

	this.render.sprites[1].hidden = nil
	this.render.sprites[1].r = r

	U.animation_start_default(this, "fly", nil, store.tick_ts, true)
	U.y_ease_keys(store, {this.pos, this.pos}, {"x", "y"}, {this.pos.x, this.pos.y}, {this.to.x, this.to.y}, duration, {"quad-out", "quad-out"})
	U.animation_start_default(this, "hit", nil, store.tick_ts, false)

	this.arrived = true

	U.y_animation_wait_default(this)
	simulation:queue_remove_entity(this)
end

local function hero_veznan_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	upgrade_skill(this, "soulburn", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.total_hp = s.total_hp[s.level]
	end)
	upgrade_skill(this, "shackles", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.max_count = s.max_count[s.level]
	end)
	upgrade_skill(this, "hermeticinsight", function(this, s)
		this.hermeticinsight_factor = s.range_factor[s.level]
	end)
	upgrade_skill(this, "arcanenova", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.damage_max = s.damage_max[s.level]
		a.damage_min = s.damage_min[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local u = E:get_template(s.controller_name)
		local m = E:get_template(u.mod)

		m.modifier.duration = s.stun_duration[s.level]

		local e = E:get_template(u.entity)

		e.health.hp_max = s.soldier_hp_max[s.level]
		e.melee.attacks[1].damage_max = s.soldier_damage_max[s.level]
		e.melee.attacks[1].damage_min = s.soldier_damage_min[s.level]

		local b = E:get_template(e.ranged.attacks[1].bullet)

		b.bullet.damage_max = s.soldier_damage_max[s.level]
		b.bullet.damage_min = s.soldier_damage_min[s.level]
	end)

	this.ranged.attacks[1].max_range = this.ranged.attacks[1].max_range_base * this.hermeticinsight_factor
	this.timed_attacks.list[1].range = this.timed_attacks.list[1].range_base * this.hermeticinsight_factor
	this.timed_attacks.list[2].range = this.timed_attacks.list[2].range_base * this.hermeticinsight_factor
	this.timed_attacks.list[3].max_range = this.timed_attacks.list[3].max_range_base * this.hermeticinsight_factor

	update_hp(this)
end

local function hero_veznan_update(this, store)
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
				if SU.y_hero_new_rally(store, this) then
					goto label_154_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.soulburn

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local triggers = U.find_enemies_in_range_filter_on(this.pos, a.range, a.vis_flags, a.vis_bans, function(e)
					return skill.level == 3 or e.health.hp_max <= a.total_hp
				end)

				if not triggers then
					a.ts = a.ts + 0.3333333333333333
				else
					table.sort(triggers, function(e1, e2)
						return e1.health.hp > e2.health.hp
					end)

					local targets = {}
					local first_target = triggers[1]

					table.insert(targets, first_target)

					local hp_count = first_target.health.hp

					if hp_count < a.total_hp then
						for _, t in pairs(triggers) do
							if t ~= first_target and hp_count + t.health.hp_max <= a.total_hp and U.is_inside_ellipse(t.pos, first_target.pos, a.radius) then
								table.insert(targets, t)

								hp_count = hp_count + t.health.hp_max
							end
						end
					end

					S:queue(a.sound)

					local af = first_target.pos.x < this.pos.x

					U.animation_start_default(this, a.animations[1], af, store.tick_ts, false)
					U.y_wait_unconditional(store, a.cast_time)

					local balls = {}
					local o = V.v(a.balls_dest_offset.x * (this.render.sprites[1].flip_x and -1 or 1), a.balls_dest_offset.y)

					for _, target in ipairs(targets) do
						local d = E.assign_damage(DAMAGE_EAT, 0, this.id, target.id)

						queue_damage(store, d)

						local fx = E:create_entity(a.hit_fx)

						fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
						fx.render.sprites[1].name = fx.render.sprites[1].size_names[target.unit.size]
						fx.render.sprites[1].ts = store.tick_ts

						simulation:queue_insert_entity(fx)

						local b = E:create_entity(a.ball)

						b.from = V.v(target.pos.x + target.unit.mod_offset.x, target.pos.y + target.unit.mod_offset.y)
						b.to = V.v(this.pos.x + o.x, this.pos.y + o.y)

						b.pos:copy(b.from)

						b.target = target

						simulation:queue_insert_entity(b)
						table.insert(balls, b)
					end

					U.y_animation_wait_default(this)
					U.animation_start_default(this, a.animations[2], nil, store.tick_ts, true)

					while true do
						coroutine.yield()

						local arrived = true

						for _, ball in pairs(balls) do
							arrived = arrived and ball.arrived
						end

						if arrived then
							break
						end

						if h.dead then
							goto label_154_0
						end
					end

					SU.hero_gain_xp_from_skill(this, skill)
					U.animation_start_default(this, a.animations[3], nil, store.tick_ts, false)
					U.y_animation_wait_default(this)

					a.ts = store.tick_ts
				end
			end

			a = this.timed_attacks.list[3]
			skill = this.hero.skills.arcanenova

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target, targets = U.find_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, a.cast_time, a.vis_flags, a.vis_bans)

				if not target or #targets < 2 then
					a.ts = a.ts + 0.3333333333333333
				else
					local af = target.pos.x < this.pos.x

					U.animation_start_default(this, a.animation, af, store.tick_ts, false)
					U.y_wait_unconditional(store, a.hit_time)

					local node = table.deepclone(target.nav_path)

					node.spi = 1

					local node_pos = P:node_pos(node.pi, node.spi, node.ni)
					local targets = U.find_enemies_in_range_filter_off(node_pos, a.damage_radius, a.vis_flags, a.vis_bans)

					if targets then
						SU.hero_gain_xp_from_skill(this, skill)

						for _, t in ipairs(targets) do
							queue_damage(store, SU.create_attack_damage(a, t.id, this))

							local m = E:create_entity(a.mod)

							m.modifier.source_id = this.id
							m.modifier.target_id = t.id

							simulation:queue_insert_entity(m)
						end
					end

					S:queue(a.cast_sound)

					local fx = E:create_entity(a.hit_fx)

					fx.pos.x, fx.pos.y = node_pos.x, node_pos.y

					U.animation_start_default(fx, nil, nil, store.tick_ts, false)
					simulation:queue_insert_entity(fx)
					U.y_wait_unconditional(store, fts(5))

					local decal = E:create_entity(a.hit_decal)

					decal.pos.x, decal.pos.y = node_pos.x, node_pos.y
					decal.tween.ts = store.tick_ts
					decal.render.sprites[2].ts = store.tick_ts

					simulation:queue_insert_entity(decal)
					U.y_animation_wait_default(this)

					a.ts = store.tick_ts
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.shackles

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local triggers = U.find_enemies_in_range_filter_off(this.pos, a.range, a.vis_flags, a.vis_bans)

				if not triggers then
					a.ts = a.ts + 0.3333333333333333
				else
					local first_target = table.random(triggers)
					local targets = U.find_enemies_in_range_filter_off(first_target.pos, a.radius, a.vis_flags, a.vis_bans)
					local af = first_target.pos.x < this.pos.x

					U.animation_start_default(this, a.animation, af, store.tick_ts, false)
					U.y_wait_unconditional(store, a.cast_time)
					S:queue(a.cast_sound)
					SU.hero_gain_xp_from_skill(this, skill)

					if targets then
						for i = 1, math.min(#targets, a.max_count) do
							local target = targets[i]

							for _, m_name in ipairs(a.mods) do
								local m = E:create_entity(m_name)

								m.modifier.target_id = target.id
								m.modifier.source_id = this.id

								simulation:queue_insert_entity(m)
							end
						end
					end

					U.y_animation_wait_default(this)

					a.ts = store.tick_ts
				end
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local target = find_target_at_critical_moment(this, this.ranged.attacks[1].max_range, F_RANGED, F_NONE)

				if target and target.pos and U.has_valid_rally_node_nearby(target.pos) then
					U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
					S:queue(this.sound_events.change_rally_point)

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

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			else
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
				-- block empty
				elseif SU.soldier_go_back_step(store, this) then
				-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_154_0::

		coroutine.yield()
	end
end

local function hero_veznan_ultimate_update(this, store)
	local e = E:create_entity(this.entity)

	e.pos.x, e.pos.y = this.pos.x, this.pos.y
	e.nav_rally.pos = V.vclone(e.pos)
	e.nav_rally.center = V.vclone(e.pos)

	simulation:queue_insert_entity(e)

	local targets = U.find_enemies_in_range_filter_off(this.pos, this.range, this.vis_flags, this.vis_bans)

	if targets then
		for _, target in ipairs(targets) do
			local m = E:create_entity(this.mod)

			m.modifier.source_id = this.id
			m.modifier.target_id = target.id

			simulation:queue_insert_entity(m)
		end
	end

	simulation:queue_remove_entity(this)
end

tt = RT("hero_veznan", "hero")

AC(tt, "melee", "ranged", "timed_attacks", "teleport")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {185, 200, 215, 230, 245, 260, 275, 290, 305, 320}
tt.hero.level_stats.melee_damage_max = {8, 10, 11, 12, 13, 14, 16, 17, 18, 19}
tt.hero.level_stats.melee_damage_min = {6, 6, 7, 8, 9, 10, 10, 11, 12, 13}
tt.hero.level_stats.ranged_damage_min = {14, 15, 17, 18, 20, 22, 26, 27, 29, 30}
tt.hero.level_stats.ranged_damage_max = {32, 36, 41, 45, 50, 54, 59, 63, 68, 72}
tt.hero.skills.soulburn = CC("hero_skill")
tt.hero.skills.soulburn.total_hp = {500, 1000, 1500}
tt.hero.skills.soulburn.xp_gain = {105, 210, 315}
tt.hero.skills.soulburn.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.shackles = CC("hero_skill")
tt.hero.skills.shackles.max_count = {3, 5, 7}
tt.hero.skills.shackles.xp_gain = {50, 100, 150}
tt.hero.skills.shackles.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.hermeticinsight = CC("hero_skill")
tt.hero.skills.hermeticinsight.range_factor = {1.1, 1.2, 1.3}
tt.hero.skills.hermeticinsight.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.arcanenova = CC("hero_skill")
tt.hero.skills.arcanenova.damage_min = {30, 50, 70}
tt.hero.skills.arcanenova.damage_max = {60, 100, 140}
tt.hero.skills.arcanenova.xp_gain = {45, 90, 135}
tt.hero.skills.arcanenova.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_veznan_ultimate"
tt.hero.skills.ultimate.stun_duration = {2, 3, 4, 5}
tt.hero.skills.ultimate.soldier_hp_max = {666, 999, 1337, 1666}
tt.hero.skills.ultimate.soldier_damage_max = {50, 90, 115, 130}
tt.hero.skills.ultimate.soldier_damage_min = {30, 50, 65, 80}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.xp_gain_factor = 96
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 41)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_veznan_level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.hero_portrait = "kr3_hero_portraits_0008"
tt.info.portrait = "kr3_info_portraits_heroes_0008"
tt.main_script.update = hero_veznan_update
tt.motion.max_speed = 2 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.125
tt.render.sprites[1].prefix = "veznan_hero"
tt.soldier.melee_slot_offset = vec_2(3, 0)
tt.sound_events.change_rally_point = "ElvesHeroVeznanTaunt"
tt.sound_events.death = "ElvesHeroVeznanDeath"
tt.sound_events.respawn = "ElvesHeroVeznanTauntIntro"
tt.sound_events.insert = "ElvesHeroVeznanTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroVeznanTauntSelect"
tt.teleport.min_distance = 55
tt.teleport.sound = "ElvesHeroVeznanTeleport"
tt.unit.hit_offset = vec_2(0, 15)
tt.unit.mod_offset = vec_2(0, 15)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(7)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 2.5
tt.melee.range = 55
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].max_range = 165
tt.ranged.attacks[1].max_range_base = 165
tt.ranged.attacks[1].min_range = 20
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].bullet = "bolt_veznan"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(20, 40)}
tt.ranged.attacks[1].shoot_time = fts(11)
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animations = {"soulBurnStart", "soulBurnLoop", "soulBurnEnd"}
tt.timed_attacks.list[1].ball = "decal_veznan_soulburn_ball"
tt.timed_attacks.list[1].balls_dest_offset = vec_2(17, 36)
tt.timed_attacks.list[1].cast_time = fts(8)
tt.timed_attacks.list[1].cooldown = 35
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].hit_fx = "fx_veznan_soulburn"
tt.timed_attacks.list[1].radius = 110
tt.timed_attacks.list[1].range = 140
tt.timed_attacks.list[1].range_base = 140
tt.timed_attacks.list[1].sound = "ElvesHeroVeznanSoulBurn"
tt.timed_attacks.list[1].vis_bans = bor(F_BOSS)
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_INSTAKILL)
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].animation = "shackles"
tt.timed_attacks.list[2].cast_sound = "ElvesHeroVeznanMagicSchackles"
tt.timed_attacks.list[2].cast_time = fts(14)
tt.timed_attacks.list[2].cooldown = 20
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].mods = {"mod_veznan_shackles_stun", "mod_veznan_shackles_dps"}
tt.timed_attacks.list[2].radius = 100
tt.timed_attacks.list[2].range = 150
tt.timed_attacks.list[2].range_base = 150
tt.timed_attacks.list[2].vis_bans = bor(F_BOSS)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED, F_MOD, F_STUN)
tt.timed_attacks.list[3] = CC("area_attack")
tt.timed_attacks.list[3].animation = "arcaneNova"
tt.timed_attacks.list[3].cast_sound = "ElvesHeroVeznanArcaneNova"
tt.timed_attacks.list[3].cooldown = 18
tt.timed_attacks.list[3].damage_max = nil
tt.timed_attacks.list[3].damage_min = nil
tt.timed_attacks.list[3].damage_radius = 125
tt.timed_attacks.list[3].damage_type = DAMAGE_MAGICAL_EXPLOSION
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].hit_decal = "decal_veznan_arcanenova"
tt.timed_attacks.list[3].hit_fx = "fx_veznan_arcanenova"
tt.timed_attacks.list[3].hit_time = fts(25)
tt.timed_attacks.list[3].max_range = 165
tt.timed_attacks.list[3].max_range_base = 165
tt.timed_attacks.list[3].min_range = 75
tt.timed_attacks.list[3].min_count = 2
tt.timed_attacks.list[3].mod = "mod_veznan_arcanenova"
tt.timed_attacks.list[3].vis_bans = 0
tt.ultimate = {
	ts = 0,
	cooldown = 96,
	disabled = true
}
tt.hermeticinsight_factor = 1
tt = RT("bolt_veznan", "bolt")
tt.render.sprites[1].prefix = "veznan_hero_bolt"
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.bullet.acceleration_factor = 0.1
tt.bullet.hit_fx = "fx_bolt_veznan_hit"
tt.bullet.xp_gain_factor = 2.5
tt.sound_events.insert = "ElvesHeroVeznanRangeShoot"
tt.bullet.pop = {"pop_mage"}
tt = RT("hero_veznan_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.cooldown = 96
tt.entity = "soldier_veznan_demon"
tt.main_script.update = hero_veznan_ultimate_update
tt.mod = "mod_veznan_ultimate_stun"
tt.range = 65
tt.sound_events.insert = "ElvesHeroVeznanDarkPact"
tt.vis_bans = bor(F_BOSS)
tt.vis_flags = bor(F_MOD, F_STUN)
tt = RT("mod_veznan_ultimate_stun", "mod_stun")
tt = RT("mod_veznan_arcanenova", "mod_slow")
tt.modifier.duration = 2
tt = RT("mod_veznan_shackles_stun", "mod_stun")
tt.render.sprites[1].prefix = "veznan_hero_shackles"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].name = "start"
tt.render.sprites[1].size_anchors = {vec_2(0.5, 0.7222222222222222), vec_2(0.5, 0.5483870967741935), vec_2(0.5, 0.4838709677419355)}
tt.modifier.animation_phases = true
tt.modifier.duration = 3
tt = RT("mod_veznan_shackles_dps", "modifier")

AC(tt, "dps")

tt.modifier.duration = 3
tt.dps.damage_min = 3
tt.dps.damage_max = 4
tt.dps.damage_every = fts(5)
tt.dps.damage_type = DAMAGE_TRUE
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt = RT("ps_veznan_soulburn")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "veznan_hero_soulBurn_particle"
tt.particle_system.loop = false
tt.particle_system.emission_rate = 30
tt.particle_system.particle_lifetime = {fts(4), fts(12)}
tt.particle_system.scales_x = {1, 1.25}
tt.particle_system.scales_y = {1, 1.25}
tt.particle_system.scale_var = {0.25, 1}
tt.particle_system.alphas = {255, 0}
tt = RT("fx_bolt_veznan_hit", "fx")
tt.render.sprites[1].name = "veznan_hero_bolt_hit"
tt = RT("fx_veznan_arcanenova", "fx")
tt.render.sprites[1].name = "fx_veznan_arcanenova"
tt.render.sprites[1].anchor.y = 0.11904761904761904
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("fx_veznan_soulburn", "decal_tween")
tt.render.sprites[1].prefix = "veznan_hero_soulBurn_desintegrate"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].loop = false
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].anchor.y = 0.15217391304347827
tt.tween.props[1].keys = {{0.5, 255}, {1, 0}}
tt = RT("fx_veznan_soulburn_ball_spawn", "fx")
tt.render.sprites[1].prefix = "veznan_hero_soulBurn_proy_spawn"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].z = Z_BULLETS
tt = RT("decal_veznan_arcanenova", "decal_bomb_crater")
tt.render.sprites[1].name = "veznan_hero_arcaneNova_terrainDecal"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "fx_veznan_arcanenova_terrain"
tt.render.sprites[2].hide_after_runs = 1
tt.render.sprites[2].z = Z_DECALS
tt = RT("decal_veznan_soulburn_ball", "decal_scripted")
tt.render.sprites[1].prefix = "veznan_hero_soulBurn_proy"
tt.render.sprites[1].name = "fly"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].hidden = true
tt.speed = 14 * FPS
tt.offset = vec_2(-5, 5)
tt.particles_name = "ps_veznan_soulburn"
tt.spawn_fx = "fx_veznan_soulburn_ball_spawn"
tt.main_script.update = decal_veznan_soulburn_ball_update
