local bit = require("bit")
local E = require("entity_db")
local GR = require("grid_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local scripts = require("scripts")
local signal = require("lib.hump.signal")

require("lib.klua.table")
require("all.constants")

local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)
	local a = this.melee.attacks[1]

	a.damage_max = ls.damage_max[hl]
	a.damage_min = ls.damage_min[hl]
	a = this.melee.attacks[2]
	a.damage_max = ls.damage_max[hl]
	a.damage_min = ls.damage_min[hl]

	upgrade_skill(this, "spinningpole", function(this, s)
		local a = this.melee.attacks[3]

		a.disabled = nil
		a.damage_min = s.damage[s.level]
		a.damage_max = s.damage[s.level]
		a.loops = s.loops[s.level]
	end)
	upgrade_skill(this, "tetsubostorm", function(this, s)
		local a = this.melee.attacks[4]

		a.disabled = nil
		a.damage_min = s.damage[s.level]
		a.damage_max = s.damage[s.level]
	end)
	upgrade_skill(this, "monkeypalm", function(this, s)
		local a = this.melee.attacks[5]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]

		local m = E:get_template(a.mod)

		m.modifier.duration = s.silence_duration[s.level]
		m.stun_duration = s.stun_duration[s.level]
	end)
	upgrade_skill(this, "angrygod", function(this, s)
		a = this.timed_attacks.list[1]
		a.disabled = nil

		local m = E:get_template(a.mod)

		m.received_damage_factor = s.received_damage_factor[s.level]
	end)
	update_hp(this)
end

local function hero_insert(this, store)
	this.hero.fn_level_up(this, store)

	this.melee.order = U.attack_order(this.melee.attacks)

	local e = E:create_entity("aura_monkey_god_divinenature")

	e.aura.source_id = this.id
	e.aura.ts = store.tick_ts

	simulation:queue_insert_entity(e)

	return true
end

local function hero_can_spinningpole(this, store, attack, target)
	local targets = U.find_enemies_in_range_filter_off(this.pos, attack.damage_radius, attack.vis_flags, attack.vis_bans)

	return targets and #targets >= attack.min_count
end

local function hero_update(this, store)
	local h = this.health
	local a, skill, brk, sta
	local cloud_trail = E:create_entity("ps_monkey_god_trail")

	cloud_trail.particle_system.track_id = this.id
	cloud_trail.particle_system.track_offset = V.v(0, 50)
	cloud_trail.particle_system.emit = false
	cloud_trail.particle_system.z = Z_OBJECTS

	simulation:queue_insert_entity(cloud_trail)
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
				local r = this.nav_rally
				local cw = this.cloudwalk
				local force_cloudwalk = false

				for _, p in pairs(this.nav_grid.waypoints) do
					if GR:cell_is(p.x, p.y, bor(TERRAIN_WATER, TERRAIN_SHALLOW, TERRAIN_NOWALK)) then
						force_cloudwalk = true

						break
					end
				end

				if force_cloudwalk or V.dist(this.pos.x, this.pos.y, r.pos.x, r.pos.y) > cw.min_distance then
					r.new = false

					U.unblock_target(store, this)
					U.bans_add(this.vis, F_ALL)

					this.health.immune_to = F_ALL

					local original_speed = this.motion.max_speed

					U.speed_inc_self(this, cw.extra_speed)

					this.unit.marker_hidden = true
					this.health_bar.hidden = true

					S:queue(this.sound_events.change_rally_point)
					S:queue(this.sound_events.cloud_start)
					SU.hide_modifiers(store, this, true)
					U.y_animation_play(this, cw.animations[1], r.pos.x < this.pos.x, store.tick_ts)
					SU.show_modifiers(store, this, true)
					S:queue(this.sound_events.cloud_loop)

					cloud_trail.particle_system.emit = true
					this.render.sprites[2].hidden = nil
					this.render.sprites[1].z = Z_BULLETS

					local ho = this.unit.hit_offset
					local mo = this.unit.mod_offset

					this.unit.hit_offset = cw.hit_offset
					this.unit.mod_offset = cw.mod_offset

					::label_452_0::

					local dest = r.pos
					local n = this.nav_grid

					while not V.veq(this.pos, dest) do
						local w = table.remove(n.waypoints, 1) or dest

						U.set_destination(this, w)

						local an, af = U.animation_name_facing_point(this, cw.animations[2], this.motion.dest)

						U.animation_start_default(this, an, af, store.tick_ts, true)

						while not this.motion.arrived do
							if r.new then
								r.new = false

								goto label_452_0
							end

							U.walk_off__accel__unsnapped(this, store.tick_length)
							coroutine.yield()

							this.motion.speed.x, this.motion.speed.y = 0, 0
						end
					end

					cloud_trail.particle_system.emit = false

					S:stop(this.sound_events.cloud_loop)
					S:queue(this.sound_events.cloud_end, this.sound_events.cloud_end_args)
					SU.hide_modifiers(store, this, true)
					U.y_animation_play(this, cw.animations[3], nil, store.tick_ts)
					SU.show_modifiers(store, this, true)

					this.render.sprites[1].z = Z_OBJECTS
					this.render.sprites[2].hidden = true

					U.update_max_speed(this, original_speed)
					U.bans_remove(this.vis, F_ALL)

					this.health.immune_to = 0
					this.unit.marker_hidden = nil
					this.health_bar.hidden = nil
					this.unit.hit_offset = ho
					this.unit.mod_offset = mo
				elseif SU.y_hero_new_rally(store, this) then
					goto label_452_2
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.angrygod

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local targets = U.find_enemies_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not targets or #targets < a.min_count then
					a.ts = a.ts + 0.2
				else
					S:queue(a.sound_start)
					U.y_animation_play(this, a.animations[1], nil, store.tick_ts, 1)

					a.ts = store.tick_ts
					this.melee.attacks[3].ts = 0
					this.melee.attacks[4].ts = 0
					this.melee.attacks[5].ts = 0

					SU.hero_gain_xp_from_skill(this, skill)
					S:queue(a.sound_loop)

					this.health.immune_to = F_ALL

					for i = 1, a.loops do
						U.animation_start_default(this, a.animations[2], nil, store.tick_ts, false)

						local targets = U.find_enemies_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

						if targets then
							for _, target in ipairs(targets) do
								local m = E:create_entity(a.mod)

								m.modifier.target_id = target.id
								m.modifier.source_id = this.id
								m.render.sprites[1].ts = store.tick_ts

								simulation:queue_insert_entity(m)

								local m = E:create_entity("mod_monkey_god_fire")

								m.modifier.target_id = target.id
								m.modifier.source_id = this.id
								m.modifier.level = skill.level

								simulation:queue_insert_entity(m)
							end
						end

						while not U.animation_finished_default(this) do
							if SU.hero_interrupted(this) then
								a.ts = a.ts - a.cooldown * (a.loops - i) / a.loops

								goto label_452_1
							end

							coroutine.yield()
						end
					end

					::label_452_1::

					this.health.immune_to = 0

					S:stop(a.sound_loop)
					U.y_animation_play(this, a.animations[3], nil, store.tick_ts, 1)

					goto label_452_2
				end
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

		::label_452_2::

		coroutine.yield()
	end
end

local function mod_monkey_god_palm_insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target and not target.health.dead then
		local sm = E:create_entity(this.stun_mod)

		sm.modifier.target_id = target.id
		sm.modifier.source_id = this.id
		sm.modifier.duration = this.stun_duration

		simulation:queue_insert_entity(sm)
		U.cast_silence(target, store.tick_ts)

		local s = this.render.sprites[1]

		s.ts = store.tick_ts

		if target.unit and target.unit.mod_offset then
			s.offset.x = target.unit.mod_offset.x
			s.offset.y = target.unit.mod_offset.y
		end

		local s_offset = this.custom_offsets[target.template_name] or this.custom_offsets.default

		if s_offset then
			s.offset.x = s.offset.x + s_offset.x
			s.offset.y = s.offset.y + s_offset.y
		end

		s.offset.x = (target.render.sprites[1].flip_x and -1 or 1) * s.offset.x

		signal.emit("mod-applied", this, target)

		return true
	-- end
	end

	return false
end

local tt

tt = RT("hero_monkey_god", "hero")

AC(tt, "melee", "timed_attacks")

tt.hero.level_stats.hp_max = {220, 240, 260, 280, 300, 320, 340, 360, 380, 400}
tt.hero.level_stats.armor = {0.18, 0.21, 0.24, 0.27, 0.3, 0.33, 0.36, 0.39, 0.42, 0.45}
tt.hero.level_stats.damage_min = {10, 12, 13, 15, 16, 17, 19, 20, 22, 23}
tt.hero.level_stats.damage_max = {16, 18, 21, 23, 26, 29, 31, 34, 36, 39}
tt.hero.skills.spinningpole = CC("hero_skill")
tt.hero.skills.spinningpole.xp_gain_factor = 28
tt.hero.skills.spinningpole.loops = {2, 3, 4}
tt.hero.skills.spinningpole.damage = {18, 26, 34}
tt.hero.skills.spinningpole.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.tetsubostorm = CC("hero_skill")
tt.hero.skills.tetsubostorm.damage = {35, 70, 105}
tt.hero.skills.tetsubostorm.xp_gain_factor = 60
tt.hero.skills.tetsubostorm.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.monkeypalm = CC("hero_skill")
tt.hero.skills.monkeypalm.stun_duration = {1, 2, 3}
tt.hero.skills.monkeypalm.silence_duration = {5, 10, 15}
tt.hero.skills.monkeypalm.damage_min = {10, 20, 30}
tt.hero.skills.monkeypalm.damage_max = {20, 40, 60}
tt.hero.skills.monkeypalm.xp_gain_factor = 60
tt.hero.skills.monkeypalm.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.angrygod = CC("hero_skill")
tt.hero.skills.angrygod.received_damage_factor = {1.25, 1.45, 1.65}
tt.hero.skills.angrygod.xp_gain_factor = 120
tt.hero.skills.angrygod.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.health.armor = nil
tt.health.dead_lifetime = 15
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 47)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(30)
tt.idle_flip.cooldown = 2
tt.info.hero_portrait = "kr2_hero_portraits_0016"
tt.info.portrait = "kr2_info_portraits_heroes_0016"
tt.main_script.insert = hero_insert
tt.main_script.update = hero_update
tt.motion.max_speed = 108
tt.nav_grid.valid_terrains = bor(TERRAIN_LAND, TERRAIN_WATER, TERRAIN_SHALLOW, TERRAIN_NOWALK, TERRAIN_ICE)
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.1891891891891892
tt.render.sprites[1].prefix = "hero_monkey_god"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"running"}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_monkeyGod_shadow"
tt.render.sprites[2].hidden = true
tt.render.sprites[2].offset = vec_2(0, 46)
tt.soldier.melee_slot_offset = vec_2(20, 0)
tt.sound_events.change_rally_point = "HeroMonkeyGodTaunt"
tt.sound_events.death = "HeroMonkeyGodDeath"
tt.sound_events.respawn = "HeroMonkeyGodTauntIntro"
tt.sound_events.insert = "HeroMonkeyGodTauntIntro"
tt.sound_events.hero_room_select = "HeroMonkeyGodTauntSelect"
tt.sound_events.cloud_start = "HeroMonkeyGodCloudJump"
tt.sound_events.cloud_loop = "HeroMonkeyGodCloudWalkLoop"
tt.sound_events.cloud_end = "HeroMonkeyGodCloudDrop"
tt.sound_events.cloud_end_args = {
	delay = fts(14)
}
tt.unit.hit_offset = vec_2(0, 11)
tt.unit.marker_offset = vec_2(0, -2)
tt.unit.mod_offset = vec_2(0, 14)
tt.cloudwalk = {}
tt.cloudwalk.min_distance = 300
tt.cloudwalk.extra_speed = 108
tt.cloudwalk.animations = {"cloud_start", "cloud_loop", "cloud_end"}
tt.cloudwalk.hit_offset = vec_2(0, 60)
tt.cloudwalk.mod_offset = vec_2(0, 64)
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "HeroMonkeyGodAttack1"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 3.5
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[2].sound = "HeroMonkeyGodAttack2"
tt.melee.attacks[3] = CC("area_attack")
tt.melee.attacks[3].animations = {"pole_start", "pole_loop", "pole_end"}
tt.melee.attacks[3].cooldown = 13
tt.melee.attacks[3].damage_max = nil
tt.melee.attacks[3].damage_min = nil
tt.melee.attacks[3].damage_radius = 90
tt.melee.attacks[3].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].fn_can = hero_can_spinningpole
tt.melee.attacks[3].hit_time = fts(8)
tt.melee.attacks[3].loopable = true
tt.melee.attacks[3].min_count = 2
tt.melee.attacks[3].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[3].vis_flags = F_BLOCK
tt.melee.attacks[3].xp_from_skill = "spinningpole"
tt.melee.attacks[3].sound = "HeroMonkeyGodSpinningPoleLoop"
tt.melee.attacks[3].sound_end = "HeroMonkeyGodSpinningPoleLoopEnd"
tt.melee.attacks[4] = CC("melee_attack")
tt.melee.attacks[4].animations = {"tetsubo_start", "tetsubo_loop", "tetsubo_end"}
tt.melee.attacks[4].cooldown = 13
tt.melee.attacks[4].damage_max = nil
tt.melee.attacks[4].damage_min = nil
tt.melee.attacks[4].disabled = true
tt.melee.attacks[4].hit_times = {fts(1), fts(4), fts(9)}
tt.melee.attacks[4].loopable = true
tt.melee.attacks[4].loops = 2
tt.melee.attacks[4].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[4].vis_flags = F_BLOCK
tt.melee.attacks[4].xp_from_skill = "tetsubostorm"
tt.melee.attacks[4].sound = "HeroMonkeyGodTetsuboStorm"
tt.melee.attacks[5] = CC("melee_attack")
tt.melee.attacks[5].animation = "palm"
tt.melee.attacks[5].disabled = true
tt.melee.attacks[5].damage_type = DAMAGE_MIXED
tt.melee.attacks[5].damage_max = nil
tt.melee.attacks[5].damage_min = nil
tt.melee.attacks[5].mod = "mod_monkey_god_palm"
tt.melee.attacks[5].vis_bans = bor(F_BOSS, F_STUN)
tt.melee.attacks[5].vis_flags = F_BLOCK
tt.melee.attacks[5].xp_from_skill = "monkeypalm"
tt.melee.attacks[5].sound = "HeroMonkeyGodMonkeyPalm"
tt.melee.attacks[5].hit_time = fts(12)
tt.melee.attacks[5].cooldown = 10
tt.melee.attacks[5].side_effect = function(this, store, damage, target)
	this.timed_attacks.list[1].ts = this.timed_attacks.list[1].ts - 4
end
tt.melee.range = 64
tt.melee.cooldown = 1
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animations = {"angry_start", "angry_loop", "angry_end"}
tt.timed_attacks.list[1].cooldown = 33
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].loops = 8
tt.timed_attacks.list[1].min_count = 5
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].max_range = 9999
tt.timed_attacks.list[1].mod = "mod_monkey_god_angry"
tt.timed_attacks.list[1].sound_start = "HeroMonkeyGodAngryGodScream"
tt.timed_attacks.list[1].sound_loop = "HeroMonkeyGodAngryGodLoop"
tt.vis.bans = bor(F_POISON)
tt = RT("aura_monkey_god_divinenature", "aura_beastmaster_regeneration")
tt.hps.heal_min = 3
tt.hps.heal_max = 3
tt.hps.heal_every = fts(10)
tt = RT("mod_monkey_god_angry", "modifier")

AC(tt, "render")

tt.inflicted_damage_factor = 1
tt.modifier.duration = 2
tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.remove = scripts.mod_damage_factors.remove
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].name = "fx_monkey_god_angry"
tt.render.sprites[1].size_scales = {vec_1(1), vec_1(1.2), vec_1(1.4)}
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].anchor.y = 0.46551724137931033
tt = RT("mod_monkey_god_fire", "modifier")

AC(tt, "dps")

tt.modifier.duration = 2
tt.modifier.vis_flags = F_BURN
tt.dps.damage_min = 1
tt.dps.damage_max = 1
tt.dps.damage_inc = 3
tt.dps.damage_every = 0.5
tt.dps.damage_type = DAMAGE_TRUE
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt = RT("mod_monkey_god_palm", "modifier")

AC(tt, "render")

tt.main_script.insert = mod_monkey_god_palm_insert
tt.main_script.remove = scripts.mod_silence.remove
tt.main_script.update = scripts.mod_track_target.update
tt.stun_mod = "mod_stun"
tt.modifier.bans = {"mod_shaman_armor", "mod_shaman_magic_armor", "mod_shaman_priest_heal", "mod_silence_totem"}
tt.modifier.remove_banned = true
tt.modifier.use_mod_offset = false
tt.render.sprites[1].name = "fx_monkey_god_palm"
tt.render.sprites[1].draw_order = 2
tt.custom_offsets = {}
tt.custom_offsets.default = vec_2(0, 18)
tt.custom_offsets.enemy_munra = vec_2(0, 18)
tt.custom_offsets.enemy_shaman_priest = vec_2(0, 16)
tt.custom_offsets.enemy_shaman_magic = vec_2(0, 18)
tt.custom_offsets.enemy_shaman_shield = vec_2(0, 16)
tt.custom_offsets.enemy_shaman_necro = vec_2(0, 18)
tt.custom_offsets.enemy_nightscale = vec_2(0, 22)
tt.custom_offsets.enemy_darter = vec_2(0, 16)
tt.custom_offsets.enemy_savant = vec_2(0, 18)
tt.custom_offsets.enemy_bluegale = vec_2(0, 22)
tt.custom_offsets.enemy_blacksurge = vec_2(0, 18)
tt.custom_offsets.enemy_phantom_warrior = vec_2(0, 18)
tt = RT("ps_monkey_god_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.alphas = {150, 0}
tt.particle_system.emission_rate = 20
tt.particle_system.emit_area_spread = vec_2(15, 10)
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.names = {"hero_monkeyGod_cloudParticle_0001", "hero_monkeyGod_cloudParticle_0003"}
tt.particle_system.particle_lifetime = {0.5, 0.75}
tt.particle_system.scale_var = {0.9, 1.1}
tt.particle_system.scales_x = {1, 0.2}
tt.particle_system.scales_y = {1, 0.2}
tt.particle_system.sort_y_offset = -45
tt.particle_system.spin = {-math.pi * 0.5, math.pi * 0.5}
--  三代
-- 艾莉丹
